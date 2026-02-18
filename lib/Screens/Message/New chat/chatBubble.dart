
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:chewie/chewie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart' show AudioPlayer;
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatBubble extends StatelessWidget {
  final String senderId;
  final String currentUser;
  final String? text;
  final List<String>? mediaUrls;

  const ChatBubble({
    super.key,
    required this.senderId,
    required this.currentUser,
    this.text,
    this.mediaUrls,
  });

  bool get isMe => currentUser == currentUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (text != null && text!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: isMe ? purpal : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                text!,
                style: const TextStyle(fontSize: 16, color: whit),
              ),
            ),
          ],
          if (mediaUrls != null && mediaUrls!.isNotEmpty) ...[
            const SizedBox(height: 5),
            _buildMediaContent(context),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    final mediaList = mediaUrls ?? [];
    if (mediaList.isEmpty) return const SizedBox();

    // Categorize media types
    final audioList = mediaList.where((url) =>
        url.endsWith(".mp3") ||
        url.endsWith(".wav") ||
        url.endsWith(".m4a") ||
        url.endsWith(".aac")).toList();
    final videoList = mediaList.where((url) =>
        url.endsWith(".mp4") ||
        url.endsWith(".mov") ||
        url.endsWith(".avi")).toList();
    final imageList = mediaList.where((url) =>
        url.endsWith(".jpg") ||
        url.endsWith(".jpeg") ||
        url.endsWith(".png") ||
        url.endsWith(".gif")).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show images and videos in carousel if any
        if (imageList.isNotEmpty || videoList.isNotEmpty)
          SizedBox(
            height: 250,
            width: MediaQuery.of(context).size.width * 0.85,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider.builder(
                  itemCount: imageList.length + videoList.length,
                  itemBuilder: (context, index, realIndex) {
                    final combinedList = [...imageList, ...videoList];
                    return _buildSingleMedia(combinedList[index], context);
                  },
                  options: CarouselOptions(
                    enlargeCenterPage: true,
                    autoPlay: false,
                    aspectRatio: 16 / 9,
                    viewportFraction: 1.0,
                  ),
                ),
                if (imageList.length + videoList.length > 1)
                  Positioned(
                    bottom: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${imageList.length + videoList.length} media items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          backgroundColor: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 10),
        // Show audio files
        if (audioList.isNotEmpty)
          ...audioList.map((url) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: _buildAudioPlayer(url),
              )),
      ],
    );
  }

  Widget _buildSingleMedia(String url, BuildContext context) {
    if (url.endsWith(".mp4")) {
      return VideoPlayerWidget(videoUrl: url);
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: url,
          width: MediaQuery.of(context).size.width * 0.8,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    }
  }

  Widget _buildAudioPlayer(String audioUrl) {
    return AudioPlayerWidget(audioUrl: audioUrl);
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      aspectRatio: 16 / 9,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 180, // Adjust size to prevent overflow
        child: _controller.value.isInitialized
            ? Chewie(controller: _chewieController)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({required this.audioUrl, super.key});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late AudioPlayer _audioPlayer;
  bool isPlaying = false;
  double _volume = 1.0; // Default volume
  // double _progress = 0.0; // For tracking playback progress

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    // _audioPlayer.setVolume(_volume); // Set the initial volume
    // _audioPlayer.setUrl(widget.audioUrl).then((_) {
    //   _audioPlayer.positionStream.listen((duration) {
    //     setState(() {
    //       _progress = duration.inMilliseconds / _audioPlayer.duration!.inMilliseconds;
    //     });
    //   });
    // });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.setUrl(widget.audioUrl).then((_) {
        _audioPlayer.play();
      });
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  // Method to update volume
  // ignore: unused_element
  void _setVolume(double value) {
    setState(() {
      _volume = value;
      _audioPlayer.setVolume(_volume); // Adjust the volume
    });
  }

//   Widget _buildWaveform() {
//   return Row(
//     mainAxisSize: MainAxisSize.min,
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: List.generate(20, (index) {
//       // Add a base height and animate with progress
//       double barHeight = (index.isEven
//               ? 10 + (20 * _progress) // alternate heights
//               : 20 + (30 * _progress))
//           .clamp(10.0, 50.0); // Clamp to limit max height

//       return AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         width: 3.0,
//         height: barHeight,
//         margin: const EdgeInsets.symmetric(horizontal: 1.5),
//         decoration: BoxDecoration(
//           color: Colors.deepPurple,
//           borderRadius: BorderRadius.circular(3),
//         ),
//       );
//     }),
//   );
// }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min, // Ensures Row shrinks to its children
          children: [
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow,color: purpal,),
              onPressed: _togglePlayPause,
            ),
            const SizedBox(width: 10),
            Text('Audio Message',style: TextStyle(color: purpal),),
            // _buildWaveform(), // Placeholder for waveform
          ],
        ),
        // const SizedBox(height: 10),
        // Volume control slider
        // Row(
        //   mainAxisSize: MainAxisSize.min, // Ensures Row shrinks to its children
        //   children: [
        //     const Text("Volume"),
        //     Flexible(
        //       fit: FlexFit.loose, // Allow it to take less space
        //       child: Slider(
        //         value: _volume,
        //         min: 0.0,
        //         max: 1.0,
        //         onChanged: _setVolume,
        //         activeColor: Colors.deepPurple,
        //         inactiveColor: Colors.grey,
        //       ),
        //     ),
        //     Text('${(_volume * 100).round()}%'), // Show volume percentage
        //   ],
        // ),
      ],
    );
  }
}

