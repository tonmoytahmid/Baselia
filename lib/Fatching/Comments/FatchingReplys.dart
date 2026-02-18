import 'package:baseliae_flutter/Widgets/Posting/CaptionWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class Fatchingreplys extends StatefulWidget {
  final String postId;
  final String commentId;
   const Fatchingreplys({super.key,required this.postId, required this.commentId});

  @override
  State<Fatchingreplys> createState() => _FatchingreplysState();
}

class _FatchingreplysState extends State<Fatchingreplys> {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('posts')
                                .doc(widget.postId)
                                .collection('comments')
                                .doc(widget.commentId)
                                .collection('replies')
                                .orderBy('timestamp', descending: false)
                                .limit(1)
                                .snapshots(),
                            builder: (context, replySnapshot) {
                              if (!replySnapshot.hasData ||
                                  replySnapshot.data!.docs.isEmpty) {
                                return Padding(
                                  padding:  EdgeInsets.only(left: 20),
                                  child: Text("",
                                      style: TextStyle(color: Colors.grey)),
                                );
                              }

                              var reply = replySnapshot.data!.docs.first;

                              return Padding(
                                padding: EdgeInsets.all(20),
                                child: Container(
                                  margin: EdgeInsets.only(top: 6),
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: FutureBuilder<DocumentSnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(reply['userId'])
                                        .get(),
                                    builder: (context, replyUserSnapshot) {
                                      if (!replyUserSnapshot.hasData ||
                                          !replyUserSnapshot.data!.exists) {
                                        return Text("Unknown");
                                      }

                                      var replyUser = replyUserSnapshot.data!;
                                      String replyText = reply['text'];
                                      bool isLink = Uri.tryParse(replyText)
                                              ?.hasAbsolutePath ??
                                          false;
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                           
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundImage: NetworkImage(
                                                replyUser['profileImage']),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  replyUser['fullName'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                isLink
                                                    ? CaptionWidget(
                                                        caption: replyText,
                                                      )
                                                    : Text(
                                                        replyText,
                                                        style: TextStyle(
                                                            fontSize: 13),
                                                      ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
  }
}