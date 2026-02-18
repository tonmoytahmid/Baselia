import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Forumsdiscussionscreen.dart'; // your discussion screen

class ForumSearchScreen extends StatefulWidget {
  const ForumSearchScreen({super.key});

  @override
  State<ForumSearchScreen> createState() => _ForumSearchScreenState();
}

class _ForumSearchScreenState extends State<ForumSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        title: const Text("Search Forums", style: TextStyle(color: purpal)),
        centerTitle: true,
        backgroundColor: whit,
        iconTheme: const IconThemeData(color: Colors.purple),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchText = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by caption...',
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Forums')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final allForums = snapshot.data!.docs.where((doc) {
                  final caption = doc['caption']?.toString().toLowerCase() ?? '';
                  return caption.contains(_searchText);
                }).toList();

                if (allForums.isEmpty) {
                  return const Center(child: Text("No forums found."));
                }

                return ListView.builder(
                  itemCount: allForums.length,
                  itemBuilder: (context, index) {
                    final forumData = allForums[index];
                    final userId = forumData['userId'];
                    final title = forumData['caption'] ?? 'No Caption';
                    final commentCount = forumData['commentcount'] ?? 0;
                    final likeCount = forumData['likecount'] ?? 0;
                    final postId = forumData['postId'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();

                        final userData = snapshot.data!;
                        final username = userData['fullName'] ?? 'Unknown';
                        final profilePic = userData['profileImage'] ?? '';

                        return GestureDetector(
                          onTap: () {
                            Get.to(() => Forumsdiscussionscreen(forumData: forumData));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: whit,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: profilePic.isNotEmpty
                                            ? NetworkImage(profilePic)
                                            : null,
                                        backgroundColor: Colors.grey.shade300,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              username,
                                              style: robotostyle(Colors.black, 14, FontWeight.w700),
                                            ),
                                            Text(
                                              formatTimestamp(forumData['timestamp']),
                                              style: TextStyle(fontSize: 9, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(Icons.more_horiz, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    title,
                                    style: robotostyle(Colors.black, 13, FontWeight.w600),
                                  ),
                                  const SizedBox(height: 10),
                                  // Row(
                                  //   children: [
                                  //     Icon(Icons.thumb_up_alt_outlined, color: Colors.purple, size: 18),
                                  //     const SizedBox(width: 4),
                                  //     Text("$likeCount"),
                                  //     const SizedBox(width: 20),
                                  //     Icon(Icons.comment_outlined, color: Colors.purple, size: 18),
                                  //     const SizedBox(width: 4),
                                  //     Text("$commentCount"),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
