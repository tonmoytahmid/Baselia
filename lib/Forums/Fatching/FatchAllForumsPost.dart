
import 'package:baseliae_flutter/Forums/ForumsController/FatchingForumsPostController.dart';
import 'package:baseliae_flutter/Forums/Widgets/ForumsPostWidgets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Fatchallforumspost extends StatefulWidget {
   final String selectedCategory;
  const Fatchallforumspost({super.key,required this.selectedCategory});

  @override
  State<Fatchallforumspost> createState() => _FatchallforumspostState();
}

class _FatchallforumspostState extends State<Fatchallforumspost> {
  final FetchingForumController fatchingpostcontroller = Get.put(FetchingForumController());
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    fatchingpostcontroller.fetchInitialForums(category: widget.selectedCategory); // Load first 10 posts

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fatchingpostcontroller.fetchMoreForums(category: widget.selectedCategory); // Load next batch when scrolled to bottom
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  
  Future<void> _onRefresh() async {
    await fatchingpostcontroller.fetchInitialForums(category: widget.selectedCategory); // Refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Obx(() {
        if (fatchingpostcontroller.forums.isEmpty && fatchingpostcontroller.isFetching.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (fatchingpostcontroller.forums.isEmpty) {
          return const Center(child: Text("No posts available"));
        }

        return RefreshIndicator(
          onRefresh:  _onRefresh,
          
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            controller: _scrollController,
            itemCount: fatchingpostcontroller.forums.length + 1, // Extra for loading indicator
            itemBuilder: (context, index) {
              if (index == fatchingpostcontroller.forums.length) {
                return fatchingpostcontroller.isFetching.value
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink();
              }
              return Forumspostwidgets(Forumspost: fatchingpostcontroller.forums[index]);
            },
          ),
        );
      }),
    );
  }
}
