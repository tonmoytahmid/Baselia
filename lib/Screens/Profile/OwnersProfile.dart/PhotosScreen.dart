import 'package:baseliae_flutter/Fatching/ProfileFatching/PhotosFatching.dart';
import 'package:baseliae_flutter/Helper/VideoPouswidgets.dart';
import 'package:baseliae_flutter/Widgets/Posting/MediaFullscreen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Photosscreen extends StatefulWidget {
  String? uid;
  Photosscreen({super.key, required this.uid});

  @override
  State<Photosscreen> createState() => _PhotosscreenState();
}

class _PhotosscreenState extends State<Photosscreen> {
  late Future<List<Map<String, dynamic>>> posts;
  @override
  void initState() {
    super.initState();
    posts = fetchUserPosts(widget.uid!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: posts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No posts available.'));
        }

        List<Map<String, dynamic>> posts = snapshot.data!;

        return GridView.builder(
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            var post = posts[index];

            if (post['image_media'] != null && post['image_media'].isNotEmpty) {
              return GestureDetector(
                onTap: () {
                  Get.to(()=>MediaFullScreen(
                    url: post['image_media'][0],
                    isVideo: false,
                  ));
                },
                child: Image.network(
                  post['image_media'][0],
                  fit: BoxFit.cover,
                ),
              );
            } else if (post['video_media'] != null &&
                post['video_media'].isNotEmpty) {
              return GestureDetector(
                onDoubleTap: () {
                  Get.to(() => MediaFullScreen(
                    url: post['video_media'][0],
                    isVideo: true,
                  ));
                },
                child: Videopouswidgets(videoUrl: post['video_media'][0]));
            } else {
              return Container();
            }
          },
        );
      },
    );
  }
}
