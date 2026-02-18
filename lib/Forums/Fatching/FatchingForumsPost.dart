import 'package:baseliae_flutter/Forums/Screens/ForumsDiscussionScreen.dart';
import 'package:baseliae_flutter/Forums/Widgets/ForumPostCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class Fatchingforumspost extends StatefulWidget {
  final String userId;
  const Fatchingforumspost({super.key, required this.userId});

  @override
  State<Fatchingforumspost> createState() => _FatchingforumspostState();
}

class _FatchingforumspostState extends State<Fatchingforumspost>
    with AutomaticKeepAliveClientMixin<Fatchingforumspost> {
  @override
  bool get wantKeepAlive => true;

  Stream<QuerySnapshot> getUserForumPosts() {
    return FirebaseFirestore.instance
        .collection('Forums')
        .where('userId', isEqualTo: widget.userId)
        // .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important for keeping state
    return StreamBuilder<QuerySnapshot>(
      stream: getUserForumPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No posts yet."));
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 10),
              child: ForumPostCard(forumData: posts[index]),
            );
          },
        );
      },
    );
  }
}

class UserForumPostCard extends StatelessWidget {
  final DocumentSnapshot forumData;
  const UserForumPostCard({super.key, required this.forumData});

  @override
  Widget build(BuildContext context) {
    final caption = forumData['caption'] ?? '';
    final timestamp = forumData['timestamp'] ?? Timestamp.now();
    final postId = forumData['postId'];
    final userId = forumData['userId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        final user = snapshot.data!;
        final username = user['fullName'] ?? 'User';
        final profileImage = user['profileImage'] ?? '';

        return GestureDetector(
          onTap: () {
            Get.to(() => Forumsdiscussionscreen(forumData: forumData));
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profileImage),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(username,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(formatTimestamp(timestamp),
                              style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz),
                  ],
                ),
                SizedBox(height: 12),
                Text(caption,
                    style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.favorite_border,
                        size: 20, color: Colors.purple),
                    SizedBox(width: 6),
                    Text(_formatCount(forumData['likecount'] ?? 0)),
                    SizedBox(width: 20),
                    Icon(Icons.comment, size: 20, color: Colors.purple),
                    SizedBox(width: 6),
                    Text(_formatCount(forumData['commentcount'] ?? 0)),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

String _formatCount(int count) {
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}

String formatTimestamp(Timestamp timestamp) {
  return timeago.format(timestamp.toDate());
}
