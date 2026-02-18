import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class FetchingOwnerPostController extends GetxController {
  Future<List<Map<String, dynamic>>> fetchOwnerPosts(String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      List<Map<String, dynamic>> posts = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
        post['postId'] = doc.id;

        // Determine if it's a church page post
        String postType = post['post_type'] ?? 'user_post';
        DocumentSnapshot userSnapshot;

        if (postType == 'page_post') {
          // Fetch data from ChurchPages
          userSnapshot = await FirebaseFirestore.instance
              .collection('ChurchPages')
              .doc(userId)
              .get();

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
            post['followersCount'] = 0;
          }
        } else {
          // Fetch data from Users
          userSnapshot = await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .get();

          if (userSnapshot.exists) {
            Map<String, dynamic> user =
                userSnapshot.data() as Map<String, dynamic>;
            post['userName'] = user['fullName'] ?? 'Unknown';
            post['userProfileImage'] = user['profileImage'] ?? '';
            post['followersCount'] = user['followersCount'] ?? 0;
            post['friendUid'] = userId;
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
            post['followersCount'] = 0;
          }
        }

        posts.add(post);
      }

      return posts;
    } catch (e) {
      print("❌ Error fetching posts: $e");
      return [];
    }
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';


// class FetchingOwnerPostController extends GetxController {
//   Future<List<Map<String, dynamic>>> fetchOwnerPosts(String userId) async {
//     try {
      
     
//       QuerySnapshot snapshot = await FirebaseFirestore.instance
//           .collection('posts')
//           .where('userId', isEqualTo: userId) 
//           .orderBy('timestamp', descending: true)
//           .get();

//       List<Map<String, dynamic>> posts = [];

//       for (var doc in snapshot.docs) {
//         Map<String, dynamic> post = doc.data() as Map<String, dynamic>;
//         post['postId'] = doc.id;

       
//         DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
//             .collection('Users')
//             .doc(post['userId'])
//             .get();

//         if (userSnapshot.exists) {
//           Map<String, dynamic> user = userSnapshot.data() as Map<String, dynamic>;
//           post['userName'] = user['fullName'] ?? "Unknown User";
//           post['userProfileImage'] = user['profileImage'] ?? "";
//           post['followersCount'] = user['followersCount'] ?? 0;
//         } else {
//           post['userName'] = "Unknown User";
//           post['userProfileImage'] = "";
//           post['followersCount'] = 0;
//         }

//         posts.add(post);
//       }

//       return posts;
//     } catch (e) {
//       print("Error fetching posts: $e");
//       return [];
//     }
//   }
// }
