
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/PostCardWidgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Fatchingallpost extends StatefulWidget {
  const Fatchingallpost({super.key});

  @override
  State<Fatchingallpost> createState() => _FatchingallpostState();
}

class _FatchingallpostState extends State<Fatchingallpost> {
  
 
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
    backgroundColor: whit,
      body: StreamBuilder<QuerySnapshot>(
        
        stream: FirebaseFirestore.instance
            .collection('posts')
            // Fetch only owner's posts
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

