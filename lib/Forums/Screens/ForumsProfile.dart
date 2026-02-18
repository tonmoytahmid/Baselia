import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:baseliae_flutter/Forums/Fatching/FatchingForumsPost.dart';

import '../../Style/AppStyle.dart';

// Main Profile Page
class Froumsprofile extends StatefulWidget {
  final String profilePic;
  final String username;
  final String userEmail;
  final String userId;
  final int followingCount;

  const Froumsprofile({
    super.key,
    required this.profilePic,
    required this.username,
    required this.userEmail,
    required this.userId,
    required this.followingCount,
  });

  @override
  State<Froumsprofile> createState() => _FroumsprofileState();
}

class _FroumsprofileState extends State<Froumsprofile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Profile Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0XFFFFFFFF),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(widget.profilePic),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.username,
                                  style:  TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                 Icon(Icons.mode_edit_outline_outlined, color: Colors.purple),
                              ],
                            ),
                            Text(widget.userEmail,  style: robotostyle(purpal,18,FontWeight.w400)),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Stats Row - all 3 stats in one row
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Forums')
                      .where('userId', isEqualTo: widget.userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    int postCount = 0;
                    int likeSum = 0;

                    if (snapshot.hasData) {
                      postCount = snapshot.data!.docs.length;
                      for (var doc in snapshot.data!.docs) {
                        final likeCount = doc['likecount'];
                        if (likeCount != null && likeCount is int) {
                          likeSum += likeCount;
                        }
                      }
                    }

                    return Container(
                        padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0XFFF8F9FA),
                    boxShadow: const [
                    BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    ),
                    ],),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatItem(label: 'Read Articles', value: formatCount(postCount)),
                          StatItem(label: 'Total Likes', value: formatCount(likeSum)),
                          StatItem(label: 'Following', value: widget.followingCount.toString()),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // TabBar
          Container(
            color: Color(0XFFF8F4F8),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              tabs:  [
                Tab(text: 'Post'),
                Tab(text: 'Activity'),
              ],
            ),
          ),

          // TabBarView
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // First Tab - Posts
                Fatchingforumspost(userId: widget.userId),

                // Second Tab - Activity
                const Center(
                  child: Text(
                    'No recent activity.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
