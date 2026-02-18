import 'package:baseliae_flutter/Controller/PostController/PostUploadingController.dart';
import 'package:baseliae_flutter/Screens/Story/CreatStoryScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Creatpostscreen extends StatelessWidget {
  const Creatpostscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PostUploadingController postUploadingController =
        Get.put(PostUploadingController());

    return Scaffold(
      backgroundColor: whit,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: whit,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Image.asset(
            'assets/images/radix-icons_cross-2.png',
            color: purpal,
            width: 20,
            height: 25,
          ),
        ),
        title: Text(
          "Create Post",
          style: robotostyle(black, 24, FontWeight.w500),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                postUploadingController.uploadSelectedFiles(
                  postUploadingController.captionController.text.trim(),
                );
                // postUploadingController.uploadSelectedFiles(
                //   postUploadingController.user!.uid,
                //   postUploadingController.captionController.text.trim(),
                // );
              },
              child: Container(
                height: 38,
                width: 79,
                decoration: BoxDecoration(
                  color: purpal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    "Post",
                    style: robotostyle(whit, 17, FontWeight.w500),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 140), // space for both bars
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Obx(() => CircleAvatar(
                        backgroundImage: postUploadingController
                                .profileImage.value.isNotEmpty
                            ? NetworkImage(
                                postUploadingController.profileImage.value)
                            : const AssetImage('assets/profile.jpg')
                                as ImageProvider,
                        radius: 24,
                      )),
                  const SizedBox(width: 10),
                  Obx(() => Text(
                        postUploadingController.userName.value,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      )),
                ],
              ),
            ),

            // Caption TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: postUploadingController.captionController,
                decoration: InputDecoration(
                  hintText: "What's On Your Mind?",
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ),
            const SizedBox(height: 10),

            // Media Preview
            GetBuilder<PostUploadingController>(
              builder: (_) => postUploadingController.buildSelectedMedia(),
            ),
          ],
        ),
      ),

      // ✅ Bottom: Two stacked containers (Text row + Icon row)
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🟪 Post | Photos/Videos | Story | Live
          Container(
            height: 40,
            width: 260,
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                    onTap: postUploadingController.pickMultipleMedia,
                    child: Text('Photos/videos',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                GestureDetector(
                    onTap: () {
                      Get.to(() => StoryUploadScreen());
                    },
                    child: Text('Story',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Text('Live', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: 20),

          // 🟨 Icon Options
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: postUploadingController.pickMultipleMedia,
                  icon: const Icon(Icons.image, color: Colors.green),
                ),
                const Icon(Icons.location_on, color: Colors.red),
                const Icon(Icons.layers, color: Colors.brown),
                const Icon(Icons.emoji_emotions, color: Colors.orange),
                const Icon(Icons.local_offer, color: Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
