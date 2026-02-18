import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';

class Relationshipcontroller extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final UserSessionController userSessionController = Get.find();

  //For Pending Requests
  Stream<List<Map<String, dynamic>>> getPendingRequests() {
    return FirebaseFirestore.instance
        .collection('follow_requests')
        .where('status', isEqualTo: 'pending')
        .where('receiverId',
            isEqualTo: userSessionController.activeUid
                .value) // Use activeUid instead of auth.currentUser!.uid
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id; // Add document ID to data
        return data;
      }).toList();
    });
  }

  //For Followers

  Stream<List<Map<String, dynamic>>> getFollowers() {
    final String uid = userSessionController.activeUid.value;

    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    final churchDocRef =
        FirebaseFirestore.instance.collection('ChurchPages').doc(uid);

    return userDocRef.snapshots().asyncMap((userSnapshot) async {
      if (userSnapshot.exists) {
        return _extractFollowers(userSnapshot, uid);
      } else {
        final churchSnapshot = await churchDocRef.get();
        if (churchSnapshot.exists) {
          return _extractFollowers(churchSnapshot, uid);
        } else {
          return [];
        }
      }
    });
  }

  List<Map<String, dynamic>> _extractFollowers(
      DocumentSnapshot snapshot, String currentUid) {
    var followers = snapshot['followers'] as List<dynamic>? ?? [];
    return followers
        .where((follower) => follower['senderId'] != currentUid)
        .map((follower) => follower as Map<String, dynamic>)
        .toList();
  }

  // Stream<List<Map<String, dynamic>>> getFollowers() {
  //   return FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(userSessionController
  //           .activeUid.value) // Use activeUid instead of auth.currentUser!.uid
  //       .snapshots()
  //       .map((docSnapshot) {
  //     var followers = docSnapshot['followers'] as List<dynamic>? ?? [];
  //     return followers
  //         .where((follower) =>
  //             follower['senderId'] != userSessionController.activeUid.value)
  //         .map((follower) => follower as Map<String, dynamic>)
  //         .toList();
  //   });
  // }

  // //For Following
  // Stream<List<Map<String, dynamic>>> getFollowing() {
  //   return FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(userSessionController
  //           .activeUid.value) // Use activeUid instead of auth.currentUser!.uid
  //       .snapshots()
  //       .map((docSnapshot) {
  //     var following = docSnapshot['following'] as List<dynamic>? ?? [];
  //     return following
  //         .where((follow) =>
  //             follow['receiverId'] != userSessionController.activeUid.value)
  //         .map((follow) => follow as Map<String, dynamic>)
  //         .toList();
  //   });
  // }

  Stream<List<Map<String, dynamic>>> getFollowing() {
    final String uid = userSessionController.activeUid.value;

    // Try to fetch from 'Users' first, fallback to 'churchpages' if not found
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(uid);
    final churchDocRef =
        FirebaseFirestore.instance.collection('ChurchPages').doc(uid);

    // Combine both attempts into a single stream
    return userDocRef.snapshots().asyncMap((userSnapshot) async {
      if (userSnapshot.exists) {
        return _extractFollowing(userSnapshot, uid);
      } else {
        final churchSnapshot = await churchDocRef.get();
        if (churchSnapshot.exists) {
          return _extractFollowing(churchSnapshot, uid);
        } else {
          return [];
        }
      }
    });
  }

  List<Map<String, dynamic>> _extractFollowing(
      DocumentSnapshot snapshot, String currentUid) {
    var following = snapshot['following'] as List<dynamic>? ?? [];
    return following
        .where((follow) => follow['receiverId'] != currentUid)
        .map((follow) => follow as Map<String, dynamic>)
        .toList();
  }

  //Can View
  Future<bool> canViewProfile(String profileOwnerId) async {
    String currentUserId = userSessionController.activeUid.value;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(profileOwnerId)
        .get();

    List<String> followers = List<String>.from(userDoc.get("followers") ?? []);
    return followers.contains(currentUserId);
  }

  // Remove from followers list
  Future<void> removeFollower(String followerId) async {
    String currentUserId = userSessionController.activeUid.value;
    DocumentReference currentUserRef =
        firestore.collection("Users").doc(currentUserId);
    DocumentReference followerRef =
        firestore.collection("Users").doc(followerId);

    try {
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserRef);
        DocumentSnapshot followerSnapshot = await transaction.get(followerRef);

        if (!currentUserSnapshot.exists || !followerSnapshot.exists) {
          print("User documents do not exist.");
          return;
        }

        List followers = List.from(currentUserSnapshot.get("followers") ?? []);
        List following = List.from(followerSnapshot.get("following") ?? []);

        followers.removeWhere((follower) =>
            follower is Map<String, dynamic> &&
            follower["senderId"] == followerId);
        following.removeWhere((followingUser) =>
            followingUser is Map<String, dynamic> &&
            followingUser["receiverId"] == currentUserId);

        int newFollowerCount = followers.length;

        transaction.update(currentUserRef,
            {"followers": followers, "followersCount": newFollowerCount});
        transaction.update(followerRef, {"following": following});
      });

      print("✅ Follower removed successfully: $followerId");
    } catch (e) {
      print("❌ Error removing follower: $e");
    }
  }

  // Remove from following list
  Future<void> removeFollowerAndFollowing(String followingId) async {
    String currentUserId = userSessionController.activeUid.value;
    DocumentReference currentUserRef =
        firestore.collection("Users").doc(currentUserId);
    DocumentReference followingUserRef =
        firestore.collection("Users").doc(followingId);

    try {
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot currentUserSnapshot =
            await transaction.get(currentUserRef);
        DocumentSnapshot followingUserSnapshot =
            await transaction.get(followingUserRef);

        if (!currentUserSnapshot.exists || !followingUserSnapshot.exists) {
          print("User documents do not exist.");
          return;
        }

        List following = List.from(currentUserSnapshot.get("following") ?? []);
        List followers =
            List.from(followingUserSnapshot.get("followers") ?? []);

        following.removeWhere((followingUser) =>
            followingUser is Map<String, dynamic> &&
            followingUser["receiverId"] == followingId);
        followers.removeWhere((follower) =>
            follower is Map<String, dynamic> &&
            follower["senderId"] == currentUserId);

        int newFollowingCount = following.length;
        int newFollowerCount = followers.length;

        transaction.update(currentUserRef,
            {"following": following, "followingCount": newFollowingCount});
        transaction.update(followingUserRef,
            {"followers": followers, "followersCount": newFollowerCount});
      });

      print("✅ Successfully removed from both following and followers lists.");
    } catch (e) {
      print("❌ Error removing from following and followers lists: $e");
    }
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:get/get.dart';

// class Relationshipcontroller extends GetxController {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   FirebaseAuth auth = FirebaseAuth.instance;
//   //For Pending Requests
//   Stream<List<Map<String, dynamic>>> getPendingRequests() {
//   return FirebaseFirestore.instance
//       .collection('follow_requests')
//       .where('status', isEqualTo: 'pending')
//       .where('receiverId', isEqualTo: auth.currentUser!.uid) // Filter by receiverId
//       .snapshots()
//       .map((snapshot) {
//     return snapshot.docs.map((doc) {
//       Map<String, dynamic> data = doc.data();
//       data['id'] = doc.id; // Add document ID to data
//       return data;
//     }).toList();
//   });
// }


   

// //For Followers
// Stream<List<Map<String, dynamic>>> getFollowers() {
//     return FirebaseFirestore.instance
//         .collection('Users')
//         .doc(auth.currentUser!.uid)
//         .snapshots()
//         .map((docSnapshot) {
//           var followers = docSnapshot['followers'] as List<dynamic>?;
//           if (followers != null) {
//             // Filter out the current user from the followers list
//             return followers
//                 .where((follower) => follower['senderId'] != auth.currentUser!.uid)
//                 .map((follower) => follower as Map<String, dynamic>)
//                 .toList();
//           }
//           return [];
//         });
//   }





// //For Following

//     Stream<List<Map<String, dynamic>>> getFollowing() {
//     return FirebaseFirestore.instance
//         .collection('Users')
//         .doc(auth.currentUser!.uid)
//         .snapshots()
//         .map((docSnapshot) {
//           var following = docSnapshot['following'] as List<dynamic>?;
//           if (following != null) {
//             // Filter out the current user from the following list
//             return following
//                 .where((follow) => follow['receiverId'] != auth.currentUser!.uid)
//                 .map((follow) => follow as Map<String, dynamic>)
//                 .toList();
//           }
//           return [];
//         });
//   }


//   //Can View

//   Future<bool> canViewProfile(String profileOwnerId) async {
//     String currentUserId = FirebaseAuth.instance.currentUser!.uid;

//     DocumentSnapshot userDoc = await FirebaseFirestore.instance
//         .collection("users")
//         .doc(profileOwnerId)
//         .get();

//     List<String> followers = List<String>.from(userDoc.get("followers") ?? []);

//     return followers.contains(currentUserId);
//   }

//   // Remove form followers list

//   Future<void> removeFollower(String followerId) async {
//     String currentUserId = auth.currentUser!.uid;
//     DocumentReference currentUserRef =
//         firestore.collection("Users").doc(currentUserId);
//     DocumentReference followerRef =
//         firestore.collection("Users").doc(followerId);

//     try {
//       await firestore.runTransaction((transaction) async {
//         DocumentSnapshot currentUserSnapshot =
//             await transaction.get(currentUserRef);
//         DocumentSnapshot followerSnapshot = await transaction.get(followerRef);

//         if (!currentUserSnapshot.exists || !followerSnapshot.exists) {
//           print("User documents do not exist.");
//           return;
//         }

//         List followers = List.from(currentUserSnapshot.get("followers") ?? []);
//         List following = List.from(followerSnapshot.get("following") ?? []);

//         print("Before removal, followers: $followers");
//         print("Before removal, following: $following");

//         followers.removeWhere((follower) =>
//             follower is Map<String, dynamic> &&
//             follower["senderId"] == followerId);

//         following.removeWhere((followingUser) =>
//             followingUser is Map<String, dynamic> &&
//             followingUser["receiverId"] == currentUserId);

//              int newFollowerCount = followers.length;

//         print("After removal, followers: $followers");
//         print("After removal, following: $following");

//        transaction.update(currentUserRef, {"followers": followers, "followersCount": newFollowerCount});
//       transaction.update(followerRef, {"following": following});
//       });

//       print("✅ Follower removed successfully: $followerId");
//     } catch (e) {
//       print("❌ Error removing follower: $e");
//     }
//   }

//   //Remove form following list

//   Future<void> removeFollowerAndFollowing(String followingId) async {
//     String currentUserId = auth.currentUser!.uid;
//     DocumentReference currentUserRef =
//         firestore.collection("Users").doc(currentUserId);
//     DocumentReference followingUserRef =
//         firestore.collection("Users").doc(followingId);

//     try {
//       await firestore.runTransaction((transaction) async {
//         DocumentSnapshot currentUserSnapshot =
//             await transaction.get(currentUserRef);
//         DocumentSnapshot followingUserSnapshot =
//             await transaction.get(followingUserRef);

//         if (!currentUserSnapshot.exists || !followingUserSnapshot.exists) {
//           print("User documents do not exist.");
//           return;
//         }

//         List following = List.from(currentUserSnapshot.get("following") ?? []);
//         List followers =
//             List.from(followingUserSnapshot.get("followers") ?? []);

//         print("Before removal: following = $following, followers = $followers");

//         following.removeWhere((followingUser) =>
//             followingUser is Map<String, dynamic> &&
//             followingUser["receiverId"] == followingId);

//         followers.removeWhere((follower) =>
//             follower is Map<String, dynamic> &&
//             follower["senderId"] == currentUserId);

//         print("After removal: following = $following, followers = $followers");
//  int newFollowingCount = following.length;
//       int newFollowerCount = followers.length;

//       transaction.update(currentUserRef, {"following": following, "followingCount": newFollowingCount});
//       transaction.update(followingUserRef, {"followers": followers, "followersCount": newFollowerCount});
//       });

//       print("✅ Successfully removed from both following and followers lists.");
//     } catch (e) {
//       print("❌ Error removing from following and followers lists: $e");
//     }
//   }
// }
