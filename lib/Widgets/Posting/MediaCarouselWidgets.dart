import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:baseliae_flutter/Widgets/Posting/FullScreenMedia.dart';
import 'package:baseliae_flutter/Widgets/Posting/VideoPlayerWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class MediaCarousel extends StatefulWidget {
  final Map<String, dynamic> post;

  const MediaCarousel({super.key, required this.post});

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
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
        AspectRatio(
          aspectRatio: 1, // Make it square; or change to 16/9 for wide media
          child: CarouselSlider.builder(
            itemCount: totalItems,
            itemBuilder: (context, index, realIndex) {
              String mediaUrl = index < imageMedia.length
                  ? imageMedia[index]
                  : videoMedia[index - imageMedia.length];

              final bool isVideo = mediaUrl.endsWith('.mp4');

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
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  
                  color: Colors.black,
                  child: isVideo
                      ? VideoPlayerWidget(videoUrl: mediaUrl)
                      : CachedNetworkImage(
                          imageUrl: mediaUrl,
                          fit: BoxFit.cover, // Fill the space like reference
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                ),
              );
            },
            options: CarouselOptions(
              autoPlay: false,
              viewportFraction: 1.0,
              height: double.infinity, // Takes full height of AspectRatio
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
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
