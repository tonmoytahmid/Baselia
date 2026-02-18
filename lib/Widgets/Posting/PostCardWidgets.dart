import 'package:baseliae_flutter/Component/ShowDailougebox.dart';
import 'package:baseliae_flutter/Controller/PostController/FatchingPostController.dart';
import 'package:baseliae_flutter/Controller/PostController/LikeController.dart';
import 'package:baseliae_flutter/Controller/PostController/PostUploadingController.dart';
import 'package:baseliae_flutter/Fatching/Comments/CommentBottomsheet.dart';
import 'package:baseliae_flutter/Screens/Profile/ChurchpageProfile/ChurchviewProfile.dart';
import 'package:baseliae_flutter/Screens/Profile/FriendsProfle.dart/DisplayFirendsProfile.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/ProfileScreen.dart';

import 'package:baseliae_flutter/Service/FollowService.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/CaptionWidgets.dart';
import 'package:baseliae_flutter/Widgets/Posting/MediaCarouselWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  const PostCard({super.key, required this.post});
  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final FollowService _followService = FollowService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool isFriend = false;
  bool isRequested = false;

  final PostUploadingController postUploadingController =
      Get.put(PostUploadingController());

  final FetchingPostController fatchingpostcontroller =
      Get.find<FetchingPostController>();

  String? displayName;
  String? displayImage;
  bool isChurchPost = false;

  @override
  void initState() {
    super.initState();
    checkFriendStatus();
    initializeLikeStatus();
    initcommentcount();

    isChurchPost = widget.post['isChurchPagePost'] ?? false;

    if (isChurchPost) {
      final String pageId = widget.post['churchPageId'] ?? '';
      fetchChurchPageData(pageId);
    } else {
      setState(() {
        displayName = widget.post['isShared'] ?? false
            ? widget.post['sharedByName']
            : widget.post['userName'];
        displayImage = widget.post['isShared'] ?? false
            ? widget.post['sharedByPhoto']
            : widget.post['userProfileImage'];
      });
    }
  }

  Future<void> fetchChurchPageData(String churchPageId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('ChurchPages')
          .doc(churchPageId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          displayName = data?['churchName'] ?? 'Church Page';
          displayImage = data?['profileImage'] ??
              'https://cdn-icons-png.flaticon.com/512/847/847969.png';
        });
      }
    } catch (e) {
      print("Failed to fetch church page info: $e");
    }
  }

  Future<void> checkFriendStatus() async {
    if (currentUserId == null) return;

    Map<String, bool> status =
        await _followService.checkFriendStatus(widget.post['userId']);

    if (mounted) {
      setState(() {
        isFriend = status['isFriend'] ?? false;
        isRequested = status['isRequested'] ?? false;
      });
    }
  }

  Future<void> sendFollowRequest() async {
    await _followService.sendFollowRequest(widget.post['userId']);
    await checkFriendStatus();
  }

  Future<void> cancelFollowRequest() async {
    await _followService.cancelFollowRequest(widget.post['userId']);
    await checkFriendStatus();
  }

  final Likecontroller likecontroller = Get.put(Likecontroller());
  bool isLiked = false;
  int likeCount = 0;

  int commentcount = 0;

  void initcommentcount() {
    setState(() {
      commentcount = widget.post['commentcount'] ?? 0;
    });
  }

  void initializeLikeStatus() {
    List<dynamic> likedBy = widget.post['likes'] ?? [];
    setState(() {
      isLiked = likedBy.contains(currentUserId);
      likeCount = widget.post['likecount'] ?? 0;
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

    await likecontroller.toggleLike(widget.post['postId'], currentUserId!);
  }

  Future<void> deletePost(String postId) async {
    try {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);
      final postSnap = await postRef.get();

      if (!postSnap.exists) {
        Get.snackbar("Error", "Post not found.",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final postData = postSnap.data()!;
      final String? postType = postData['post_type'];
      final List imageMedia = postData['image_media'] ?? [];
      final String? userId = postData['userId'];

      // Delete the post
      await postRef.delete();

      // Update user's post count
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'postCount': FieldValue.increment(-1)});

      // Remove the post from UI immediately
      fatchingpostcontroller.posts
          .removeWhere((post) => post['postId'] == postId);

      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      final userSnap = await userRef.get();

      if (userSnap.exists && imageMedia.isNotEmpty) {
        final userData = userSnap.data()!;
        final String imageUrl = imageMedia[0];

        if (postType == 'profile_image_update' &&
            userData['profileImage'] == imageUrl) {
          await userRef.update({
            'profileImage':
                "https://cdn-icons-png.flaticon.com/512/847/847969.png",
          });
          print("Profile image reset to default.");
        }

        if (postType == 'cover_image_update' &&
            userData['coverImage'] == imageUrl) {
          await userRef.update({
            'coverImage':
                "https://cdn-icons-png.flaticon.com/512/847/847969.png",
          });
          print("Cover image reset to default.");
        }
      }

      Get.snackbar(
        "Success",
        "Post deleted successfully.",
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete post: $e",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final postText = widget.post['caption']?.toString().trim() ?? '';
    final imageMedia = List<String>.from(widget.post['image_media'] ?? []);
    final videoMedia = List<String>.from(widget.post['video_media'] ?? []);
    final hasMedia = imageMedia.isNotEmpty || videoMedia.isNotEmpty;
    final hasText = postText.isNotEmpty;
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  final String postOwnerId = widget.post['userId'] ?? '';
                  final String currentUserId =
                      FirebaseAuth.instance.currentUser?.uid ?? '';

                  final String accountType = widget.post['accountType'] ?? '';

                  if (accountType == 'church_page') {
                    Get.to(() => Churchviewprofile(), arguments: {
                      'churchName': widget.post['userName'] ?? '',
                      'profileImage': widget.post['userProfileImage'] ?? '',
                      'coverImage': widget.post['coverImage'] ?? '',
                      'ownersName': widget.post['ownersname'] ?? '',
                      'churchLocation': widget.post['location'] ?? '',
                      'churchPageId': widget.post['friendUid'] ?? '',
                      'followerscount': widget.post['followersCount'] ?? 0,
                      'followingcount': widget.post['followingCount'] ?? 0,
                      'postcount': widget.post['postCount'] ?? 0,
                      'about': widget.post['about'] ?? '',
                    });
                  } else {
                    if (postOwnerId == currentUserId) {
                      Get.to(() => Profilescreen(), arguments: {
                        'fullname': widget.post['userName'],
                        'bio': widget.post['bio'],
                        'profilepic': widget.post['userProfileImage'],
                        'coverpic': widget.post['coverImage'],
                        'uid': widget.post['friendUid'],
                        'location': widget.post['location'],
                        'followerscount': widget.post['followersCount'],
                        'followingcount': widget.post['followingCount'],
                        'postcount': widget.post['postCount'],
                        'about': widget.post['about'],
                        'accountType': widget.post['accountType'],
                      });
                    } else {
                      Get.to(
                          () => Displayfirendsprofile(FrienduId: postOwnerId));
                    }
                  }
                },
                child: CircleAvatar(
                  backgroundImage: NetworkImage(displayImage ?? ''),

                  // backgroundImage: NetworkImage(
                  //   widget.post['isShared'] ?? false
                  //       ? widget.post['sharedByPhoto'] ?? ''
                  //       : widget.post['userProfileImage'] ?? '',
                  // ),
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
                        final String postOwnerId = widget.post['userId'] ?? '';
                        final String currentUserId =
                            FirebaseAuth.instance.currentUser?.uid ?? '';

                        final String accountType =
                            widget.post['accountType'] ?? '';

                        if (accountType == 'church_page') {
                          Get.to(() => Churchviewprofile(), arguments: {
                            'churchName': widget.post['userName'] ?? '',
                            'profileImage':
                                widget.post['userProfileImage'] ?? '',
                            'coverImage': widget.post['coverImage'] ?? '',
                            'ownersName': widget.post['ownersname'] ?? '',
                            'churchLocation': widget.post['location'] ?? '',
                            'churchPageId': widget.post['friendUid'] ?? '',
                            'followerscount':
                                widget.post['followersCount'] ?? 0,
                            'followingcount':
                                widget.post['followingCount'] ?? 0,
                            'postcount': widget.post['postCount'] ?? 0,
                            'about': widget.post['about'] ?? '',
                          });
                        } else {
                          if (postOwnerId == currentUserId) {
                            Get.to(() => Profilescreen(), arguments: {
                              'fullname': widget.post['userName'],
                              'bio': widget.post['bio'],
                              'profilepic': widget.post['userProfileImage'],
                              'coverpic': widget.post['coverImage'],
                              'uid': widget.post['friendUid'],
                              'location': widget.post['location'],
                              'followerscount': widget.post['followersCount'],
                              'followingcount': widget.post['followingCount'],
                              'postcount': widget.post['postCount'],
                              'about': widget.post['about'],
                              'accountType': widget.post['accountType'],
                            });
                          } else {
                            Get.to(() =>
                                Displayfirendsprofile(FrienduId: postOwnerId));
                          }
                        }
                        // Get.to(() => Displayfirendsprofile(
                        //     FrienduId: widget.post['userId']));
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  displayName ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                // Text(
                                //   maxLines: 1,
                                //   overflow: TextOverflow.ellipsis,
                                //   widget.post['isShared'] ?? false
                                //       ? widget.post['sharedByName'] ?? ''
                                //       : widget.post['userName'] ?? '',
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //     fontSize: 16,
                                //   ),
                                // ),
                              ),
                              const SizedBox(width: 4),
                              if (widget.post['accountType'] ==
                                  'Celebrities / VIPs')
                                Image.asset(
                                  'assets/images/CelebrityUserbage.png',
                                  height: 20,
                                ),
                              if (widget.post['accountType'] == 'Church Leader')
                                Image.asset(
                                  'assets/images/Chargeleaderbage.png',
                                  height: 20,
                                ),
                            ],
                          ),
                          if (widget.post['post_type'] ==
                                  'profile_image_update' ||
                              widget.post['post_type'] == 'cover_image_update')
                            Text(
                              widget.post['post_type'] == 'profile_image_update'
                                  ? 'Updated Profile Picture'
                                  : 'Updated Cover Picture',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.post['isShared'] ?? false)
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
                              text: widget.post['originalPosterName'] ?? '',
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
                      '${widget.post['followersCount'] ?? 0} Followers',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (currentUserId != widget.post['userId']) ...[
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
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                ),
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    final String postId = widget.post['postId'];
                    final String link = "https://yourapp.com/post?id=$postId";

                    if (value == 'share_profile') {
                      postUploadingController.sharePost(widget.post);
                    } else if (value == 'share_others') {
                      Clipboard.setData(ClipboardData(text: link));
                      Share.share(link);
                    } else if (value == 'edit_post') {
                      // TODO: Navigate to edit post screen
                    } else if (value == 'delete_post') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Post'),
                          content: const Text(
                              'Are you sure you want to delete this post?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                deletePost(postId);
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (BuildContext context) {
                    final currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    final postOwnerId = widget.post[
                        'userId']; // Assuming this is where the post owner ID is stored

                    if (currentUserId == postOwnerId) {
                      // If current user is the post owner
                      return [
                        const PopupMenuItem<String>(
                          value: 'edit_post',
                          child: Text('Edit Post'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete_post',
                          child: Text('Delete Post'),
                        ),
                      ];
                    } else {
                      // If current user is not the post owner
                      return [
                        const PopupMenuItem<String>(
                          value: 'share_profile',
                          child: Text('Share in your profile'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'share_others',
                          child: Text('Share to others'),
                        ),
                      ];
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.post['isShared'] ?? false)
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
                            widget.post['originalPosterPhoto'] ?? ''),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.post['originalPosterName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CaptionWidget(
                    caption: widget.post['caption'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  if (((widget.post['image_media'] ?? []) as List).isNotEmpty ||
                      ((widget.post['video_media'] ?? []) as List).isNotEmpty)
                    MediaCarousel(post: widget.post),
                ],
              ),
            ),
          const SizedBox(height: 12),
          if (!(widget.post['isShared'] ?? false)) ...[
            if (hasMedia) ...[
              MediaCarousel(post: widget.post),
            ],
            const SizedBox(height: 12),
            if (hasText) ...[
              CaptionWidget(caption: postText),
              const SizedBox(height: 12),
            ],
          ],
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formatTimestamp(widget.post['timestamp'] ?? Timestamp.now()),
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
              _buildMetric(Icons.comment, commentcount, () {
                showCommentsBottomSheet(context, widget.post['postId'],
                    widget.post['userProfileImage'] ?? '');
              }),
              const SizedBox(width: 20),
              _buildMetric(Icons.open_in_new, widget.post['sharedCount'] ?? 0,
                  () {
                showCustomDialog(context, () {
                  Navigator.of(context).pop();
                  postUploadingController.sharePost(widget.post);
                });
              }),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
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
}
