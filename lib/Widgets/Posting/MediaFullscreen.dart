import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class MediaFullScreen extends StatelessWidget {
  final String url;
  final bool isVideo;

  const MediaFullScreen({super.key, required this.url, this.isVideo = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        title: Text(
          isVideo ? 'Video Player' : 'Image Viewer',
          style: TextStyle(color: whit),
        ),
        centerTitle: true,
        backgroundColor: purpal, iconTheme: const IconThemeData(color: whit)),
      body: Center(
        child: isVideo
            ? _VideoPlayerWidget(videoUrl: url)
            : InteractiveViewer(
                child: Image.network(url, fit: BoxFit.contain),
              ),
      ),
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : CircularProgressIndicator();
  }
}
