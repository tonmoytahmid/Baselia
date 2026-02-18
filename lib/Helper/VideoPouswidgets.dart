import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Videopouswidgets extends StatefulWidget {
  final String videoUrl;

  const Videopouswidgets({super.key, required this.videoUrl});

  @override
  _VideopouswidgetsState createState() => _VideopouswidgetsState();
}

class _VideopouswidgetsState extends State<Videopouswidgets> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playPauseVideo() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        isVideoPlaying = false;
      } else {
        _controller.play();
        isVideoPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? GestureDetector(
            onTap: playPauseVideo,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: VideoPlayer(_controller),
                ),
                if (!isVideoPlaying)
                  const Icon(
                    Icons.play_arrow,
                    size: 50,
                    color: Colors.white,
                  ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
} 