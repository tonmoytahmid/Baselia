import 'dart:io';

import 'package:baseliae_flutter/Service/StorageService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Uploadprofileimage extends GetxController {
  TextEditingController captionController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  File? selectedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickSingleImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedFile = File(pickedFile.path);
      update();
    }
  }

  Widget buildSelectedMedia() {
    if (selectedFile == null) return SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: Center(
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
            child: Image.file(
              selectedFile!,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> uploadAndUpdateProfile(
    String userId,
  ) async {
    if (selectedFile == null) {
      EasyLoading.showError('No image selected!');
      return;
    }

    EasyLoading.show(status: 'Uploading...');

    String? uploadedUrl = await CloudinaryService.uploadFile(selectedFile!);

    if (uploadedUrl != null) {
      await updateUserProfileImage(userId, uploadedUrl);

      await createPostWithImage(
        userId,
        uploadedUrl,
        captionController.text,
      );

      EasyLoading.dismiss();
      Get.back();
    } else {
      EasyLoading.dismiss();
     
    }
  }

  Future<void> updateUserProfileImage(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'profileImage': imageUrl,
      });
      // captionController.clear();
      selectedFile = null;
      print("User profile image updated!");
    } catch (e) {
      print("Error updating profile image: $e");
    }
  }

  Future<void> createPostWithImage(
    String userId,
    String imageUrl,
    caption
  ) async {
    try {
      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');
      DocumentReference newPostRef = posts.doc();
      String postId = newPostRef.id;

      Map<String, dynamic> postData = {
        'caption': caption ?? '',
        'postId': postId,
        'userId': userId,
        'post_type': 'profile_image_update',
        'likecount': 0,
        'likes': [],
        'comments': [],
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'postCount': FieldValue.increment(1)});

      postData['image_media'] = [imageUrl];
      // if (caption != null && caption.isNotEmpty) {
      //   postData['caption'] = caption;
      // }

      await posts.doc(postId).set(postData);
      print("Post created with image!");
    } catch (e) {
      print("Error creating post: $e");
    }
  }

  // ignore: unused_element
  bool _isVideo(String filePath) {
    List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  // Future<void> deleteUserProfileImage(String userId) async {
  //   try {
  //      EasyLoading.show(status: 'Deleting...');
  //     // Step 1: Update Firestore with default image
  //     await FirebaseFirestore.instance.collection('Users').doc(userId).update({
  //       'profileImage': "https://cdn-icons-png.flaticon.com/512/847/847969.png",
  //     });
     

  //     print("Firestore updated with default image");

  //     // Step 2 (Optional): Clear local variables
  //     captionController.clear();
  //     selectedFile = null;
  //      update();
  //     EasyLoading.dismiss();

  //     print("Profile image successfully reset to default!");
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     print("Error deleting profile image: $e");
  //   }
  // }

  Future<void> deleteUserProfileImage(String userId) async {
  try {
    EasyLoading.show(status: 'Deleting...');

    // Step 1: Get current profile image URL from the user document
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .get();

    final currentProfileImage = userDoc['profileImage'];

    // Step 2: Find the actual post containing this profile image
    QuerySnapshot postSnap = await FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .where('post_type', isEqualTo: 'profile_image_update')
        .where('image_media', arrayContains: currentProfileImage)
        .get();

    // Step 3: Delete the post if found
    if (postSnap.docs.isNotEmpty) {
      await postSnap.docs.first.reference.delete();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .update({'postCount': FieldValue.increment(-1)});
      print("Deleted actual profile image post.");
    } else {
      print("No post found matching current profile image.");
    }

    // Step 4: Set default profile image
    await FirebaseFirestore.instance.collection('Users').doc(userId).update({
      'profileImage': "https://cdn-icons-png.flaticon.com/512/847/847969.png",
    });

    captionController.clear();
    selectedFile = null;
    update();

    EasyLoading.dismiss();
    Get.snackbar("Success", "Profile image and post deleted.");
  } catch (e) {
    EasyLoading.dismiss();
    print("Error deleting profile image and post: $e");
    Get.snackbar("Error", "Failed to delete profile image and post.");
  }
}




}
