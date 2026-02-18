// ignore_for_file: unused_field

import 'package:baseliae_flutter/Screens/Story/Storyinshight.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:story_view/story_view.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<DocumentSnapshot> stories;
  final int startIndex;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.startIndex = 0,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  final StoryController _storyController = StoryController();
  final currentUser = FirebaseAuth.instance.currentUser;

  int _currentStoryIndex = 0;
  String? _reaction;

  @override
  void initState() {
    super.initState();
    _currentStoryIndex = widget.startIndex;
    _markAsViewed(widget.stories[_currentStoryIndex].id);
  }

  void _markAsViewed(String storyId) async {
    final uid = currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('stories')
          .doc(storyId)
          .update({
        'views': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void _sendReaction(String storyId, String emoji) async {
    setState(() {
      _reaction = emoji;
    });

    await FirebaseFirestore.instance.collection('stories').doc(storyId).set({
      'reactions': {currentUser!.uid: emoji}
    }, SetOptions(merge: true));

    _showReactionConfirmation(emoji);
  }

  void _showReactionConfirmation(String emoji) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: MediaQuery.of(context).size.width / 2 - 60,
        child: _ReactionToast(emoji: emoji),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  List<StoryItem> _buildStoryItems(DocumentSnapshot storyDoc) {
    final List<StoryItem> storyItems = [];
    final images = List<String>.from(storyDoc['image_media'] ?? []);
    final videos = List<String>.from(storyDoc['video_media'] ?? []);

    for (final url in images) {
      storyItems.add(StoryItem.pageImage(
        url: url,
        controller: _storyController,
        imageFit: BoxFit.cover,
        duration: const Duration(seconds: 5),
      ));
    }

    for (final videoUrl in videos) {
      storyItems.add(StoryItem.pageVideo(
        videoUrl,
        controller: _storyController,
        duration: const Duration(seconds: 10), // can be adjusted
      ));
    }

    return storyItems;
  }

  void _goToNextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
      });
      _storyController.play();
      _markAsViewed(widget.stories[_currentStoryIndex].id);
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
      });
      _storyController.play();
      _markAsViewed(widget.stories[_currentStoryIndex].id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStory = widget.stories[_currentStoryIndex];
    final storyItems = _buildStoryItems(currentStory);
    final isOwner = currentStory['userId'] == currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          final dx = details.globalPosition.dx;

          if (dx < width / 3) {
            _goToPreviousStory();
          } else {
            _goToNextStory();
          }
        },
        child: Stack(
          children: [
            StoryView(
              storyItems: storyItems,
              controller: _storyController,
              indicatorColor: purpal,
              onStoryShow: (storyItem, index) {
                _storyController.play();
              },
              onComplete: () {
                _goToNextStory();
              },
              repeat: false,
            ),
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundImage:
                            NetworkImage(currentStory['userProfileImage']),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        currentStory['userName'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          // shadows: [
                          //   Shadow(color: Colors.black87, blurRadius: 4)
                          // ],
                        ),
                      ),
                    ],
                  ),
                  // if (isOwner)
                  //   IconButton(
                  //     icon: const Icon(Icons.insights, color: Colors.black),
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (_) =>
                  //               StoryInsightsScreen(storyId: currentStory.id),
                  //         ),
                  //       );
                  //     },
                  //   )

                  if (isOwner)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.insights,
                            color: Colors.deepPurple),
                        tooltip: "View Insights",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StoryInsightsScreen(storyId: currentStory.id),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildEmojiButton("❤️"),
                        _buildEmojiButton("😂"),
                        _buildEmojiButton("😮"),
                        _buildEmojiButton("👍"),
                        _buildEmojiButton("👎"),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiButton(String emoji) {
    final currentStory = widget.stories[_currentStoryIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _sendReaction(currentStory.id, emoji),
          splashColor: Colors.grey.withOpacity(0.3),
          highlightColor: Colors.grey.withOpacity(0.15),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReactionToast extends StatelessWidget {
  final String emoji;

  const _ReactionToast({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade900.withOpacity(0.85),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reaction sent',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
