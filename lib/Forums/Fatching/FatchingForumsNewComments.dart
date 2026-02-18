// ignore_for_file: unused_local_variable

import 'package:baseliae_flutter/Component/CommentTextfield.dart';


import 'package:baseliae_flutter/Forums/ForumsController/ForumsComments/ForumsCommentsController.dart';
import 'package:baseliae_flutter/Forums/Fatching/ForumsReply.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FatchingForumsNewComments extends StatefulWidget {
  String postId;

  FatchingForumsNewComments({super.key, required this.postId});

  @override
  State<FatchingForumsNewComments> createState() => _FatchingForumsNewCommentsState();
}

class _FatchingForumsNewCommentsState extends State<FatchingForumsNewComments> {
  final ForumsCommentsController controller = Get.put(ForumsCommentsController());
  TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? auth = FirebaseAuth.instance.currentUser;

  // ignore: unused_element
  Future<void> _fetchCommentData(String commentId) async {
    DocumentSnapshot commentSnapshot = await _firestore
        .collection('Forums')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId)
        .get();

    setState(() {});
  }

  Future<void> _toggleLike(String commentId) async {
    String userId = auth!.uid;

    DocumentReference commentRef = FirebaseFirestore.instance
        .collection('Forums')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    DocumentSnapshot snapshot = await commentRef.get();
    var reactions = Map<String, bool>.from(snapshot['reactions'] ?? {});
    int likeCount = snapshot['likeCount'] ?? 0;

    if (reactions[userId] == true) {
      reactions.remove(userId);
      likeCount--;
    } else {
      reactions[userId] = true;
      likeCount++;
    }

    await commentRef.update({
      'reactions': reactions,
      'likeCount': likeCount,
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Commenttextfield(
          controller: commentController,
          onPressed: () async {
            if (commentController.text.isNotEmpty) {
              await controller.addComment(
                  widget.postId, auth!.uid, commentController.text);
              commentController.clear();
            }
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: controller.fetchComments(widget.postId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  var comments = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index];
                      var commentId = comment.id;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(()=>Forumsreply(), arguments: {
                                'postId': widget.postId,
                                'commentId': commentId,
                                'comment': comment,
                              });
                            },
                            child: ListTile(
                              leading: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(comment['userId'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (!userSnapshot.hasData ||
                                      !userSnapshot.data!.exists) {
                                    return CircleAvatar(
                                        child: Icon(Icons.person));
                                  }

                                  var userData = userSnapshot.data!;
                                  return CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(userData['profileImage']),
                                  );
                                },
                              ),
                              title: FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(comment['userId'])
                                    .get(),
                                builder: (context, userSnapshot) {
                                  if (!userSnapshot.hasData ||
                                      !userSnapshot.data!.exists) {
                                    return Text("Unknown User");
                                  }
                                  var userData = userSnapshot.data!;
                                  return Text(userData['fullName']);
                                },
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(comment['text']),
                                  Text("Replys"),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${comment['likeCount'] ?? 0}'),
                                  IconButton(
                                    onPressed: () => _toggleLike(commentId),
                                    icon: Icon(
                                      comment['reactions']
                                              .containsKey(auth!.uid)
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: comment['reactions']
                                              .containsKey(auth!.uid)
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
