import 'package:baseliae_flutter/Screens/Message/New%20chat/ChatScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Newchatsearch extends StatefulWidget {
  const Newchatsearch({super.key});

  @override
  State<Newchatsearch> createState() => _NewchatsearchState();
}

class _NewchatsearchState extends State<Newchatsearch> {
 
  List<Map<String, dynamic>> _searchResults = [];

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final result = await FirebaseFirestore.instance
        .collection('Users') 
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: '$query\uf8ff')
        .get();

    setState(() {
      _searchResults = result.docs .where((doc) => doc.id != currentUserId) .map((doc) {
        return {
          'uid': doc.id, // Firestore document ID (User UID)
          'fullName': doc['fullName'],
          'profileImage':
              doc['profileImage'], // Make sure your Firestore has this field
        };
      }).toList();
    });
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> createChat(List<Map<String, dynamic>> members, String senderId,
      String receiverId) async {
    String getChatId(String user1, String user2) {
      return user1.hashCode <= user2.hashCode
          ? "$user1-$user2"
          : "$user2-$user1";
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 21),
          child: Material(
            elevation: 1.5,
            shape: const CircleBorder(),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.purple),
              ),
            ),
          ),
        ),
        title: const Text(
          "Search",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onEditingComplete: () => FocusScope.of(context).unfocus(),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              onChanged:
                  _searchUsers, // Call the search function when user types
              decoration: InputDecoration(
                fillColor: Colors.grey[200],
                filled: true,
                contentPadding: const EdgeInsets.all(12),
                hintText: "Search users...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Search results list
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];

                final fullName = user['fullName'] ?? 'Unknown User';
                final profileImage = user['profileImage'];
                final userId = user['uid'];

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

                return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: user['profileImage'] != null
                          ? NetworkImage(user['profileImage'])
                          : const AssetImage('assets/default_user.png')
                              as ImageProvider,
                    ),
                    title: Text(user['fullName']),
                    onTap: () {
                      createChat(members, auth.currentUser!.uid, userId);
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
