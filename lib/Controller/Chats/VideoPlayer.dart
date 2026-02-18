import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final List<String> videoUrls;

  const VideoPlayerWidget({super.key, required this.videoUrls});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  int _currentVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideo(widget.videoUrls[_currentVideoIndex]);
  }

  void _initializeVideo(String url) {
    _videoController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {});
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: false,
      looping: false,
    );
  }

  void _changeVideo(int index) {
    setState(() {
      _currentVideoIndex = index;
      _videoController.dispose();
      _initializeVideo(widget.videoUrls[index]);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _videoController.value.isInitialized
            ? Chewie(controller: _chewieController)
            : Center(child: CircularProgressIndicator()),
        if (widget.videoUrls.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.videoUrls.length, (index) {
              return IconButton(
                icon: Icon(
                  Icons.play_circle_fill,
                  color: index == _currentVideoIndex ? Colors.blue : Colors.grey,
                ),
                onPressed: () => _changeVideo(index),
              );
            }),
          ),
      ],
    );
  }
}
