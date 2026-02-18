import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoryInsightsScreen extends StatefulWidget {
  final String storyId;

  const StoryInsightsScreen({super.key, required this.storyId});

  @override
  State<StoryInsightsScreen> createState() => _StoryInsightsScreenState();
}

class _StoryInsightsScreenState extends State<StoryInsightsScreen> {
  List<Map<String, dynamic>> viewers = [];
  List<Map<String, dynamic>> reactions = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    final doc = await FirebaseFirestore.instance
        .collection('stories')
        .doc(widget.storyId)
        .get();

    final List viewIds = doc['views'] ?? [];
    final Map reactionMap = doc['reactions'] ?? {};

    // Fetch user data for views
    for (var uid in viewIds) {
      final userDoc =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      if (userDoc.exists) {
        viewers.add({
          'uid': uid,
          'name': userDoc['fullName'],
          'image': userDoc['profileImage'],
        });
      }
    }

    // Fetch user data for reactions
    for (var entry in reactionMap.entries) {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(entry.key)
          .get();
      if (userDoc.exists) {
        reactions.add({
          'uid': entry.key,
          'name': userDoc['fullName'],
          'image': userDoc['profileImage'],
          'emoji': entry.value,
        });
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Story Insights"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "👁️ Views",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...viewers.map((viewer) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(viewer['image']),
                ),
                title: Text(viewer['name'],
                    style: const TextStyle(color: Colors.white)),
              )),
          const SizedBox(height: 24),
          const Text(
            "❤️ Reactions",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...reactions.map((reaction) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(reaction['image']),
                ),
                title: Text(reaction['name'],
                    style: const TextStyle(color: Colors.white)),
                trailing: Text(reaction['emoji'],
                    style: const TextStyle(fontSize: 24)),
              )),
        ],
      ),
    );
  }
}
