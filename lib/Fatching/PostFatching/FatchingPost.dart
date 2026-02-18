import 'package:baseliae_flutter/Controller/PostController/FatchingPostController.dart';
import 'package:baseliae_flutter/Widgets/Posting/PostCardWidgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Fatchingpost extends StatefulWidget {
  final ScrollController scrollController;
  const Fatchingpost({super.key, required this.scrollController});

  @override
  State<Fatchingpost> createState() => _FatchingpostState();
}

class _FatchingpostState extends State<Fatchingpost> {
  final FetchingPostController fatchingpostcontroller = Get.put(FetchingPostController());
  // late ScrollController _scrollController;

  // @override
  // void initState() {
  //   super.initState();
  //   fatchingpostcontroller.fetchInitialPosts(); // Load first 10 posts

  //   _scrollController = ScrollController();
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
  //       fatchingpostcontroller.fetchMorePosts(); // Load next batch when scrolled to bottom
  //     }
  //   });
  // }

  @override
void initState() {
  super.initState();
  fatchingpostcontroller.fetchInitialPosts();

  widget.scrollController.addListener(() {
    if (widget.scrollController.position.pixels ==
        widget.scrollController.position.maxScrollExtent) {
      fatchingpostcontroller.fetchMorePosts();
    }
  });
}


  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  
  Future<void> _onRefresh() async {
    await fatchingpostcontroller.fetchInitialPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (fatchingpostcontroller.posts.isEmpty && fatchingpostcontroller.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fatchingpostcontroller.posts.isEmpty) {
          return const Center(child: Text("No posts available"));
        }

        return RefreshIndicator(
          onRefresh:  _onRefresh,
          
          child: ListView.builder(
            controller:widget.scrollController,
            itemCount: fatchingpostcontroller.posts.length + 1, // Extra for loading indicator
            itemBuilder: (context, index) {
              if (index == fatchingpostcontroller.posts.length) {
                return fatchingpostcontroller.isFetching.value
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink();
              }
              return PostCard(post: fatchingpostcontroller.posts[index]);
            },
          ),
        );
      }),
    );
  }
}
