import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';
import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class Fatchingpending extends StatefulWidget {
  const Fatchingpending({super.key});

  @override
  State<Fatchingpending> createState() => _FatchingpendingState();
}

class _FatchingpendingState extends State<Fatchingpending> {
  final Relationshipcontroller relationshipcontroller =
      Get.put(Relationshipcontroller());
  final userSession = Get.find<UserSessionController>();

  Future<void> acceptFollowRequest(String requestId, String senderId) async {
    final receiverId = userSession.activeUid.value;

    final receiverRef = userSession.isPageProfile.value
        ? FirebaseFirestore.instance.collection("ChurchPages").doc(receiverId)
        : FirebaseFirestore.instance.collection("Users").doc(receiverId);

    final senderRef =
        FirebaseFirestore.instance.collection("Users").doc(senderId);

    final receiverDoc = await receiverRef.get();
    final senderDoc = await senderRef.get();

    Timestamp timestamp = Timestamp.now();

    List<dynamic> receiverFollowers = receiverDoc.data()?['followers'] ?? [];
    List<dynamic> senderFollowing = senderDoc.data()?['following'] ?? [];

    Map<String, dynamic> newFollower = {
      'senderId': senderId,
      'timestamp': timestamp,
    };

    Map<String, dynamic> newFollowing = {
      'receiverId': receiverId,
      'timestamp': timestamp,
    };

    if (!receiverFollowers.any((f) => f['senderId'] == senderId)) {
      await receiverRef.update({
        "followers": FieldValue.arrayUnion([newFollower]),
        "followersCount": FieldValue.increment(1),
      });
    }

    if (!senderFollowing.any((f) => f['receiverId'] == receiverId)) {
      await senderRef.update({
        "following": FieldValue.arrayUnion([newFollowing]),
        "followingCount": FieldValue.increment(1),
      });
    }

    await FirebaseFirestore.instance
        .collection("follow_requests")
        .doc(requestId)
        .delete();
  }

  Future<void> denyFollowRequest(String requestId) async {
    await FirebaseFirestore.instance
        .collection("follow_requests")
        .doc(requestId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: relationshipcontroller.getPendingRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No Pendings",
                  style: TextStyle(color: purpal, fontSize: 14)));
        }

        var requests = snapshot.data!;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
            final timestamp = request['timestamp'] as Timestamp;
            final timeAgo = formatTimestamp(timestamp);
            final senderId = request['senderId'];
            if (senderId == null || senderId.isEmpty) {
              return const ListTile(
                leading: CircleAvatar(),
                title: Text("Invalid sender ID"),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(request['senderId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (request['senderId'] == null ||
                    request['senderId'].isEmpty) {
                  return const Center(child: Text("Invalid sender ID"));
                }
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                      leading: CircleAvatar(), title: Text('Loading...'));
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  var userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final fullName = userData['fullName'] ?? "Unknown User";
                  final profileImage = userData['profileImage'] ?? "";

                  return _buildRequestTile(
                    id: request['id'],
                    senderId: request['senderId'],
                    name: fullName,
                    image: profileImage,
                    timeAgo: timeAgo,
                    message: request['message'],
                    onAccept: acceptFollowRequest,
                    onDeny: denyFollowRequest,
                    requests: requests,
                  );
                } else {
                  // If not found in Users, try ChurchPages
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("ChurchPages")
                        .doc(request['senderId'])
                        .get(),
                    builder: (context, pageSnapshot) {
                      if (!pageSnapshot.hasData || !pageSnapshot.data!.exists) {
                        return const ListTile(
                          leading: CircleAvatar(child: Icon(Icons.error)),
                          title: Text('Sender not found'),
                        );
                      }

                      var pageData =
                          pageSnapshot.data!.data() as Map<String, dynamic>;
                      final churchName =
                          pageData['churchName'] ?? "Unknown Page";
                      final churchImage = pageData['profileImage'] ?? "";

                      return _buildRequestTile(
                        id: request['id'],
                        senderId: request['senderId'],
                        name: churchName,
                        image: churchImage,
                        timeAgo: timeAgo,
                        message: request['message'],
                        onAccept: acceptFollowRequest,
                        onDeny: denyFollowRequest,
                        requests: requests,
                      );
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequestTile({
    required String id,
    required String senderId,
    required String name,
    required String image,
    required String timeAgo,
    String? message,
    required void Function(String, String) onAccept,
    required void Function(String) onDeny,
    required List<Map<String, dynamic>> requests,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty ? Text(name[0].toUpperCase()) : null,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(timeAgo),
            if (message != null) Text(message),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                onAccept(id, senderId);
                setState(() {
                  requests.removeWhere((r) => r['id'] == id);
                });
              },
              child: Container(
                height: 28,
                width: 68,
                decoration: BoxDecoration(
                    color: purpal, borderRadius: BorderRadius.circular(18)),
                child: Center(
                  child: Text("Confirm",
                      style: ButtonTextStyle(whit, 14, FontWeight.w500)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                onDeny(id);
                setState(() {
                  requests.removeWhere((r) => r['id'] == id);
                });
              },
              child: Container(
                height: 28,
                width: 68,
                decoration: BoxDecoration(
                    color: const Color(0XFFF2F3F5),
                    borderRadius: BorderRadius.circular(18)),
                child: Center(
                  child: Text("Delete",
                      style: ButtonTextStyle(semigray, 14, FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatTimestamp(Timestamp timestamp) {
  return timeago.format(timestamp.toDate(), locale: 'en');
}




// import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
// import 'package:baseliae_flutter/Style/AppStyle.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'package:timeago/timeago.dart' as timeago;

// class Fatchingpending extends StatefulWidget {
//   const Fatchingpending({super.key});

//   @override
//   State<Fatchingpending> createState() => _FatchingpendingState();
// }

// class _FatchingpendingState extends State<Fatchingpending> {
//   Relationshipcontroller relationshipcontroller =
//       Get.put(Relationshipcontroller());
//  void acceptFollowRequest(String requestId, String senderId) async {
//   String receiverId = FirebaseAuth.instance.currentUser!.uid;

 
//   await FirebaseFirestore.instance
//       .collection("follow_requests")
//       .doc(requestId)
//       .update({"status": "accepted"});


//   var receiverDoc = await FirebaseFirestore.instance
//       .collection("Users")
//       .doc(receiverId)
//       .get();
//   var senderDoc = await FirebaseFirestore.instance
//       .collection("Users")
//       .doc(senderId)
//       .get();

  
//   Timestamp timestamp = Timestamp.now();

  
//   List<dynamic> receiverFollowers = receiverDoc.data()?['followers'] ?? [];
//   List<dynamic> senderFollowing = senderDoc.data()?['following'] ?? [];

 
//   Map<String, dynamic> newFollower = {
//     'senderId': senderId,
//     'timestamp': timestamp,
//   };

//   Map<String, dynamic> newFollowing = {
//     'receiverId': receiverId,
//     'timestamp': timestamp,
//   };

 
//   if (!receiverFollowers.any((follower) => follower['senderId'] == senderId)) {
//     await FirebaseFirestore.instance
//         .collection("Users")
//         .doc(receiverId)
//         .update({
//       "followers": FieldValue.arrayUnion([newFollower]), 
//        "followersCount": FieldValue.increment(1),
//     });
//   }


//   if (!senderFollowing.contains(receiverId)) {
//     await FirebaseFirestore.instance
//         .collection("Users")
//         .doc(senderId)
//         .update({
//       "following": FieldValue.arrayUnion([newFollowing]), 
//         "followingCount": FieldValue.increment(1), 
//     });
//   }

 
//   await FirebaseFirestore.instance
//       .collection("follow_requests")
//       .doc(requestId)
//       .delete(); 
// }


//   void denyFollowRequest(String requestId) async {
//     await FirebaseFirestore.instance
//         .collection("follow_requests")
//         .doc(requestId)
//         .delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Map<String, dynamic>>>(
//       stream: relationshipcontroller.getPendingRequests(),
//       builder: (context, snapshot) {
       
//          if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//          if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text("No Pendings",style: TextStyle(color: purpal,fontSize: 14,),));
//         }
//         var requests = snapshot.data!;

//         return ListView.builder(
//           itemCount: requests.length,
//           itemBuilder: (context, index) {
//             var request = requests[index];
//             final timestamp = request['timestamp'] as Timestamp;
//             // ignore: unused_local_variable
//             final timeAgo = formatTimestamp(timestamp);


//             return FutureBuilder<DocumentSnapshot>(
//               future: FirebaseFirestore.instance
//                   .collection('Users')
//                   .doc(request['senderId'])
//                   .get(),
//               builder: (context, userSnapshot) {
//                 if (userSnapshot.connectionState == ConnectionState.waiting) {
//                   return const ListTile(
//                     leading: CircleAvatar(),
//                     title: Text('Loading...'),
//                   );
//                 }

//                 if (!userSnapshot.hasData ||
//                     userSnapshot.data!.data() == null) {
//                   return const ListTile(
//                     leading: CircleAvatar(child: Icon(Icons.error)),
//                     title: Text('User not found'),
//                   );
//                 }

//                 final userData =
//                     userSnapshot.data!.data() as Map<String, dynamic>;
//                 final fullName = userData['fullName'] ?? 'Unknown User';
//                 final profileImage = userData['profileImage'];
//                 // ignore: unused_local_variable
//                 final timeAgo = formatTimestamp(timestamp);

//                 return Padding(
//                   padding: const EdgeInsets.only(top: 20),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       radius: 30,
//                       backgroundImage: profileImage != null
//                           ? NetworkImage(profileImage)
//                           : null,
//                       child: profileImage == null
//                           ? Text(fullName[0].toUpperCase())
//                           : null,
//                     ),
//                     title: Text(fullName),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(timeAgo),
//                         if (request['message'] != null)
//                           Text(request['message']),
//                       ],
//                     ),
//                      trailing: Row(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//     GestureDetector(
//       onTap: () {
//         // Call the acceptFollowRequest method
//         acceptFollowRequest(request['id'], request['senderId']);
        
//         // Use setState to remove the request from the list
//         setState(() {
//           // Remove the request by matching the 'id'
//           requests.removeWhere((r) => r['id'] == request['id']);
//         });
//       },
//       child: Container(
//         height: 28,
//         width: 68,
//         decoration: BoxDecoration(
//             color: purpal, borderRadius: BorderRadius.circular(18)),
//         child: Center(
//             child: Text(
//           "Confirm",
//           style: ButtonTextStyle(whit, 14, FontWeight.w500),
//         )),
//       ),
//     ),
//     const SizedBox(width: 8),
//     GestureDetector(
//       onTap: () { denyFollowRequest(request['id']);
//       setState(() {
//           // Remove the request by matching the 'id'
//           requests.removeWhere((r) => r['id'] == request['id']);
//         });},
//       child: Container(
//         height: 28,
//         width: 68,
//         decoration: BoxDecoration(
//             color: Color(0XFFF2F3F5), borderRadius: BorderRadius.circular(18)),
//         child: Center(
//             child: Text(
//           "Delete",
//           style: ButtonTextStyle(semigray, 14, FontWeight.w500),
//         )),
//       ),
//     ),
//   ],
// ),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
// String formatTimestamp(Timestamp timestamp) {
//   return timeago.format(timestamp.toDate(), locale: 'en');
// }
