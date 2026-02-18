
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/PostCardWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart';

class OwnersAllPostscren extends StatefulWidget {
  const OwnersAllPostscren({super.key});

  @override
  State<OwnersAllPostscren> createState() => _OwnersAllPostscrenState();
}

class _OwnersAllPostscrenState extends State<OwnersAllPostscren> {
   String uid = Get.arguments['uid'];
 
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    backgroundColor: whit,
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: uid) // Fetch only owner's posts
            .orderBy('timestamp', descending: true) // Order by latest posts
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No posts available.'));
          }

          // Convert Firestore data to a list of maps
          List<Map<String, dynamic>> posts = snapshot.data!.docs
              .map((doc) => {'postId': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList();

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]); // Pass data to PostCard
            },
          );
        },
      ),
    );
  }
}

