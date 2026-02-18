// import 'dart:io';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class PostController extends GetxController {
//   final ImagePicker picker = ImagePicker();
//
//   var isUploading = false.obs; // To show upload progress
//
//   /// Pick Image or Video from Gallery
//   Future<XFile?> pickMedia() async {
//     return await picker.pickMedia(); // Auto-detects image or video
//   }
//
//   /// Upload Image or Video to Firebase Storage
//   Future<String?> uploadMediaToFirebase(XFile mediaFile) async {
//     try {
//       File file = File(mediaFile.path);
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       String extension = file.path.split('.').last;
//
//       Reference ref = FirebaseStorage.instance.ref().child('uploads/$fileName.$extension');
//       UploadTask uploadTask = ref.putFile(file);
//
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to upload media: $e");
//       return null;
//     }
//   }
//
//   /// Save Post (Image/Video/Text) to Firestore
//   Future<void> savePost(String userId, String? mediaUrl, String caption, String mediaType) async {
//     await FirebaseFirestore.instance.collection('posts').add({
//       'userId': userId,
//       'mediaUrl': mediaUrl, // Can be null if posting text only
//       'caption': caption,
//       'mediaType': mediaType, // "image", "video", or "text"
//       'timestamp': FieldValue.serverTimestamp(),
//       'likes': [],
//       'comments': [],
//     });
//   }
//
//   /// Pick, Upload & Save Post
//   Future<void> pickAndUploadPost(String userId, String caption) async {
//     isUploading.value = true; // Show loading
//
//     XFile? media = await pickMedia();
//     if (media != null) {
//       String mediaType = media.path.endsWith(".mp4") ? "video" : "image";
//       String? mediaUrl = await uploadMediaToFirebase(media);
//
//       if (mediaUrl != null) {
//         await savePost(userId, mediaUrl, caption, mediaType);
//         Get.snackbar("Success", "Post uploaded successfully!");
//       }
//     } else {
//       // If user only wants to post text
//       if (caption.isNotEmpty) {
//         await savePost(userId, null, caption, "text");
//         Get.snackbar("Success", "Text post uploaded!");
//       }
//     }
//
//     isUploading.value = false; // Hide loading
//   }
// }
