import 'dart:io';

import 'package:baseliae_flutter/Helper/VideoPouswidgets.dart';
import 'package:baseliae_flutter/Service/StorageService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DiscussionUploadingController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  var selectedCategory = 'General'.obs;

  void setSelectedCategory(String value) {
    selectedCategory.value = value;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user = FirebaseAuth.instance.currentUser;
  RxString userName = ''.obs;
  RxString profileImage = ''.obs;
  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  List<File> selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  void fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('Users').doc(user!.uid).get();
      if (userDoc.exists) {
        userName.value = userDoc['fullName'] ?? 'Unknown';
        profileImage.value =
            userDoc['profileImage'] ?? 'https://via.placeholder.com/150';
      }
    }
  }

  Future<void> pickSingleMedia() async {
    final pickedFile = await _picker.pickMedia();
    if (pickedFile != null) {
      selectedFiles = [File(pickedFile.path)];
      update();
    }
  }

  Future<void> pickMultipleMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      selectedFiles = result.paths.map((path) => File(path!)).toList();
      update();
    }
  }

  Widget buildSelectedMedia() {
    if (selectedFiles.isEmpty) return SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: selectedFiles.length,
        itemBuilder: (context, index) {
          File file = selectedFiles[index];
          return GestureDetector(
            onTap: () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: file.path.endsWith('.mp4') || file.path.endsWith('.mov')
                    ? Container(
                        color: Colors.black45,
                        child: Center(
                            child: Videopouswidgets(videoUrl: file.path)),
                      )
                    : Image.file(
                        file,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isVideo(String filePath) {
    List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  Future<void> uploadSelectedFiles(String userId, String caption,
      String description, String category) async {
    EasyLoading.show(status: 'Uploading...');

    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      EasyLoading.showError('Please add title and description to post.');
      return;
    }
    List<String> imageUrls = [];
    List<String> videoUrls = [];

    for (var file in selectedFiles) {
      String? uploadedUrl = await CloudinaryService.uploadFile(file);

      if (uploadedUrl != null) {
        if (_isVideo(file.path)) {
          videoUrls.add(uploadedUrl);
        } else {
          imageUrls.add(uploadedUrl);
        }
      } else {
        print("Upload failed for ${file.path}");
      }
    }

    String postType = "normal post";

    await savePostToFirestore(
      userId: userId,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
      videoUrls: videoUrls.isNotEmpty ? videoUrls : null,
      caption: caption.isNotEmpty ? caption : null,
      description: description.isNotEmpty ? description : null,
      postType: postType,
      category: category,
    );

    selectedFiles.clear();
    update();
    titleController.clear();
    descriptionController.clear();
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> savePostToFirestore({
    required String userId,
    List<String>? imageUrls,
    List<String>? videoUrls,
    String? caption,
    String? description,
    required String postType,
    bool isShared = false,
    String? originalPostId,
    String? originalPosterId,
    String? originalPosterName,
    String? originalPosterPhoto,
    String? sharedByName,
    String? sharedByPhoto,
    String? category,
  }) async {
    try {
      CollectionReference posts =
          FirebaseFirestore.instance.collection('Forums');
      DocumentReference newPostRef = posts.doc();
      String postId = newPostRef.id;

      Map<String, dynamic> postData = {
        'postId': postId,
        'userId': userId,
        'post_type': postType,
        'likecount': 0,
        'likes': [],
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
        'sharedCount': 0,
        'category': category,
        'image_media': [],
        'video_media': [],
        'commentcount': 0,
        'upvotes': {},
        'downvotes': {},
        'voteCount': 0,
      };

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'postCount': FieldValue.increment(1)});

      // Optional fields
      if (caption != null && caption.isNotEmpty) {
        postData['caption'] = caption;
      }
      if (description != null && description.isNotEmpty) {
        postData['description'] = description;
      }

      if (imageUrls != null && imageUrls.isNotEmpty) {
        postData['image_media'] = imageUrls;
      }

      if (videoUrls != null && videoUrls.isNotEmpty) {
        postData['video_media'] = videoUrls;
      }

      // Shared post logic
      if (isShared) {
        postData['isShared'] = true;
        postData['originalPostId'] = originalPostId;
        postData['originalPosterId'] = originalPosterId;
        postData['originalPosterName'] = originalPosterName;
        postData['originalPosterPhoto'] = originalPosterPhoto;
        postData['sharedByName'] = sharedByName;
        postData['sharedByPhoto'] = sharedByPhoto;
      }

      await posts.doc(postId).set(postData);
      print("Post saved to Firestore!");
    } catch (e) {
      print("Error saving post: $e");
    }
  }

  void sharePost(Map<String, dynamic> originalPostData) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.uid)
        .get();

    EasyLoading.show(status: 'Sharing...');

    await savePostToFirestore(
      userId: currentUser.uid,
      imageUrls: List<String>.from(originalPostData['image_media'] ?? []),
      videoUrls: List<String>.from(originalPostData['video_media'] ?? []),
      caption: originalPostData['caption'] ?? '',
      description: originalPostData['description'] ?? '',
      postType: originalPostData['post_type'],
      isShared: true,
      originalPostId: originalPostData['postId'],
      originalPosterId: originalPostData['userId'],
      originalPosterName: originalPostData[
          'userName'], // Make sure original post has this field
      originalPosterPhoto: originalPostData['userProfileImage'],
      sharedByName: userDoc['fullName'],
      sharedByPhoto: userDoc['profileImage'],
      category: originalPostData['category'],
    );
    EasyLoading.dismiss();
    try {
      await FirebaseFirestore.instance
          .collection('Forums')
          .doc(originalPostData['postId'])
          .update({'sharedCount': FieldValue.increment(1)});
      print("Original post sharedCount updated.");
    } catch (e) {
      EasyLoading.dismiss();
      print("Error updating sharedCount in post: $e");
    }
  }
}
