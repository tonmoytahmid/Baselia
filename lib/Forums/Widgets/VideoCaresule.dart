import 'package:flutter/material.dart';

class VideoCarousel extends StatelessWidget {
  final List<String> videos;
  
  const VideoCarousel({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Icon(Icons.play_circle_fill, 
                    size: 50, 
                    color: Colors.white
                  ),
                  // For actual video implementation, you'd use a video player widget
                  // like video_player or chewie
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}