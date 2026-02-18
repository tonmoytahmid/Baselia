import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔄 Use the session controller instead of FirebaseAuth directly
  final UserSessionController _session = Get.find<UserSessionController>();

  Future<Map<String, bool>> checkFriendStatus(String postUserId) async {
    String currentUserId = _session.activeUid.value;

    try {
      // Check if postUserId belongs to Users or ChurchPages
      var userDoc = await _firestore.collection("Users").doc(postUserId).get();
      var isChurchPage = !userDoc.exists;

      // Fetch current user's "following" list
      var currentUserDoc = await _firestore
          .collection(_session.isPageProfile.value ? "ChurchPages" : "Users")
          .doc(currentUserId)
          .get();

      List followingList = currentUserDoc.data()?['following'] ?? [];

      bool isFriend = false;
      bool isRequested = false;

      if (isChurchPage) {
        var pageDoc =
            await _firestore.collection("ChurchPages").doc(postUserId).get();

        if (pageDoc.exists) {
          List pageFollowers = pageDoc.data()?['followers'] ?? [];

          isFriend = followingList
                  .any((item) => item['receiverId'] == postUserId) &&
              pageFollowers.any((item) => item['senderId'] == currentUserId);
        }
      } else {
        var postUserDoc = userDoc;
        List followersList = postUserDoc.data()?['followers'] ?? [];

        isFriend =
            followingList.any((item) => item['receiverId'] == postUserId) &&
                followersList.any((item) => item['senderId'] == currentUserId);
      }

      // Check pending follow requests
      if (!isFriend) {
        var requestDocs = await _firestore
            .collection("follow_requests")
            .where("senderId", isEqualTo: currentUserId)
            .where("receiverId", isEqualTo: postUserId)
            .where("status", isEqualTo: "pending")
            .get();

        isRequested = requestDocs.docs.isNotEmpty;
      }

      return {
        "isFriend": isFriend,
        "isRequested": isRequested,
      };
    } catch (e) {
      print("❌ Error checking friend status: $e");
      return {
        "isFriend": false,
        "isRequested": false,
      };
    }
  }

  Future<void> sendFollowRequest(String postUserId) async {
    String currentUserId = _session.activeUid.value;

    await _firestore.collection("follow_requests").add({
      "senderId": currentUserId,
      "receiverId": postUserId,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<void> cancelFollowRequest(String postUserId) async {
    String currentUserId = _session.activeUid.value;

    var requestDocs = await _firestore
        .collection("follow_requests")
        .where("senderId", isEqualTo: currentUserId)
        .where("receiverId", isEqualTo: postUserId)
        .where("status", isEqualTo: "pending")
        .get();

    for (var doc in requestDocs.docs) {
      await doc.reference.delete();
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class FollowService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   Future<Map<String, bool>> checkFriendStatus(String postUserId) async {
//     String? currentUserId = _auth.currentUser?.uid;

//     try {
//       var currentUserDoc = await _firestore.collection("Users").doc(currentUserId).get();
//       var postUserDoc = await _firestore.collection("Users").doc(postUserId).get();

//       List followingList = currentUserDoc.data()?['following'] ?? [];
//       List followersList = postUserDoc.data()?['followers'] ?? [];

//       bool isFriend = followingList.any((item) => item['receiverId'] == postUserId) &&
//                       followersList.any((item) => item['senderId'] == currentUserId);

//       if (!isFriend) {
//         var requestDocs = await _firestore
//             .collection("follow_requests")
//             .where("senderId", isEqualTo: currentUserId)
//             .where("receiverId", isEqualTo: postUserId)
//             .where("status", isEqualTo: "pending")
//             .get();

//         return {
//           "isFriend": false,
//           "isRequested": requestDocs.docs.isNotEmpty,
//         };
//       }

//       return {"isFriend": isFriend, "isRequested": false};
//     } catch (e) {
//       print("Error checking friend status: $e");
//       return {"isFriend": false, "isRequested": false};
//     }
//   }

//   Future<void> sendFollowRequest(String postUserId) async {
//     String? currentUserId = _auth.currentUser?.uid;

//     await _firestore.collection("follow_requests").add({
//       "senderId": currentUserId,
//       "receiverId": postUserId,
//       "status": "pending",
//       "timestamp": FieldValue.serverTimestamp(),
//     });
//   }

//   Future<void> cancelFollowRequest(String postUserId) async {
//     String? currentUserId = _auth.currentUser?.uid;

//     var requestDocs = await _firestore
//         .collection("follow_requests")
//         .where("senderId", isEqualTo: currentUserId)
//         .where("receiverId", isEqualTo: postUserId)
//         .where("status", isEqualTo: "pending")
//         .get();

//     for (var doc in requestDocs.docs) {
//       await doc.reference.delete();
//     }
//   }
// }
