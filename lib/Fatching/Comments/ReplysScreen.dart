import 'package:baseliae_flutter/Controller/PostController/CommentsController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/CaptionWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Replysscreen extends StatefulWidget {
  const Replysscreen({super.key});

  @override
  State<Replysscreen> createState() => _ReplysscreenState();
}

class _ReplysscreenState extends State<Replysscreen> {
  String commentId = Get.arguments['commentId'];
  DocumentSnapshot commentSnapshot = Get.arguments['comment'];
  Map<String, dynamic> comment = {};
  String postId = Get.arguments['postId'];

  final CommentsController controller = Get.put(CommentsController());
  TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? auth = FirebaseAuth.instance.currentUser;

  void _initializeCommentData() {
    if (commentSnapshot.exists) {
      comment = commentSnapshot.data() as Map<String, dynamic>;
    }
  }

  Future<void> addReply(
      String postId, String commentId, String userId, String text) async {
    CollectionReference replies = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies');

    await replies.add({
      'userId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'reactions': {},
    });
  }

  Stream<QuerySnapshot> getRepliesStream() {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  @override
  void initState() {
    super.initState();
    _initializeCommentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.purple),
        backgroundColor: whit,
        title: Text("Replies", style: TextStyle(color: Colors.black)),
      ),
      body: Column(
        children: [
          // Main Comment Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Card(
              color: whit,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(comment['userId'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return CircleAvatar(child: Icon(Icons.person));
                    }
                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    return CircleAvatar(
                      backgroundImage: NetworkImage(userData['profileImage']),
                    );
                  },
                ),
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(comment['userId'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return Text("Unknown User");
                    }
                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    return Text(
                      userData['fullName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    );
                  },
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(comment['text']),
                  ],
                ),
              ),
            ),
          ),

          Divider(),

          // Replies Section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getRepliesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No replies yet.'));
                }

                var replies = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: replies.length,
                  itemBuilder: (context, index) {
                    var replyData =
                        replies[index].data() as Map<String, dynamic>;
                    String userId = replyData['userId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(userId)
                          .get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return SizedBox();
                        }

                        var userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Card(
                            color: Colors.grey[100],
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        NetworkImage(userData['profileImage']),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData['fullName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        CaptionWidget(
                                            caption: replyData['text']),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Input Field for Reply
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: InputDecoration(
                        hintText: "Write a reply...",
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.purple),
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        addReply(
                          postId,
                          commentId,
                          auth!.uid,
                          commentController.text.trim(),
                        );
                        commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
