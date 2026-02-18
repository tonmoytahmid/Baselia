import 'package:baseliae_flutter/Screens/Message/New%20chat/NewChatSearch.dart';
import 'package:baseliae_flutter/Service/FatchingChatlist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Messagescreen extends StatefulWidget {
  const Messagescreen({super.key});

  @override
  State<Messagescreen> createState() => _MessagescreenState();
}

class _MessagescreenState extends State<Messagescreen> {
  final List<Map<String, dynamic>> menuItems = [
    {'title': 'New Chat', 'icon': Icons.chat, 'route': '/newChatScreen'},
    {
      'title': 'Create Group',
      'icon': Icons.group,
      'route': '/createGroupScreen'
    },
  ];

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUserChats() {
    String currentUserId = auth.currentUser!.uid;

    return firestore
        .collection('chats')
        .where('membersIds', arrayContains: currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'chatId': doc['chatId'],
          'isGroup': doc['isGroup'] ?? false,
          'groupName': doc['groupName'] ?? '',
          'groupImage': doc['groupImage'] ?? '',
          'lastMessage': doc['lastMessage'] ?? '',
          'timestamp': doc['timestamp'] ?? Timestamp.now(),
          'members': doc['members'],
          'membersIds': doc['membersIds'],
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Chats",
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_outlined, color: Colors.grey),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Menu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      onTap: () {
                        Get.to(() => Newchatsearch());
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        filled: true,
                        contentPadding: const EdgeInsets.all(10),
                        hintText: "Search here...",
                        hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Image.asset("assets/images/create.png"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (context) {
                    return menuItems.map((item) {
                      return PopupMenuItem<String>(
                        value: item['route'],
                        child: Row(
                          children: [
                            Icon(item['icon'],
                                color: item['title'] == 'New Chat'
                                    ? Colors.purple
                                    : Colors.grey),
                            const SizedBox(width: 10),
                            Text(
                              item['title'],
                              style: TextStyle(
                                color: item['title'] == 'New Chat'
                                    ? Colors.purple
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  onSelected: (value) {
                    Get.toNamed(value);
                  },
                ),
              ],
            ),
          ),

          Expanded(child: ChatListScreen())
        ],
      ),
    );
  }
}
