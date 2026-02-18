import 'package:baseliae_flutter/Component/CommentTextfield.dart';
import 'package:baseliae_flutter/Forums/Fatching/ForumsReply.dart';
import 'package:baseliae_flutter/Forums/ForumsController/ForumsComments/ForumsCommentsController.dart';
import 'package:baseliae_flutter/Forums/ForumsController/ForumsLikeController.dart';
import 'package:baseliae_flutter/Forums/Screens/CreatQuestionScreen.dart';
import 'package:baseliae_flutter/Forums/Screens/ForumsProfile.dart';

import 'package:baseliae_flutter/Forums/Screens/ForumsSearchScreen.dart';
import 'package:baseliae_flutter/Forums/Widgets/ExpandableTextwidgets.dart';
import 'package:baseliae_flutter/Forums/Widgets/ForumsCommentsBottomsheet.dart';
import 'package:baseliae_flutter/Forums/Widgets/ReplayCardwidgets.dart';

import 'package:baseliae_flutter/Service/FollowService.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class Forumsdiscussionscreen extends StatefulWidget {
  final DocumentSnapshot forumData;
  const Forumsdiscussionscreen({super.key, required this.forumData});

  @override
  State<Forumsdiscussionscreen> createState() => _ForumsdiscussionscreenState();
}

class _ForumsdiscussionscreenState extends State<Forumsdiscussionscreen> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final FollowService _followService = FollowService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isFriend = false;
  bool isRequested = false;
  late Map<String, dynamic> forumData;
  @override
  void initState() {
    super.initState();
    forumData = Map<String, dynamic>.from(widget.forumData.data() as Map);
    checkFriendStatus();
    initializeLikeStatus();
    initcommentcount();
  }

  Future<void> checkFriendStatus() async {
    if (currentUserId == null) return;

    Map<String, bool> status =
        await _followService.checkFriendStatus(widget.forumData['userId']);

    if (mounted) {
      setState(() {
        isFriend = status['isFriend'] ?? false;
        isRequested = status['isRequested'] ?? false;
      });
    }
  }

  Future<void> sendFollowRequest() async {
    await _followService.sendFollowRequest(widget.forumData['userId']);
    await checkFriendStatus();
  }

  Future<void> cancelFollowRequest() async {
    await _followService.cancelFollowRequest(widget.forumData['userId']);
    await checkFriendStatus();
  }

  final ForumsLikeController likecontroller = Get.put(ForumsLikeController());
  bool isLiked = false;
  int likeCount = 0;

  int commentcount = 0;

  void initcommentcount() {
    setState(() {
      commentcount = widget.forumData['commentcount'] ?? 0;
    });
  }

  void initializeLikeStatus() {
    List<dynamic> likedBy = widget.forumData['likes'] ?? [];
    setState(() {
      isLiked = likedBy.contains(currentUserId);
      likeCount = widget.forumData['likecount'] ?? 0;
    });
  }

  Future<void> toggleLike() async {
    if (currentUserId == null) return;

    setState(() {
      if (isLiked) {
        likeCount = (likeCount > 0) ? likeCount - 1 : 0;
      } else {
        likeCount += 1;
      }
      isLiked = !isLiked;
    });

    await likecontroller.toggleLike(widget.forumData['postId'], currentUserId!);
  }

  final ForumsCommentsController controller =
      Get.put(ForumsCommentsController());
  TextEditingController commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? auth = FirebaseAuth.instance.currentUser;

  // ignore: unused_element
  Future<void> _fetchCommentData(String commentId) async {
    DocumentSnapshot commentSnapshot = await _firestore
        .collection('Forums')
        .doc(widget.forumData['postId'])
        .collection('comments')
        .doc(commentId)
        .get();

    setState(() {});
  }

  Future<void> _toggleLike(String commentId) async {
    String userId = auth!.uid;

    DocumentReference commentRef = FirebaseFirestore.instance
        .collection('Forums')
        .doc(widget.forumData['postId'])
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

  Future<void> _toggleLikeReply(String commentId, String replyId) async {
    String userId = auth!.uid;

    DocumentReference replyRef = FirebaseFirestore.instance
        .collection('Forums')
        .doc(widget.forumData['postId'])
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId);

    DocumentSnapshot snapshot = await replyRef.get();

    if (!snapshot.exists) return;

    final data = snapshot.data() as Map<String, dynamic>;

    Map<String, bool> reactions = {};
    if (data['reactions'] != null && data['reactions'] is Map) {
      reactions = Map<String, bool>.from(data['reactions']);
    }

    int likeCount = data['likeCount'] ?? 0;

    if (reactions[userId] == true) {
      reactions.remove(userId);
      likeCount--;
    } else {
      reactions[userId] = true;
      likeCount++;
    }

    await replyRef.update({
      'reactions': reactions,
      'likeCount': likeCount,
    });

    // No need for setState if you're in a StreamBuilder — it will auto refresh.
  }

  Future<void> _handlePostVote(bool isUpvote) async {
    if (currentUserId == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('Forums')
        .doc(forumData['postId']);

    final snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    Map<String, bool> upvotes = Map<String, bool>.from(data['upvotes'] ?? {});
    Map<String, bool> downvotes =
        Map<String, bool>.from(data['downvotes'] ?? {});

    bool hasUpvoted = upvotes.containsKey(currentUserId);
    bool hasDownvoted = downvotes.containsKey(currentUserId);

    // Remove old votes
    upvotes.remove(currentUserId);
    downvotes.remove(currentUserId);

    // Apply new vote
    if (isUpvote) {
      upvotes[currentUserId!] = true;
    } else {
      downvotes[currentUserId!] = true;
    }

    int voteCount = upvotes.length - downvotes.length;

    await docRef.update({
      'upvotes': upvotes,
      'downvotes': downvotes,
      'voteCount': voteCount,
    });

    // ✅ Update local UI state
    setState(() {
      forumData['upvotes'] = upvotes;
      forumData['downvotes'] = downvotes;
      forumData['voteCount'] = voteCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.forumData['caption'];
    final userId = widget.forumData['userId'];
    final discussion = widget.forumData['description'];
    final imageMedia = List<String>.from(widget.forumData['image_media'] ?? []);
    final videoMedia = List<String>.from(widget.forumData['video_media'] ?? []);
    final hasMedia = imageMedia.isNotEmpty || videoMedia.isNotEmpty;
    final hastext = discussion.isNotEmpty;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: whit,
      appBar: AppBar(
        iconTheme: IconThemeData(color: purpal),
        backgroundColor: Colors.white,
        title: Text(
          "Discussion",
          style: robotostyle(black, 18, FontWeight.w400),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: purpal,
              size: 32,
            ),
            onPressed: () {
              Get.to(() => ForumSearchScreen());
            },
          ),
          IconButton(
            icon: Icon(
              Icons.add_circle,
              color: purpal,
              size: 32,
            ),
            onPressed: () {
              Get.to(() => Creatquestionscreen());
            },
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Commenttextfield(
          controller: commentController,
          onPressed: () async {
            if (commentController.text.isNotEmpty) {
              await controller.addComment(widget.forumData['postId'], auth!.uid,
                  commentController.text);
              commentController.clear();
            }
          },
        ),
      ),
      body: SizedBox(
        child: FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance.collection('Users').doc(userId).get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();

            final userData = snapshot.data!;
            final username = userData['fullName'] ?? 'Unknown';
            final profilePic = userData['profileImage'] ?? '';

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.to(() => Froumsprofile(
                                userId: userId,
                                username: username,
                                userEmail: userData['email'],
                                followingCount: userData['followingCount'] ?? 0,
                                profilePic: profilePic,
                              ));
                        },
                        child: CircleAvatar(
                          backgroundImage: profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : null,
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: robotostyle(black, 16.3, FontWeight.w700),
                            ),
                            Text(
                              // ignore: prefer_interpolation_to_compose_strings
                              _formatCount(userData['followersCount'] ?? 0) +
                                  " Followers",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (FirebaseAuth.instance.currentUser!.uid != userId) ...[
                        if (!isFriend)
                          isRequested
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: cancelFollowRequest,
                                  child: const Text(
                                    "Requested",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: purpal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: sendFollowRequest,
                                  child: const Text(
                                    "+Follow",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                      ],
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.more_vert, color: Colors.grey),
                      ),
                    ],
                  ),

                  ExpandableText(
                    fixedHeight: 50,
                    text: title,
                    trimLines: 2,
                    style: robotostyle(black, 16, FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  if (hastext) ...[
                    ExpandableText(
                      fixedHeight: 100,
                      text: discussion,
                      trimLines: 5,
                      style: robotostyle(semigray, 13, FontWeight.w400),
                    ),
                  ],

                  // if (hasMedia) ...[
                  //   Forumsmedia(
                  //     post: widget.forumData,
                  //   ),
                  // ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formatTimestamp(
                            widget.forumData['timestamp'] ?? Timestamp.now()),
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Upvote Button
                          IconButton(
                            onPressed: () => _handlePostVote(true),
                            icon: Icon(
                              Icons.arrow_upward,
                               weight: 50,
                              size: 40,
                              color: (forumData['upvotes'] as Map?)
                                          ?.containsKey(currentUserId) ==
                                      true
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                          Text(
                            "${(forumData['upvotes'] as Map?)?.length ?? 0}",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                          ),

                          // Downvote Button
                          IconButton(
                            onPressed: () => _handlePostVote(false),
                            icon: Icon(
                              Icons.arrow_downward,
                              weight: 50,
                              size: 40,
                              color: (forumData['downvotes'] as Map?)
                                          ?.containsKey(currentUserId) ==
                                      true
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                          Text(
                            "${(forumData['downvotes'] as Map?)?.length ?? 0}",
                            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(left: 20),
                      //   child: _buildLikeButton(
                      //     toggleLike,
                      //     isLiked,
                      //     likeCount,
                      //   ),
                      // ),
                      // SizedBox(width: 20),
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: _buildMetric(Icons.comment_outlined, commentcount, () {
                          ForumsCommentsBottomsheet(context,
                              widget.forumData['postId'], profilePic ?? '');
                        }),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          controller.fetchComments(widget.forumData['postId']),
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
                                    Get.to(() => Forumsreply(), arguments: {
                                      'postId': widget.forumData['postId'],
                                      'commentId': commentId,
                                      'comment': comment,
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Profile Picture
                                            FutureBuilder<DocumentSnapshot>(
                                              future: FirebaseFirestore.instance
                                                  .collection('Users')
                                                  .doc(comment['userId'])
                                                  .get(),
                                              builder: (context, userSnapshot) {
                                                if (!userSnapshot.hasData ||
                                                    !userSnapshot
                                                        .data!.exists) {
                                                  return const CircleAvatar(
                                                    radius: 25,
                                                    child: Icon(Icons.person),
                                                  );
                                                }

                                                var userData =
                                                    userSnapshot.data!;
                                                return CircleAvatar(
                                                  radius: 25,
                                                  backgroundImage: NetworkImage(
                                                      userData['profileImage']),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 10),

                                            // Right side content
                                            Expanded(
                                              child: FutureBuilder<
                                                  DocumentSnapshot>(
                                                future: FirebaseFirestore
                                                    .instance
                                                    .collection('Users')
                                                    .doc(comment['userId'])
                                                    .get(),
                                                builder:
                                                    (context, userSnapshot) {
                                                  if (!userSnapshot.hasData ||
                                                      !userSnapshot
                                                          .data!.exists) {
                                                    return const Text(
                                                        "Unknown User");
                                                  }

                                                  var userData = userSnapshot
                                                          .data!
                                                          .data()
                                                      as Map<String, dynamic>;

                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Name and timestamp
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              userData[
                                                                  'fullName'],
                                                              style: robotostyle(
                                                                  Colors.black,
                                                                  14.66,
                                                                  FontWeight
                                                                      .w700),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 6),
                                                          Text(
                                                            formatTimestamp(
                                                                comment['timestamp'] ??
                                                                    Timestamp
                                                                        .now()),
                                                            style: robotostyle(
                                                                Colors.grey,
                                                                9.77,
                                                                FontWeight
                                                                    .w700),
                                                          ),
                                                        ],
                                                      ),

                                                      const SizedBox(height: 6),

                                                      // Comment text
                                                      Text(
                                                        comment['text'],
                                                        style: robotostyle(
                                                            Colors.black,
                                                            12.58,
                                                            FontWeight.w600),
                                                      ),

                                                      // Action buttons
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            onPressed: () =>
                                                                _toggleLike(
                                                                    commentId),
                                                            icon: Icon(
                                                              comment['reactions']
                                                                      .containsKey(
                                                                          auth!
                                                                              .uid)
                                                                  ? Icons
                                                                      .favorite
                                                                  : Icons
                                                                      .favorite_border,
                                                              color: comment[
                                                                          'reactions']
                                                                      .containsKey(
                                                                          auth!
                                                                              .uid)
                                                                  ? Colors.red
                                                                  : Colors.grey,
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              Get.to(
                                                                  () =>
                                                                      Forumsreply(),
                                                                  arguments: {
                                                                    'postId': widget
                                                                            .forumData[
                                                                        'postId'],
                                                                    'commentId':
                                                                        commentId,
                                                                    'comment':
                                                                        comment,
                                                                  });
                                                            },
                                                            icon: const Icon(
                                                                Icons.reply,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          const Text("Replies"),
                                                          const Spacer(),
                                                          IconButton(
                                                            onPressed: () {},
                                                            icon: const Icon(
                                                                Icons
                                                                    .more_horiz,
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ],
                                                      ),

                                                      // Replies Section
                                                      StreamBuilder<
                                                          QuerySnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Forums')
                                                            .doc(widget
                                                                    .forumData[
                                                                'postId'])
                                                            .collection(
                                                                'comments')
                                                            .doc(commentId)
                                                            .collection(
                                                                'replies')
                                                            .orderBy(
                                                                'timestamp',
                                                                descending:
                                                                    false)
                                                            .snapshots(),
                                                        builder: (context,
                                                            replySnapshot) {
                                                          if (!replySnapshot
                                                                  .hasData ||
                                                              replySnapshot
                                                                  .data!
                                                                  .docs
                                                                  .isEmpty) {
                                                            return const SizedBox();
                                                          }

                                                          var replies =
                                                              replySnapshot
                                                                  .data!.docs;

                                                          return ListView
                                                              .builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                replies.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              var replyDoc =
                                                                  replies[
                                                                      index];
                                                              if (!replyDoc
                                                                  .exists) {
                                                                return const SizedBox();
                                                              }

                                                              var reply = replyDoc
                                                                      .data()
                                                                  as Map<String,
                                                                      dynamic>;
                                                              var userId =
                                                                  reply[
                                                                      'userId'];

                                                              return FutureBuilder<
                                                                  DocumentSnapshot>(
                                                                future: FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'Users')
                                                                    .doc(userId)
                                                                    .get(),
                                                                builder: (context,
                                                                    userSnapshot) {
                                                                  if (!userSnapshot
                                                                          .hasData ||
                                                                      !userSnapshot
                                                                          .data!
                                                                          .exists) {
                                                                    return const SizedBox();
                                                                  }

                                                                  var replyUser = userSnapshot
                                                                          .data!
                                                                          .data()
                                                                      as Map<
                                                                          String,
                                                                          dynamic>;

                                                                  final isLiked = (reply['reactions'] != null &&
                                                                          reply['reactions']
                                                                              is Map &&
                                                                          reply['reactions']
                                                                              .containsKey(auth!.uid))
                                                                      ? true
                                                                      : false;

                                                                  return ReplyCard(
                                                                    profileImage:
                                                                        replyUser[
                                                                            'profileImage'],
                                                                    fullName:
                                                                        replyUser[
                                                                            'fullName'],
                                                                    text: reply[
                                                                        'text'],
                                                                    timestamp: formatTimestamp(reply[
                                                                            'timestamp'] ??
                                                                        Timestamp
                                                                            .now()),
                                                                    isLiked:
                                                                        isLiked,
                                                                    onPressed: () => _toggleLikeReply(
                                                                        commentId,
                                                                        replyDoc
                                                                            .id),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Divider at the end
                                        const Padding(
                                          padding: EdgeInsets.only(top: 10),
                                          child: Divider(thickness: 1.2),
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
            );
          },
        ),
      ),
    );
  }
}

// ignore: unused_element
Widget _buildLikeButton(dynamic toggleLike, bool isLiked, int likeCount) {
  return Row(
    children: [
      GestureDetector(
        onTap: toggleLike,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          size: 25,
          color: isLiked ? Colors.red : purpal,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        _formatCount(likeCount),
        style: TextStyle(fontSize: 16, color: black),
      ),
    ],
  );
}

Widget _buildMetric(IconData icon, int count, VoidCallback onTap) {
  return Row(
    children: [
      GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 25, color: purpal),
      ),
      SizedBox(width: 4),
      Text(
        _formatCount(count),
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}

String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

String formatTimestamp(Timestamp timestamp) {
  return timeago.format(timestamp.toDate());
}
