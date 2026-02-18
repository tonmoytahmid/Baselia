import 'package:baseliae_flutter/Forums/ForumsController/DiscussionUploadingController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Creatquestionscreen extends StatelessWidget {
  const Creatquestionscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DiscussionUploadingController discussionUploadingController =
        Get.put(DiscussionUploadingController());

    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        backgroundColor: whit,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Image.asset(
            'assets/images/radix-icons_cross-2.png',
            color: purpal,
            width: 20,
            height: 25,
          ),
        ),
        title: Text(
          "Create Discussion",
          style: robotostyle(black, 18, FontWeight.w400),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                discussionUploadingController.uploadSelectedFiles(
                  discussionUploadingController.user!.uid,
                  discussionUploadingController.titleController.text.trim(),
                  discussionUploadingController.descriptionController.text
                      .trim(),
                  discussionUploadingController.selectedCategory.value,
                );
              },
              child: Container(
                height: 38,
                width: 79,
                decoration: BoxDecoration(
                    color: purpal, borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text(
                    "Create",
                    style: robotostyle(whit, 17, FontWeight.w500),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Obx(() => CircleAvatar(
                      backgroundImage: discussionUploadingController
                              .profileImage.value.isNotEmpty
                          ? NetworkImage(
                              discussionUploadingController.profileImage.value)
                          : AssetImage('assets/profile.jpg') as ImageProvider,
                      radius: 24,
                    )),
                SizedBox(width: 10),
                Obx(() => Text(
                      discussionUploadingController.userName.value,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: discussionUploadingController.titleController,
                    decoration: InputDecoration(
                      hintText: "Title",
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Obx(() => DropdownButtonFormField<String>(
                        initialValue: discussionUploadingController
                            .selectedCategory.value,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: ['General', 'Bible', 'Question', 'Motivation']
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category,
                                      style: TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            discussionUploadingController
                                .setSelectedCategory(value);
                          }
                        },
                      )),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: discussionUploadingController.descriptionController,
              decoration: InputDecoration(
                hintText: "Discussion",
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[100],
              ),
              maxLines: 5,
            ),
          ),
          SizedBox(height: 10),
          GetBuilder<DiscussionUploadingController>(
            // Update UI when selectedFiles change
            builder: (_) => discussionUploadingController.buildSelectedMedia(),
          ),
        ],
      ),
    );
  }
}
