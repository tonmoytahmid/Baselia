import 'package:baseliae_flutter/Screens/Message/New%20chat/ChatScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FetchAllUsers extends StatefulWidget {
  const FetchAllUsers({super.key});

  @override
  State<FetchAllUsers> createState() => _FetchAllUsersState();
}

class _FetchAllUsersState extends State<FetchAllUsers> {

  
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createChat(List<Map<String, dynamic>> members,String senderId ,String receiverId) async {
    String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? "$user1-$user2" : "$user2-$user1";
  }
    try {
      // Generate a unique chatId (you can also use a combination of sender and receiver IDs)
      String chatId = getChatId(senderId, receiverId);

      // Get current user data
      User? currentUser = auth.currentUser;
      if (currentUser == null) return;

      // Create chat data
      await firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'isGroup': false, // false for single chat
        'lastMessage': '', // Empty last message for now
        'lastMessageTime': FieldValue.serverTimestamp(),
        'members': members,
         'membersIds': members.map((m) => m['id']).toList(),
      });

      // Navigate to ChatScreen
      Get.to(() => Chatscreen(
            reciverId:
                members.firstWhere((m) => m['id'] != currentUser.uid)['id'],
            userName: members
                .firstWhere((m) => m['id'] != currentUser.uid)['fullName'],
            userImage: members
                .firstWhere((m) => m['id'] != currentUser.uid)['profileImage'],
            chatId: chatId, // pass the created chatId to the ChatScreen
          ));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').
       where('uid', isNotEqualTo: auth.currentUser!.uid). snapshots(),
     
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
              child: Text(
            "No users found",
            style: TextStyle(fontSize: 14,color: purpal),
          ));
        }

        var usersList = snapshot.data!.docs;

        return ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            var userData = usersList[index].data() as Map<String, dynamic>;
            final fullName = userData['fullName'] ?? 'Unknown User';
            final profileImage = userData['profileImage'];
            final userId = userData['uid'];

            List<Map<String, dynamic>> members = [
                  {
                    'id': auth.currentUser!.uid,
                    'fullName': auth.currentUser!.displayName ?? "You",
                    'profileImage': auth.currentUser!.photoURL ?? "",
                  },
                  {
                    'id': userId,
                    'fullName': fullName,
                    'profileImage': profileImage ?? "",
                  }
                ];

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ListTile(
                onTap: () {
                   createChat(members,auth.currentUser!.uid,userId);
                },
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      profileImage != null ? NetworkImage(profileImage) : null,
                  child: profileImage == null
                      ? Text(fullName[0].toUpperCase())
                      : null,
                ),
                title: Text(fullName),
              ),
            );
          },
        );
      },
    );
  }
}
