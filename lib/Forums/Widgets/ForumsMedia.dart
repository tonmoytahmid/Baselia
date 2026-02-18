import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/FullScreenMedia.dart';
import 'package:baseliae_flutter/Widgets/Posting/VideoPlayerWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Forumsmedia extends StatefulWidget {
  final DocumentSnapshot post;

  const Forumsmedia({super.key, required this.post});

  @override
  State<Forumsmedia> createState() => _ForumsmediaState();
}

class _ForumsmediaState extends State<Forumsmedia> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> imageMedia =
        List<String>.from(widget.post['image_media'] ?? []);
    final List<String> videoMedia =
        List<String>.from(widget.post['video_media'] ?? []);
    final int totalItems = imageMedia.length + videoMedia.length;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CarouselSlider.builder(
              itemCount: totalItems,
              itemBuilder: (context, index, realIndex) {
                String mediaUrl = '';

                if (index < imageMedia.length) {
                  mediaUrl = imageMedia[index];
                } else {
                  mediaUrl = videoMedia[index - imageMedia.length];
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenMediaPage(mediaUrl: mediaUrl),
                      ),
                    );
                  },
                  child: mediaUrl.isNotEmpty
                      ? mediaUrl.endsWith('.mp4')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AspectRatio(
                                aspectRatio: 16 / 10,
                                child: VideoPlayerWidget(videoUrl: mediaUrl,),
                                
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: mediaUrl,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                            )
                      : const SizedBox(),
                );
              },
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
                aspectRatio: 16 / 10,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ],
        ),
        if (totalItems > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalItems,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? purpal : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
