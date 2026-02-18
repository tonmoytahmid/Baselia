import 'package:baseliae_flutter/Forums/ForumsController/ForumsLikeController.dart';
import 'package:baseliae_flutter/Forums/Screens/ForumsDiscussionScreen.dart';
import 'package:baseliae_flutter/Forums/Widgets/ForumsCommentsBottomsheet.dart';
import 'package:baseliae_flutter/Service/FollowService.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumPostCard extends StatefulWidget {
  final DocumentSnapshot forumData;
  const ForumPostCard({super.key, required this.forumData});

  @override
  State<ForumPostCard> createState() => _ForumPostCardState();
}

class _ForumPostCardState extends State<ForumPostCard> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final FollowService _followService = FollowService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isFriend = false;
  bool isRequested = false;
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final title = widget.forumData['caption'];
    final userId = widget.forumData['userId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final userData = snapshot.data!;
        final username = userData['fullName'] ?? 'Unknown';
        final profilePic = userData['profileImage'] ?? '';

        return GestureDetector(
          onTap: () {
            Get.to(() => Forumsdiscussionscreen(
                  forumData: widget.forumData,
                ));
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              decoration: BoxDecoration(
                color: whit,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: profilePic.isNotEmpty
                              ? NetworkImage(profilePic)
                              : null,
                          backgroundColor: Colors.grey.shade300,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: robotostyle(black, 14, FontWeight.w700),
                              ),
                              Text(
                                formatTimestamp(widget.forumData['timestamp'] ??
                                    Timestamp.now()),
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.more_horiz, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(title, style: robotostyle(black, 12, FontWeight.w700)),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: _buildLikeButton(
                            toggleLike,
                            isLiked,
                            likeCount,
                          ),
                        ),
                        SizedBox(width: 20),
                        _buildMetric(Icons.comment_outlined, commentcount, () {
                          ForumsCommentsBottomsheet(context,
                              widget.forumData['postId'], profilePic ?? '');
                        }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
