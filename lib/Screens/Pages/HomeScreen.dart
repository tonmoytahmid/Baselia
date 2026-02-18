import 'package:baseliae_flutter/Component/HomeScreenAppbar.dart';
import 'package:baseliae_flutter/Controller/PostController/FatchingPostController.dart';
import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
import 'package:baseliae_flutter/Fatching/PostFatching/FatchingPost.dart';
import 'package:baseliae_flutter/Screens/Story/CreatStoryScreen.dart';
import 'package:baseliae_flutter/Screens/Story/StoryviewScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => HomescreenState();
}

class HomescreenState extends State<Homescreen> {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final Relationshipcontroller relationshipController =
      Get.put(Relationshipcontroller());
  final FetchingPostController fetchingPostController =
      Get.put(FetchingPostController());
  final ScrollController _scrollController = ScrollController();

  final GlobalKey<HomescreenState> homeScreenKey = GlobalKey<HomescreenState>();

// Pass it to your Homescreen

  void scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> sendFollowRequest(String senderId, String receiverId) async {
    var existingRequest = await FirebaseFirestore.instance
        .collection("follow_requests")
        .where("senderId", isEqualTo: senderId)
        .where("receiverId", isEqualTo: receiverId)
        .where("status", isEqualTo: "pending")
        .get();

    if (existingRequest.docs.isEmpty) {
      await FirebaseFirestore.instance.collection("follow_requests").add({
        "senderId": senderId,
        "receiverId": receiverId,
        "status": "pending",
        "timestamp": FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whit,
        appBar: HomeScreenAppbar(
          context,
        ),
        body: Column(
          children: [
            buildStoryBar(),
            Fatchingpost(scrollController: _scrollController),
          ],
        ));
  }
}

Widget buildStoryBar() {
  final currentUser = FirebaseAuth.instance.currentUser;
  final currentUserId = currentUser?.uid;

  return SizedBox(
    height: 100,
    child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('stories')
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final allStories = snapshot.data!.docs;

        // Group stories by userId
        final Map<String, List<DocumentSnapshot>> storiesByUser = {};
        for (var story in allStories) {
          final userId = story['userId'] as String;
          if (!storiesByUser.containsKey(userId)) {
            storiesByUser[userId] = [];
          }
          storiesByUser[userId]!.add(story);
        }

        final userIds = storiesByUser.keys.toList();

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: userIds.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return GestureDetector(
                onTap: () {
                  Get.to(() => StoryUploadScreen());
                },
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.add, size: 28, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    const Text("Your Story", style: TextStyle(fontSize: 12)),
                  ],
                ),
              );
            }

            final userId = userIds[index - 1];
            final userStories = storiesByUser[userId]!;

            // Use data from first story as representative for user profile/name
            final firstStory = userStories[0];
            final userProfile = firstStory['userProfileImage'];
            final userName = firstStory['userName'];

            // Check if current user has seen all stories from this user (optional)
            // Here, if current user has viewed all of this user's stories, mark as seen
            bool isSeen = true;
            for (var s in userStories) {
              final List views = s['views'] ?? [];
              if (!views.contains(currentUserId)) {
                isSeen = false;
                break;
              }
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoryViewerScreen(
                      stories: userStories,
                      startIndex: 0,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSeen ? Colors.grey[300] : Colors.blue,
                    child: CircleAvatar(
                      radius: 27,
                      backgroundImage: NetworkImage(userProfile),
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 60,
                    child: Text(
                      userName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSeen ? FontWeight.normal : FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

// Widget buildStoryBar() {
//   final currentUser = FirebaseAuth.instance.currentUser;
//   final currentUserId = currentUser?.uid;

//   return SizedBox(
//     height: 100,
//     child: StreamBuilder<QuerySnapshot>(
//       stream: FirebaseFirestore.instance
//           .collection('stories')
//           .where('expiresAt', isGreaterThan: Timestamp.now())
//           // .orderBy('createdAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData)
//           return const Center(child: CircularProgressIndicator());

//         final stories = snapshot.data!.docs;

//         return ListView.separated(
//           scrollDirection: Axis.horizontal,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           itemCount: stories.length + 1,
//           separatorBuilder: (_, __) => const SizedBox(width: 10),
//           itemBuilder: (context, index) {
//             // 👉 "Your Story" button
//             if (index == 0) {
//               return GestureDetector(
//                 onTap: () {
//                   // Navigate to story upload page
//                   Get.toNamed('/uploadStory'); // or use Navigator
//                 },
//                 child: Column(
//                   children: [
//                     const CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.grey,
//                       child: Icon(Icons.add, size: 28, color: Colors.white),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text("Your Story", style: TextStyle(fontSize: 12)),
//                   ],
//                 ),
//               );
//             }

//             final story = stories[index - 1];
//             final userProfile = story['userProfileImage'];
//             final userName = story['userName'];
//             final List views = story['views'] ?? [];
//             final isSeen = views.contains(currentUserId);

//             return GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => StoryViewerScreen(
//                       stories: stories,
//                       startIndex: index - 1,
//                     ),
//                   ),
//                 );
//               },
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: isSeen ? Colors.grey[300] : Colors.blue,
//                     child: CircleAvatar(
//                       radius: 27,
//                       backgroundImage: NetworkImage(userProfile),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   SizedBox(
//                     width: 60,
//                     child: Text(
//                       userName,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight:
//                             isSeen ? FontWeight.normal : FontWeight.bold,
//                       ),
//                       overflow: TextOverflow.ellipsis,
//                       textAlign: TextAlign.center,
//                     ),
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     ),
//   );
// }
