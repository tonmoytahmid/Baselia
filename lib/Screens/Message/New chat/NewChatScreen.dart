
import 'package:baseliae_flutter/Screens/Message/New%20chat/Fatching_Followers.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/Fatching_Following.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/Fatching_Suggested.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/NewChatSearch.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Newchatscreen extends StatefulWidget {
  const Newchatscreen({super.key});

  @override
  State<Newchatscreen> createState() => _NewchatscreenState();
}

class _NewchatscreenState extends State<Newchatscreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

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
          "New Message",
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onTap: (){
                Get.to(()=> Newchatsearch());
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
                FetchAllUsers(),
                Fatching_Followers(),
               Fatching_Following(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}
