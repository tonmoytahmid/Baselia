// ignore_for_file: unused_field

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:baseliae_flutter/Service/StorageService.dart';

class StoryUploadingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  User? user = FirebaseAuth.instance.currentUser;

  RxList<File> selectedFiles = <File>[].obs;
  RxString userName = ''.obs;
  RxString profileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

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

  Future<void> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      final files = result.paths.map((e) => File(e!)).toList();
      selectedFiles.addAll(files);
    }
  }

  bool _isVideo(String path) {
    return ['.mp4', '.mov', '.avi', '.mkv'].any((ext) => path.endsWith(ext));
  }

  Future<void> uploadStory() async {
    if (selectedFiles.isEmpty) {
      EasyLoading.showError("Please select image or video");
      return;
    }

    EasyLoading.show(status: "Uploading...");

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
      }
    }

    await saveStoryToFirestore(
      userId: user!.uid,
      imageUrls: imageUrls,
      videoUrls: videoUrls,
    );

    selectedFiles.clear();
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> saveStoryToFirestore({
    required String userId,
    List<String>? imageUrls,
    List<String>? videoUrls,
  }) async {
    try {
      final storyRef = _firestore.collection('stories').doc();
      final now = Timestamp.now();
      final expiresAt = Timestamp.fromDate(
        now.toDate().add(const Duration(hours: 24)),
      );

      Map<String, dynamic> storyData = {
        'storyId': storyRef.id,
        'userId': userId,
        'userName': userName.value,
        'userProfileImage': profileImage.value,
        'image_media': imageUrls ?? [],
        'video_media': videoUrls ?? [],
        'createdAt': now,
        'expiresAt': Timestamp.now().toDate().add(Duration(hours: 24)),
        'views': [],
      };

      await storyRef.set(storyData);
      print("✅ Story uploaded!");
    } catch (e) {
      print("❌ Failed to upload story: $e");
    }
  }
}
