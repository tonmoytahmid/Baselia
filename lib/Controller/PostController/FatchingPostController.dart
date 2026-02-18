import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FetchingPostController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int pageSize = 10;
  DocumentSnapshot? lastDocument;
  RxBool isFetching = false.obs;
  RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;

  /// Initial fetch
  Future<void> fetchInitialPosts() async {
    if (isFetching.value) return;
    isFetching.value = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      List<Map<String, dynamic>> newPosts = await _fetchUserData(snapshot.docs);
      posts.assignAll(newPosts);
    } catch (e) {
      print("Error fetching posts: $e");
    } finally {
      isFetching.value = false;
    }
  }

  /// Load more
  Future<void> fetchMorePosts() async {
    if (isFetching.value || lastDocument == null) return;
    isFetching.value = true;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(pageSize)
          .get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      List<Map<String, dynamic>> newPosts = await _fetchUserData(snapshot.docs);
      posts.addAll(newPosts);
    } catch (e) {
      print("Error fetching more posts: $e");
    } finally {
      isFetching.value = false;
    }
  }

  /// 🛠️ Fetch user or page data for each post
  Future<List<Map<String, dynamic>>> _fetchUserData(
      List<QueryDocumentSnapshot> docs) async {
    List<Map<String, dynamic>> postsList = [];

    for (var doc in docs) {
      Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
      post['postId'] = doc.id;

      String userId = post['userId'];
      String postType = post['post_type'] ?? 'user_post';

      try {
        DocumentSnapshot userSnapshot;

        // 🔀 If post is from a page
        if (postType == 'page_post') {
          userSnapshot =
              await _firestore.collection('ChurchPages').doc(userId).get();

          if (userSnapshot.exists) {
            Map<String, dynamic> page =
                userSnapshot.data() as Map<String, dynamic>;
            post['userName'] = page['churchName'] ?? 'Unknown Page';
            post['userProfileImage'] = page['profileImage'] ?? '';
            post['accountType'] = 'church_page';
            post['bio'] = page['bio'] ?? '';
            post['location'] = page['churchLocation'] ?? '';
            post['about'] = page['about'] ?? '';
            post['coverImage'] = page['coverImage'] ?? '';
            post['followersCount'] = page['followersCount'] ?? 0;
            post['followingCount'] = 0;
            post['postCount'] = page['postCount'] ?? 0;
            post['friendUid'] = userId;
          } else {
            post['userName'] = "Unknown Page";
            post['userProfileImage'] = "";
          }
        } else {
          // 👤 Normal user post
          userSnapshot = await _firestore.collection('Users').doc(userId).get();

          if (userSnapshot.exists) {
            Map<String, dynamic> user =
                userSnapshot.data() as Map<String, dynamic>;

            post['userName'] = user['fullName'] ?? 'Unknown';
            post['userProfileImage'] = user['profileImage'] ?? '';
            post['followersCount'] = user['followersCount'] ?? 0;
            post['friendUid'] = user['uid'] ?? userId;
            post['accountType'] = user['accountType'] ?? 'user';
            post['bio'] = user['bio'] ?? '';
            post['location'] = user['location'] ?? '';
            post['about'] = user['about'] ?? '';
            post['coverImage'] = user['coverImage'] ?? '';
            post['followingCount'] = user['followingCount'] ?? 0;
            post['postCount'] = user['postCount'] ?? 0;
          } else {
            post['userName'] = "Unknown User";
            post['userProfileImage'] = "";
          }
        }
      } catch (e) {
        print("❌ Error fetching profile: $e");
        post['userName'] = "Unknown";
        post['userProfileImage'] = "";
        post['followersCount'] = 0;
      }

      postsList.add(post);
    }

    return postsList;
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';

// class FetchingPostController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final int pageSize = 10; // Load 10 posts per page
//   DocumentSnapshot? lastDocument; // Store last document for pagination
//   RxBool isFetching = false.obs; // Prevents multiple fetch calls
//   RxList<Map<String, dynamic>> posts = <Map<String, dynamic>>[].obs;

//   /// Fetch the first 10 posts
//   Future<void> fetchInitialPosts() async {
//     if (isFetching.value) return;
//     isFetching.value = true;

//     try {
//       QuerySnapshot snapshot = await _firestore
//           .collection('posts')
//           .orderBy('timestamp', descending: true)
//           .limit(pageSize)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         lastDocument = snapshot.docs.last;
//       }

//       List<Map<String, dynamic>> newPosts = await _fetchUserData(snapshot.docs);
//       posts.assignAll(newPosts); // Replace with new posts
//     } catch (e) {
//       print("Error fetching posts: $e");
//     } finally {
//       isFetching.value = false;
//     }
//   }

//   /// Fetch the next batch of 10 posts
//   Future<void> fetchMorePosts() async {
//     if (isFetching.value || lastDocument == null) return;
//     isFetching.value = true;

//     try {
//       QuerySnapshot snapshot = await _firestore
//           .collection('posts')
//           .orderBy('timestamp', descending: true)
//           .startAfterDocument(lastDocument!)
//           .limit(pageSize)
//           .get();

//       if (snapshot.docs.isNotEmpty) {
//         lastDocument = snapshot.docs.last;
//       }

//       List<Map<String, dynamic>> newPosts = await _fetchUserData(snapshot.docs);
//       posts.addAll(newPosts); // Append new posts
//     } catch (e) {
//       print("Error fetching more posts: $e");
//     } finally {
//       isFetching.value = false;
//     }
//   }

//   /// Fetch user data for each post
//   Future<List<Map<String, dynamic>>> _fetchUserData(
//       List<QueryDocumentSnapshot> docs) async {
//     List<Map<String, dynamic>> postsList = [];

//     for (var doc in docs) {
//       Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
//       post['postId'] = doc.id;

//       try {
//         DocumentSnapshot userSnapshot =
//             await _firestore.collection('Users').doc(post['userId']).get();

//         if (userSnapshot.exists) {
//           Map<String, dynamic> user =
//               userSnapshot.data() as Map<String, dynamic>;
//           post['userName'] = user['fullName'];
//           post['userProfileImage'] = user['profileImage'];
//           post['followersCount'] = user['followersCount'];
//           post['friendUid'] = user['uid'];
//           post['accountType'] = user['accountType'];
//           post['bio'] = user['bio'];
//           post['location'] = user['location'];
//           post['about'] = user['about'];
//           post['followersCount']=user['followersCount'];
//            post['followingCount']=user['followingCount'];
//             post['postCount']=user['postCount'];
//             post['coverImage']=user['coverImage'];

//         } else {
//           post['userName'] = "Unknown User";
//           post['userProfileImage'] = "";
//           post['followersCount'] = 0;
//         }
//       } catch (e) {
//         print("Error fetching user data: $e");
//         post['userName'] = "Unknown User";
//         post['userProfileImage'] = "";
//         post['followersCount'] = 0;
//       }

//       postsList.add(post);
//     }

//     return postsList;
//   }
// }
