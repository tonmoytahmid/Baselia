import 'package:baseliae_flutter/Screens/Message/New%20chat/ChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';


class Fatching_Following extends StatefulWidget {
  const Fatching_Following({super.key});

  @override
  State<Fatching_Following> createState() => _Fatching_FollowingState();
}

class _Fatching_FollowingState extends State<Fatching_Following> {
  Relationshipcontroller relationshipcontroller = Get.put(Relationshipcontroller());

  
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: relationshipcontroller.getFollowing(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Following",style: TextStyle(color: purpal,fontSize: 14,),));
        }

        var followingList = snapshot.data!;

        return ListView.builder(
          itemCount: followingList.length,
          itemBuilder: (context, index) {
            var following = followingList[index];
            
            
            final receiverId = following['receiverId'] ?? ''; 

            if (receiverId.isEmpty) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.error)),
                title: Text('Invalid user ID'),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Users').doc(receiverId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Loading...'),
                  );
                }

                if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
                  return const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.error)),
                    title: Text('User not found'),
                  );
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final fullName = userData['fullName'] ?? 'Unknown User';
                final profileImage = userData['profileImage'];
                  List<Map<String, dynamic>> members = [
                  {
                    'id': auth.currentUser!.uid,
                    'fullName': auth.currentUser!.displayName ?? "You",
                    'profileImage': auth.currentUser!.photoURL ?? "",
                  },
                  {
                    'id': receiverId,
                    'fullName': fullName,
                    'profileImage': profileImage ?? "",
                  }
                ];
               
              
                
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListTile(
                     onTap: () {
                      createChat(members,auth.currentUser!.uid,receiverId);
                    },
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                      child: profileImage == null ? Text(fullName[0].toUpperCase()) : null,
                    ),
                    title: Text(fullName),
                   
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
