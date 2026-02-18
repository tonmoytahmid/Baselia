import 'package:baseliae_flutter/Controller/PostController/CommentsController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Forumsreply extends StatefulWidget {
  const Forumsreply({super.key});

  @override
  State<Forumsreply> createState() => _ForumsreplyState();
}

class _ForumsreplyState extends State<Forumsreply> {
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

  
  Future<void> addReply(String postId, String commentId, String userId, String text) async {
    CollectionReference replies = _firestore
        .collection('Forums')
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
        .collection('Forums')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .orderBy('timestamp', descending: true)
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
        title: Text("Replies")),
      body: Column(
        children: [
         
          ListTile(
            leading: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(comment['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return CircleAvatar(child: Icon(Icons.person));
                }

                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
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
                var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                return Text(userData['fullName']);
              },
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment['text']),
               
              ],
            ),
          ),
          
          
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
        reverse: false, // Oldest first
        itemCount: replies.length,
        itemBuilder: (context, index) {
          var replyData = replies[index].data() as Map<String, dynamic>;
          String userId = replyData['userId'];
          bool isCurrentUser = userId == auth!.uid;

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return SizedBox(); 
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                child: Row(
                  mainAxisAlignment:
                      isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isCurrentUser) 
                      CircleAvatar(
                        backgroundImage: NetworkImage(userData['profileImage']),
                      ),
                    SizedBox(width: 10),

                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userData['fullName'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(replyData['text']),
                          ],
                        ),
                      ),
                    ),

                    if (isCurrentUser) 
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: NetworkImage(userData['profileImage']),
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

          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: "Write a reply...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (commentController.text.isNotEmpty) {
                      addReply(postId, commentId, auth!.uid, commentController.text);
                      commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
