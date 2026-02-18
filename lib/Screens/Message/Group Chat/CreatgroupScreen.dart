
import 'package:baseliae_flutter/Screens/Message/Group%20Chat/FatchingFollowersGP.dart';
import 'package:baseliae_flutter/Screens/Message/Group%20Chat/FatchingFollowingGP.dart';
import 'package:baseliae_flutter/Screens/Message/Group%20Chat/FatchingSuggestedGP.dart';
import 'package:baseliae_flutter/Screens/Message/Group%20Chat/GroupChatScreen.dart';
import 'package:baseliae_flutter/Screens/Message/Group%20Chat/GroupChatSearch.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class Creatgroupscreen extends StatefulWidget {
  const Creatgroupscreen({super.key});

  @override
  State<Creatgroupscreen> createState() => _CreatgroupscreenState();
}

class _CreatgroupscreenState extends State<Creatgroupscreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();



List<Map<String, dynamic>> selectedUsers = []; // Store selected users

  void _updateSelectedUsers(List<Map<String, dynamic>> users) {
    setState(() {
      selectedUsers = users;
    });
  }



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
          "Create Group ",
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () async {
              if (selectedUsers.isEmpty) {
    Get.snackbar("Error", "Select at least one user to create a group.");
    return;
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return;

  String groupId = Uuid().v4(); // Generate unique group ID
 
  Timestamp createdAt = Timestamp.now();

  // Add current user to selectedUsers list
  List<Map<String, dynamic>> groupMembers = [
    {
      'id': currentUser.uid,
      'fullName': currentUser.displayName ?? "You",
      'profileImage': currentUser.photoURL ?? "",
    },
    ...selectedUsers // selectedUsers already contains name and image
  ];

  String groupName = groupMembers .map((e) => e['fullName'].toString())
                      .join(", "); // 

  try {
    // Create group in Firestore
    await FirebaseFirestore.instance.collection('chats').doc(groupId).set({
      'chatId': groupId,
      'groupName': groupName,
      'members': groupMembers, 
       'membersIds': groupMembers.map((m) => m['id']).toList(),// Store member details
      'createdBy': currentUser.uid,
      'createdAt': createdAt,
      'lastMessage': "",
      'lastMessageTime': createdAt,
      'isGroup': true, // To differentiate from personal chats
    });

    // Navigate to chat screen and pass group data
    Get.to(() => GroupChatScreen(
          groupId: groupId,
          groupName: groupName,
          members: groupMembers, // Pass members list
        ));
  } catch (e) {
    Get.snackbar("Error", "Failed to create group: ${e.toString()}");
  }
              },
              child: Container(
                height: 38,
                width: 79,
                decoration: BoxDecoration(
                    color: purpal, borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text(
                    "Create",
                    style: robotostyle(whit, 17, FontWeight.w500),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [

           if (selectedUsers.isNotEmpty)
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: selectedUsers.length,
                itemBuilder: (context, index) {
                  final user = selectedUsers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: user['profileImage'] != null
                              ? NetworkImage(user['profileImage'])
                              : null,
                          child: user['profileImage'] == null
                              ? Text(user['fullName'][0].toUpperCase())
                              : null,
                        ),
                        // Remove button
                        Positioned(
                          top: 28,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUsers.removeAt(index);
                              });
                            },
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.close, color: Colors.white, size: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

         
          // Search TextField
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onTap: (){
                Get.to(()=>Groupchatsearch(onSelectionChanged: _updateSelectedUsers));
              },
              controller: _searchController,
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

          // TabBar
          TabBar(
            controller: _tabController,
            labelColor: Colors.purple,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(text: "Suggested"),
              Tab(text: "Follower"),
              Tab(text: "Following"),
            ],
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FetchingSuggestedGP(onSelectionChanged: _updateSelectedUsers),
                FatchingFollowersGP(onSelectionChanged: _updateSelectedUsers),
                Fatchingfollowinggp(onSelectionChanged:_updateSelectedUsers ,),
               
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}
