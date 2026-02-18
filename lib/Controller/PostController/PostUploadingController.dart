import 'dart:io';
import 'package:baseliae_flutter/Helper/VideoPouswidgets.dart';
import 'package:baseliae_flutter/Service/StorageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';

class PostUploadingController extends GetxController {
  TextEditingController captionController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userSession =
      Get.find<UserSessionController>(); // Get session controller

  RxString userName = ''.obs;
  RxString profileImage = ''.obs;

  List<File> selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Fetch profile data initially and whenever activeUid or isPageProfile changes
    fetchUserData();
    ever(userSession.activeUid, (_) => fetchUserData());
    ever(userSession.isPageProfile, (_) => fetchUserData());
  }

  Future<void> fetchUserData() async {
    final uid = userSession.activeUid.value;
    final isPage = userSession.isPageProfile.value;

    if (uid.isEmpty) {
      userName.value = 'Unknown';
      profileImage.value = 'https://via.placeholder.com/150';
      return;
    }

    try {
      DocumentSnapshot doc;
      if (isPage) {
        doc = await _firestore.collection('ChurchPages').doc(uid).get();
      } else {
        doc = await _firestore.collection('Users').doc(uid).get();
      }

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        userName.value = data['churchName'] ?? data['fullName'] ?? 'Unknown';
        profileImage.value = data['profileImage'] ??
            data['profileImage'] ??
            'https://via.placeholder.com/150';
      } else {
        userName.value = 'Unknown';
        profileImage.value = 'https://via.placeholder.com/150';
      }
    } catch (e) {
      print("Error fetching profile data: $e");
      userName.value = 'Unknown';
      profileImage.value = 'https://via.placeholder.com/150';
    }
  }

  Future<void> pickSingleMedia() async {
    final pickedFile = await _picker.pickMedia();
    if (pickedFile != null) {
      selectedFiles.add(File(pickedFile.path));
      update();
    }
  }

  Future<void> pickMultipleMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null) {
      List<File> newFiles = result.paths.map((path) => File(path!)).toList();
      selectedFiles.addAll(newFiles);
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
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child:
                      file.path.endsWith('.mp4') || file.path.endsWith('.mov')
                          ? Container(
                              color: Colors.black45,
                              child: Center(
                                  child: Videopouswidgets(videoUrl: file.path)),
                            )
                          : Image.file(file, fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    selectedFiles.removeAt(index);
                    update();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isVideo(String filePath) {
    List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

  Future<void> uploadSelectedFiles(String caption) async {
    EasyLoading.show(status: 'Uploading...');

    if (selectedFiles.isEmpty && caption.trim().isEmpty) {
      EasyLoading.showError('Please add text or media to post.');
      return;
    }

    final userId = userSession.activeUid.value;
    final postType =
        userSession.isPageProfile.value ? 'page_post' : 'user_post';

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

    await savePostToFirestore(
      userId: userId,
      caption: caption,
      imageUrls: imageUrls,
      videoUrls: videoUrls,
      postType: postType,
    );

    selectedFiles.clear();
    captionController.clear();
    update();
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> savePostToFirestore({
    required String userId,
    required String postType,
    String? caption,
    List<String>? imageUrls,
    List<String>? videoUrls,
    bool isShared = false,
    String? originalPostId,
    String? originalPosterId,
    String? originalPosterName,
    String? originalPosterPhoto,
    String? sharedByName,
    String? sharedByPhoto,
  }) async {
    try {
      final postRef = _firestore.collection('posts').doc();

      Map<String, dynamic> postData = {
        'postId': postRef.id,
        'userId': userId,
        'post_type': postType,
        'timestamp': FieldValue.serverTimestamp(),
        'likecount': 0,
        'likes': [],
        'commentcount': 0,
        'sharedCount': 0,
      };

      if (caption != null && caption.isNotEmpty) {
        postData['caption'] = caption;
      }

      if (imageUrls != null) postData['image_media'] = imageUrls;
      if (videoUrls != null) postData['video_media'] = videoUrls;

      if (isShared) {
        postData.addAll({
          'isShared': true,
          'originalPostId': originalPostId,
          'originalPosterId': originalPosterId,
          'originalPosterName': originalPosterName,
          'originalPosterPhoto': originalPosterPhoto,
          'sharedByName': sharedByName,
          'sharedByPhoto': sharedByPhoto,
        });
      }

      await postRef.set(postData);

      // Increment post count only for normal user (not page posts)
      if (!userSession.isPageProfile.value) {
        await _firestore
            .collection('Users')
            .doc(userId)
            .update({'postCount': FieldValue.increment(1)});
      }

      print("✅ Post saved to Firestore!");
    } catch (e) {
      print("❌ Error saving post: $e");
    }
  }

  Future<void> sharePost(Map<String, dynamic> originalPostData) async {
    final userId = userSession.activeUid.value;
    final userData = userSession.currentProfileData;

    EasyLoading.show(status: 'Sharing...');

    await savePostToFirestore(
      userId: userId,
      postType: 'shared_post',
      caption: originalPostData['caption'] ?? '',
      imageUrls: List<String>.from(originalPostData['image_media'] ?? []),
      videoUrls: List<String>.from(originalPostData['video_media'] ?? []),
      isShared: true,
      originalPostId: originalPostData['postId'],
      originalPosterId: originalPostData['userId'],
      originalPosterName: originalPostData['userName'],
      originalPosterPhoto: originalPostData['userProfileImage'],
      sharedByName: userData['name'],
      sharedByPhoto: userData['image'],
    );

    await _firestore
        .collection('posts')
        .doc(originalPostData['postId'])
        .update({'sharedCount': FieldValue.increment(1)});

    EasyLoading.dismiss();
  }
}







// import 'dart:io';

// import 'package:baseliae_flutter/Helper/VideoPouswidgets.dart';
// import 'package:baseliae_flutter/Service/StorageService.dart';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class PostUploadingController extends GetxController {
//   TextEditingController captionController = TextEditingController();

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   User? user = FirebaseAuth.instance.currentUser;
//   RxString userName = ''.obs;
//   RxString profileImage = ''.obs;
//   @override
//   void onInit() {
//     super.onInit();
//     fetchUserData();
//   }

//   List<File> selectedFiles = [];
//   final ImagePicker _picker = ImagePicker();

//   void fetchUserData() async {
//     if (user != null) {
//       DocumentSnapshot userDoc =
//           await _firestore.collection('Users').doc(user!.uid).get();
//       if (userDoc.exists) {
//         userName.value = userDoc['fullName'] ?? 'Unknown';
//         profileImage.value =
//             userDoc['profileImage'] ?? 'https://via.placeholder.com/150';
//       }
//     }
//   }

//   // Future<void> pickSingleMedia() async {
//   //   final pickedFile = await _picker.pickMedia();
//   //   if (pickedFile != null) {
//   //     selectedFiles = [File(pickedFile.path)];
//   //     update();
//   //   }
//   // }

//   Future<void> pickSingleMedia() async {
//   final pickedFile = await _picker.pickMedia();
//   if (pickedFile != null) {
//     selectedFiles.add(File(pickedFile.path)); // ✅ Use add instead of =
//     update();
//   }
// }


//   // Future<void> pickMultipleMedia() async {
//   //   FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //     type: FileType.media,
//   //     allowMultiple: true,
//   //   );

//   //   if (result != null) {
//   //     selectedFiles = result.paths.map((path) => File(path!)).toList();
//   //     update();
//   //   }
//   // }

//   Future<void> pickMultipleMedia() async {
//   FilePickerResult? result = await FilePicker.platform.pickFiles(
//     type: FileType.media,
//     allowMultiple: true,
//   );

//   if (result != null) {
//     List<File> newFiles = result.paths.map((path) => File(path!)).toList();
//     selectedFiles.addAll(newFiles); // ✅ Use addAll instead of =
//     update();
//   }
// }



//   Widget buildSelectedMedia() {
//   if (selectedFiles.isEmpty) return SizedBox.shrink();

//   return SizedBox(
//     height: 300,
//     child: GridView.builder(
//       shrinkWrap: true,
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         crossAxisSpacing: 8,
//         mainAxisSpacing: 8,
//       ),
//       itemCount: selectedFiles.length,
//       itemBuilder: (context, index) {
//         File file = selectedFiles[index];
//         return Stack(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 decoration: BoxDecoration(
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black26,
//                       blurRadius: 6,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: file.path.endsWith('.mp4') || file.path.endsWith('.mov')
//                     ? Container(
//                         color: Colors.black45,
//                         child: Center(child: Videopouswidgets(videoUrl: file.path)),
//                       )
//                     : Image.file(
//                         file,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: double.infinity,
//                       ),
//               ),
//             ),

//             // ✴️ Remove Button (top right corner)
//             Positioned(
//               top: 4,
//               right: 4,
//               child: GestureDetector(
//                 onTap: () {
//                   selectedFiles.removeAt(index);
//                   update();
//                 },
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     shape: BoxShape.circle,
//                   ),
//                   padding: EdgeInsets.all(4),
//                   child: Icon(Icons.close, color: Colors.white, size: 18),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     ),
//   );
// }

//   bool _isVideo(String filePath) {
//     List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
//     return videoExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
//   }

//   Future<void> uploadSelectedFiles(String userId, String caption) async {
//     EasyLoading.show(status: 'Uploading...');

//     if (selectedFiles.isEmpty && captionController.text.trim().isEmpty) {
//       EasyLoading.showError('Please add text or media to post.');
//       return;
//     }
//     List<String> imageUrls = [];
//     List<String> videoUrls = [];

//     for (var file in selectedFiles) {
//       String? uploadedUrl = await CloudinaryService.uploadFile(file);

//       if (uploadedUrl != null) {
//         if (_isVideo(file.path)) {
//           videoUrls.add(uploadedUrl);
//         } else {
//           imageUrls.add(uploadedUrl);
//         }
//       } else {
//         print("Upload failed for ${file.path}");
//       }
//     }

//     String postType = "normal post";

//     await savePostToFirestore(
//       userId: userId,
//       imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
//       videoUrls: videoUrls.isNotEmpty ? videoUrls : null,
//       caption: caption.isNotEmpty ? caption : null,
//       postType: postType,
//     );

//     selectedFiles.clear();
//     update();
//     captionController.clear();
//     EasyLoading.dismiss();
//     Get.back();
//   }

// Future<void> savePostToFirestore({
//   required String userId,
//   List<String>? imageUrls,
//   List<String>? videoUrls,
//   String? caption,
//   required String postType,
//   bool isShared = false,
//   String? originalPostId,
//   String? originalPosterId,
//   String? originalPosterName,
//   String? originalPosterPhoto,
//   String? sharedByName,
//   String? sharedByPhoto,
// }) async {
//   try {
//     CollectionReference posts = FirebaseFirestore.instance.collection('posts');
//     DocumentReference newPostRef = posts.doc();
//     String postId = newPostRef.id;

//     Map<String, dynamic> postData = {
//       'postId': postId,
//       'userId': userId,
//       'post_type': postType,
//       'likecount': 0,
//       'likes': [],
//       'comments': [],
//       'timestamp': FieldValue.serverTimestamp(),
//       'sharedCount': 0,
//     };

//     await FirebaseFirestore.instance
//         .collection('Users')
//         .doc(userId)
//         .update({'postCount': FieldValue.increment(1)});

//     // Optional fields
//     if (caption != null && caption.isNotEmpty) {
//       postData['caption'] = caption;
//     }

//     if (imageUrls != null && imageUrls.isNotEmpty) {
//       postData['image_media'] = imageUrls;
//     }

//     if (videoUrls != null && videoUrls.isNotEmpty) {
//       postData['video_media'] = videoUrls;
//     }

//     // Shared post logic
//     if (isShared) {
//       postData['isShared'] = true;
//       postData['originalPostId'] = originalPostId;
//       postData['originalPosterId'] = originalPosterId;
//       postData['originalPosterName'] = originalPosterName;
//       postData['originalPosterPhoto'] = originalPosterPhoto;
//       postData['sharedByName'] = sharedByName;
//       postData['sharedByPhoto'] = sharedByPhoto;
//     }

//     await posts.doc(postId).set(postData);
//     print("Post saved to Firestore!");
//   } catch (e) {
//     print("Error saving post: $e");
//   }
// }


// void sharePost(Map<String, dynamic> originalPostData) async {
//   final currentUser = FirebaseAuth.instance.currentUser;
//   final userDoc = await FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).get();

//   EasyLoading.show(status: 'Sharing...');

//   await savePostToFirestore(
//     userId: currentUser.uid,
//     imageUrls: List<String>.from(originalPostData['image_media'] ?? []),
//     videoUrls: List<String>.from(originalPostData['video_media'] ?? []),
//     caption: originalPostData['caption'] ?? '',
//     postType:'shared post',
//     isShared: true,
//     originalPostId: originalPostData['postId'],
//     originalPosterId: originalPostData['userId'],
//     originalPosterName: originalPostData['userName'], // Make sure original post has this field
//     originalPosterPhoto: originalPostData['userProfileImage'],
//     sharedByName: userDoc['fullName'],
//     sharedByPhoto: userDoc['profileImage'],
//   );
//   EasyLoading.dismiss();
//    try {
    
//     await FirebaseFirestore.instance
//         .collection('posts')
//         .doc(originalPostData['postId'])
//         .update({'sharedCount': FieldValue.increment(1)});
//     print("Original post sharedCount updated.");
//   } catch (e) {
//      EasyLoading.dismiss();
//     print("Error updating sharedCount in post: $e");
//   }
// }




// }
