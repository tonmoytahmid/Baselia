/// ignore_for_file: unused_field
library;

import 'package:baseliae_flutter/Component/CommentTextfield.dart';
import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart'
    show UserSessionController;
import 'package:baseliae_flutter/Controller/PostController/CommentsController.dart';
import 'package:baseliae_flutter/Fatching/Comments/FatchingReplys.dart';
import 'package:baseliae_flutter/Fatching/Comments/ReplysScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Fatchingtopcomment extends StatefulWidget {
  final String postId;

  const Fatchingtopcomment({super.key, required this.postId});

  @override
  State<Fatchingtopcomment> createState() => _FatchingtopcommentState();
}

class _FatchingtopcommentState extends State<Fatchingtopcomment> {
  final CommentsController controller = Get.put(CommentsController());
  final TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? auth = FirebaseAuth.instance.currentUser;

  Future<void> _toggleLike(String commentId) async {
    final userId = auth!.uid;
    final commentRef = _firestore
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(commentId);

    final snapshot = await commentRef.get();
    final reactions = Map<String, bool>.from(snapshot['reactions'] ?? {});
    int likeCount = snapshot['likeCount'] ?? 0;

    if (reactions[userId] == true) {
      reactions.remove(userId);
      likeCount--;
    } else {
      reactions[userId] = true;
      likeCount++;
    }

    await commentRef.update({'reactions': reactions, 'likeCount': likeCount});
    setState(() {});
  }

  Future<Map<String, dynamic>> _getCommenterData(
      Map<String, dynamic> comment) async {
    final userId = comment['userId'];
    final accountType = comment['accountType'] ?? 'user';

    try {
      if (accountType == 'page') {
        final doc =
            await _firestore.collection('ChurchPages').doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          return {
            'name': data['churchName'] ?? 'Unknown Page',
            'image': data['profileImage'] ?? '',
          };
        }
      } else {
        final doc = await _firestore.collection('Users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          return {
            'name': data['fullName'] ?? 'Unknown User',
            'image': data['profileImage'] ?? '',
          };
        }
      }
    } catch (e) {
      print('Error loading commenter info: $e');
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
            if (commentController.text.trim().isEmpty) return;

            // ✅ Get userId and accountType from session
            final session = Get.find<UserSessionController>();
            final String userId = session.activeUid.value;
            final String accountType =
                session.isPageProfile.value ? 'page' : 'user';

            await controller.addComment(
              widget.postId,
              userId,
              commentController.text.trim(),
              accountType,
            );

            commentController.clear();
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
                stream: _firestore
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .orderBy('likeCount', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No comments available.'));
                  }

                  final comments = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment =
                          comments[index].data() as Map<String, dynamic>;
                      final commentId = comments[index].id;

                      return FutureBuilder<Map<String, dynamic>>(
                        future: _getCommenterData(comment),
                        builder: (context, userSnap) {
                          final user = userSnap.data ??
                              {'name': 'Loading...', 'image': ''};

                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundImage: user['image'].isNotEmpty
                                      ? NetworkImage(user['image'])
                                      : null,
                                  child: user['image'].isEmpty
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
                                        user['name'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(comment['text'] ?? '',
                                          style: TextStyle(fontSize: 15)),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            icon: Icon(Icons.reply, size: 18),
                                            label: Text("Reply",
                                                style: TextStyle(fontSize: 14)),
                                            onPressed: () {
                                              Get.to(() => Replysscreen(),
                                                  arguments: {
                                                    'postId': widget.postId,
                                                    'commentId': commentId,
                                                    'comment': comment,
                                                  });
                                            },
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            '${comment['likeCount'] ?? 0}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _toggleLike(commentId),
                                            icon: Icon(
                                              comment['reactions']?.containsKey(
                                                          auth!.uid) ??
                                                      false
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: comment['reactions']
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
                                )
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



// // ignore_for_file: unused_field

// import 'package:baseliae_flutter/Component/CommentTextfield.dart';
// import 'package:baseliae_flutter/Controller/PostController/CommentsController.dart';
// import 'package:baseliae_flutter/Fatching/Comments/FatchingReplys.dart';
// import 'package:baseliae_flutter/Fatching/Comments/ReplysScreen.dart';


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class Fatchingtopcomment extends StatefulWidget {
//   String postId;

//   Fatchingtopcomment({super.key, required this.postId});

//   @override
//   State<Fatchingtopcomment> createState() => _FatchingtopcommentState();
// }

// class _FatchingtopcommentState extends State<Fatchingtopcomment> {
//   final CommentsController controller = Get.put(CommentsController());
//   TextEditingController commentController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? auth = FirebaseAuth.instance.currentUser;

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
//                   widget.postId, auth!.uid, commentController.text);
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
//                 stream: FirebaseFirestore.instance
//                     .collection('posts')
//                     .doc(widget.postId)
//                     .collection('comments')
//                     .orderBy('likeCount', descending: true)
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   }

//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return Center(child: Text('No comments available.'));
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
