// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:baseliae_flutter/Component/CommentTextfield.dart';
import 'package:baseliae_flutter/Controller/PostController/CommentsController.dart';
import 'package:baseliae_flutter/Fatching/Comments/FatchingReplys.dart';
import 'package:baseliae_flutter/Fatching/Comments/ReplysScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Ftchingcomments extends StatefulWidget {
  final String postId;

  const Ftchingcomments({super.key, required this.postId});

  @override
  State<Ftchingcomments> createState() => _FtchingcommentsState();
}

class _FtchingcommentsState extends State<Ftchingcomments> {
  final CommentsController controller = Get.put(CommentsController());
  TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? auth = FirebaseAuth.instance.currentUser;

  Future<void> _toggleLike(String commentId) async {
    String userId = auth!.uid;

    DocumentReference commentRef = _firestore
        .collection('posts')
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

  /// Fetch name and profile image based on account type
  Future<Map<String, dynamic>> _getCommenterData(
      Map<String, dynamic> comment) async {
    final accountType = comment['accountType'] ?? 'user';
    final userId = comment['userId'];

    try {
      DocumentSnapshot userDoc;

      if (accountType == 'page') {
        userDoc = await _firestore.collection('ChurchPages').doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          return {
            'name': data['churchName'] ?? 'Unknown Page',
            'image': data['profileImage'] ?? '',
          };
        }
      } else {
        userDoc = await _firestore.collection('Users').doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;
          return {
            'name': data['fullName'] ?? 'Unknown User',
            'image': data['profileImage'] ?? '',
          };
        }
      }
    } catch (e) {
      print("❌ Error fetching commenter info: $e");
    }

    return {'name': 'Unknown', 'image': ''};
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
              // Get current user's account type
              String accountType = 'user';
              DocumentSnapshot userDoc =
                  await _firestore.collection('Users').doc(auth!.uid).get();
              if (userDoc.exists && userDoc.data() != null) {
                final data = userDoc.data() as Map<String, dynamic>;
                accountType = data['accountType'] ?? 'user';
              }

              await controller.addComment(
                widget.postId,
                auth!.uid,
                commentController.text.trim(),
                accountType,
              );

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
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      var comment = comments[index];
                      var commentId = comment.id;
                      var commentData = comment.data() as Map<String, dynamic>;

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getCommenterData(commentData),
                        builder: (context, userSnapshot) {
                          final userData = userSnapshot.data ??
                              {
                                'name': 'Loading...',
                                'image': '',
                              };

                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: userData['image'].isNotEmpty
                                      ? NetworkImage(userData['image'])
                                      : null,
                                  child: userData['image'].isEmpty
                                      ? Icon(Icons.person)
                                      : null,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userData['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        commentData['text'] ?? '',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            onPressed: () {
                                              Get.to(() => Replysscreen(),
                                                  arguments: {
                                                    'postId': widget.postId,
                                                    'commentId': commentId,
                                                    'comment': comment,
                                                  });
                                            },
                                            icon: Icon(Icons.reply, size: 18),
                                            label: Text("Reply",
                                                style: TextStyle(fontSize: 14)),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '${commentData['likeCount'] ?? 0}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _toggleLike(commentId),
                                            icon: Icon(
                                              commentData['reactions']
                                                          ?.containsKey(
                                                              auth!.uid) ??
                                                      false
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: commentData['reactions']
                                                          ?.containsKey(
                                                              auth!.uid) ??
                                                      false
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Fatchingreplys(
                                          postId: widget.postId,
                                          commentId: commentId,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
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

// // ignore_for_file: unused_local_variable

// import 'package:baseliae_flutter/Component/CommentTextfield.dart';
// import 'package:baseliae_flutter/Controller/PostController/CommentsController.dart';
// import 'package:baseliae_flutter/Fatching/Comments/FatchingReplys.dart';
// import 'package:baseliae_flutter/Fatching/Comments/ReplysScreen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Ftchingcomments extends StatefulWidget {
//   String postId;

//   Ftchingcomments({super.key, required this.postId});

//   @override
//   State<Ftchingcomments> createState() => _FtchingcommentsState();
// }

// class _FtchingcommentsState extends State<Ftchingcomments> {
//   final CommentsController controller = Get.put(CommentsController());
//   TextEditingController commentController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? auth = FirebaseAuth.instance.currentUser;

//   // ignore: unused_element
//   Future<void> _fetchCommentData(String commentId) async {
//     DocumentSnapshot commentSnapshot = await _firestore
//         .collection('posts')
//         .doc(widget.postId)
//         .collection('comments')
//         .doc(commentId)
//         .get();

//     setState(() {});
//   }

//   Future<void> _toggleLike(String commentId) async {
//     String userId = auth!.uid;

//     DocumentReference commentRef = FirebaseFirestore.instance
//         .collection('posts')
//         .doc(widget.postId)
//         .collection('comments')
//         .doc(commentId);

//     DocumentSnapshot snapshot = await commentRef.get();
//     var reactions = Map<String, bool>.from(snapshot['reactions'] ?? {});
//     int likeCount = snapshot['likeCount'] ?? 0;

//     if (reactions[userId] == true) {
//       reactions.remove(userId);
//       likeCount--;
//     } else {
//       reactions[userId] = true;
//       likeCount++;
//     }

//     await commentRef.update({
//       'reactions': reactions,
//       'likeCount': likeCount,
//     });

//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       bottomNavigationBar: Padding(
//         padding:
//             EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         child: Commenttextfield(
//           controller: commentController,
//           onPressed: () async {
//             if (commentController.text.isNotEmpty) {
//               await controller.addComment(
//                   widget.postId, auth!.uid, commentController.text,);
//               commentController.clear();
//             }
//           },
//         ),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           children: [
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: controller.fetchComments(widget.postId),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) {
//                     return Center(child: CircularProgressIndicator());
//                   }
//                   var comments = snapshot.data!.docs;

//                   return ListView.builder(
//                     shrinkWrap: true,
//                     physics: BouncingScrollPhysics(),
//                     itemCount: comments.length,
//                     itemBuilder: (context, index) {
//                       var comment = comments[index];
//                       var commentId = comment.id;

//                       return Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Profile Image
//                             FutureBuilder<DocumentSnapshot>(
//                               future: FirebaseFirestore.instance
//                                   .collection('Users')
//                                   .doc(comment['userId'])
//                                   .get(),
//                               builder: (context, userSnapshot) {
//                                 if (!userSnapshot.hasData ||
//                                     !userSnapshot.data!.exists) {
//                                   return CircleAvatar(
//                                       child: Icon(Icons.person));
//                                 }
//                                 var userData = userSnapshot.data!;
//                                 return CircleAvatar(
//                                   radius: 22,
//                                   backgroundImage:
//                                       NetworkImage(userData['profileImage']),
//                                 );
//                               },
//                             ),
//                             SizedBox(width: 10),
//                             // Name, comment, and buttons
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   FutureBuilder<DocumentSnapshot>(
//                                     future: FirebaseFirestore.instance
//                                         .collection('Users')
//                                         .doc(comment['userId'])
//                                         .get(),
//                                     builder: (context, userSnapshot) {
//                                       if (!userSnapshot.hasData ||
//                                           !userSnapshot.data!.exists) {
//                                         return Text("Unknown User",
//                                             style: TextStyle(
//                                                 fontWeight: FontWeight.bold));
//                                       }
//                                       var userData = userSnapshot.data!;
//                                       return Text(
//                                         userData['fullName'],
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       );
//                                     },
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     comment['text'],
//                                     style: TextStyle(fontSize: 15),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Row(
//                                     children: [
//                                       TextButton.icon(
//                                         onPressed: () {
//                                           Get.to(() => Replysscreen(),
//                                               arguments: {
//                                                 'postId': widget.postId,
//                                                 'commentId': commentId,
//                                                 'comment': comment,
//                                               });
//                                         },
//                                         icon: Icon(Icons.reply, size: 18),
//                                         label: Text("Reply",
//                                             style: TextStyle(fontSize: 14)),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Text(
//                                         '${comment['likeCount'] ?? 0}',
//                                         style: TextStyle(fontSize: 14),
//                                       ),
//                                       IconButton(
//                                         onPressed: () => _toggleLike(commentId),
//                                         icon: Icon(
//                                           comment['reactions']
//                                                   .containsKey(auth!.uid)
//                                               ? Icons.favorite
//                                               : Icons.favorite_border,
//                                           color: comment['reactions']
//                                                   .containsKey(auth!.uid)
//                                               ? Colors.red
//                                               : Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   // Replies
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 8.0),
//                                     child: Fatchingreplys(
//                                       postId: widget.postId,
//                                       commentId: commentId,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
