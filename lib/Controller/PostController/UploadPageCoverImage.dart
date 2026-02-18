import 'dart:io';

import 'package:baseliae_flutter/Service/StorageService.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class Uploadpagecoverimage extends GetxController {
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

  Future<void> uploadAndUpdateCover(
    String userId,
  ) async {
    if (selectedFile == null) {
      EasyLoading.showError('No image selected!');
      return;
    }

    EasyLoading.show(status: 'Uploading...');

    String? uploadedUrl = await CloudinaryService.uploadFile(selectedFile!);

    if (uploadedUrl != null) {
      await updateUserCoverInage(userId, uploadedUrl);

      await createPostWithImage(
        userId,
        uploadedUrl,
        captionController.text.trim(),
      );

      EasyLoading.dismiss();
      Get.back();
    } else {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateUserCoverInage(String userId, String imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('ChurchPages')
          .doc(userId)
          .update({
        'coverImage': imageUrl,
      });
      // captionController.clear();
      selectedFile = null;
      print("User profile image updated!");
    } catch (e) {
      print("Error updating profile image: $e");
    }
  }

  Future<void> createPostWithImage(
      String userId, String imageUrl, String? caption) async {
    try {
      CollectionReference posts =
          FirebaseFirestore.instance.collection('posts');
      DocumentReference newPostRef = posts.doc();
      String postId = newPostRef.id;

      Map<String, dynamic> postData = {
        'caption': caption ?? '',
        'postId': postId,
        'userId': userId,
        'post_type': 'cover_image_update',
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

  // Future<void> deleteUserCoverImage(String userId) async {
  //   try {
  //     EasyLoading.show(status: 'Deleting...');
  //     // Step 1: Update Firestore with default image
  //     await FirebaseFirestore.instance.collection('Users').doc(userId).update({
  //       'coverImage': "https://cdn-icons-png.flaticon.com/512/847/847969.png",
  //     });

  //     print("Firestore updated with default image");

  //     // Step 2 (Optional): Clear local variables
  //     captionController.clear();
  //     selectedFile = null;
  //        update();
  //     EasyLoading.dismiss();
  //     print("Profile image successfully reset to default!");
  //   } catch (e) {
  //      EasyLoading.dismiss();
  //     print("Error deleting profile image: $e");
  //   }
  // }

  Future<void> deleteUserCoverImage(String userId) async {
    try {
      EasyLoading.show(status: 'Deleting...');

      final userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);

      // Get the user's current cover image
      final userSnap = await userRef.get();
      final currentCoverImage = userSnap.data()?['coverImage'];

      // Step 1: Reset cover image to default in Firestore
      await userRef.update({
        'coverImage': "https://cdn-icons-png.flaticon.com/512/847/847969.png",
      });
      print("Cover image reset to default in Firestore");

      // Step 2: Search for the related cover image post and delete it
      QuerySnapshot postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .where('post_type', isEqualTo: 'cover_image_update')
          .get();

      for (var doc in postSnap.docs) {
        final postData = doc.data() as Map<String, dynamic>;
        final List imageMedia = postData['image_media'] ?? [];

        if (imageMedia.isNotEmpty && imageMedia[0] == currentCoverImage) {
          // Delete this post
          await FirebaseFirestore.instance
              .collection('posts')
              .doc(doc.id)
              .delete();

          // Decrease post count
          await userRef.update({'postCount': FieldValue.increment(-1)});

          print("Cover image post deleted: ${doc.id}");
          break; // Only delete the most relevant one
        }
      }

      // Step 3: Clear local variables
      captionController.clear();
      selectedFile = null;
      update();
      EasyLoading.dismiss();
      print("Cover image and post successfully deleted!");
    } catch (e) {
      EasyLoading.dismiss();
      print("Error deleting cover image: $e");
    }
  }
}
