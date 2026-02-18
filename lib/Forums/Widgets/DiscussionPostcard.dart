import 'package:baseliae_flutter/Controller/PostController/LikeController.dart';

import 'package:baseliae_flutter/Forums/ForumsController/DiscussionUploadingController.dart';
import 'package:baseliae_flutter/Screens/Profile/FriendsProfle.dart/DisplayFirendsProfile.dart';

import 'package:baseliae_flutter/Service/FollowService.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/MediaCarouselWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class Discussionpostcard extends StatefulWidget {
  final DocumentSnapshot forumData;
  const Discussionpostcard({super.key, required this.forumData});
  @override
  State<Discussionpostcard> createState() => _DiscussionpostcardState();
}

class _DiscussionpostcardState extends State<Discussionpostcard> {
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
    // initcommentcount();
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

  final Likecontroller likecontroller = Get.put(Likecontroller());
  bool isLiked = false;
  int likeCount = 0;

  int commentcount = 0;

  // void initcommentcount() {
  //   setState(() {
  //     commentcount = widget.forumData['commentcount'] ?? 0;
  //   });
  // }

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

  final DiscussionUploadingController postUploadingController =
      Get.put(DiscussionUploadingController());
  @override
  Widget build(BuildContext context) {
    final postText = widget.forumData['caption']?.toString().trim() ?? '';
    final imageMedia = List<String>.from(widget.forumData['image_media'] ?? []);
    final videoMedia = List<String>.from(widget.forumData['video_media'] ?? []);
    final hasMedia = imageMedia.isNotEmpty || videoMedia.isNotEmpty;
    final hasText = postText.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => Displayfirendsprofile(
                      FrienduId: widget.forumData['userId']));
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.forumData['isShared'] ?? false
                        ? widget.forumData['sharedByPhoto'] ?? ''
                        : widget.forumData['userProfileImage'] ?? '',
                  ),
                  radius: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => Displayfirendsprofile(
                            FrienduId: widget.forumData['userId']));
                      },
                      child: Row(
                        children: [
                          Text(
                            widget.forumData['isShared'] ?? false
                                ? widget.forumData['sharedByName'] ?? ''
                                : widget.forumData['userName'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (widget.forumData['accountType'] ==
                              'Celebrities / VIPs')
                            Image.asset(
                              'assets/images/verifiyed.png',
                              height: 16,
                            ),
                        ],
                      ),
                    ),
                    if (widget.forumData['isShared'] ?? false)
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Shared post from ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            TextSpan(
                              text:
                                  widget.forumData['originalPosterName'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.forumData['followersCount'] ?? 0} Followers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
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
              IconButton(
                onPressed: () {
                  final String postId = widget
                      .forumData['postId']; // Pass your actual post ID here
                  final String link = "https://yourapp.com/post?id=$postId";

                  // Copy to clipboard
                  Clipboard.setData(ClipboardData(text: link));

                  // Share the link
                  Share.share(link);
                },
                icon: const Icon(Icons.more_vert, color: Colors.grey),
              )
            ],
          ),
          const SizedBox(height: 12),

// Show shared post original content
          if (widget.forumData['isShared'] ?? false)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                            widget.forumData['originalPosterPhoto'] ?? ''),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.forumData['originalPosterName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.forumData['caption'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (((widget.forumData['image_media'] ?? []) as List)
                          .isNotEmpty ||
                      ((widget.forumData['video_media'] ?? []) as List)
                          .isNotEmpty)
                    MediaCarousel(
                        post: widget.forumData as Map<String,
                            dynamic>), // Your media carousel widget
                ],
              ),
            ),
          const SizedBox(height: 12),
          if (!(widget.forumData['isShared'] ?? false)) ...[
            if (hasMedia) ...[
              MediaCarousel(post: widget.forumData as Map<String, dynamic>),
            ],
            if (hasText) ...[
              Text(
                postText,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatTimestamp(widget.forumData['timestamp'] ?? Timestamp.now()),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: _buildLikeButton(),
              ),
              const SizedBox(width: 20),
              // _buildMetric(Icons.comment, commentcount, () {
              //   showCommentsBottomSheet(context, widget.forumData['postId'],
              //       widget.forumData['userProfileImage'] ?? '');
              // }),
              const SizedBox(width: 20),
              _buildMetric(
                  Icons.open_in_new, widget.forumData['sharedCount'] ?? 0, () {
                postUploadingController
                    .sharePost(widget.forumData as Map<String, dynamic>);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return Row(
      children: [
        GestureDetector(
          onTap: toggleLike,
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 35,
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
          child: Icon(icon, size: 30, color: purpal),
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
}
