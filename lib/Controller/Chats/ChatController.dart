import 'dart:io';

import 'package:baseliae_flutter/Service/StorageService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatController extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  User? user = FirebaseAuth.instance.currentUser;
  List<File> selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;

  @override
  void onInit() {
    super.onInit();
    _initRecorder();
  }
Future<void> _initRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      await _recorder.startRecorder(toFile: 'audio_message.aac');
      isRecording = true;
      update();
    } else {
      print('Microphone permission not granted');
    }
  }

  Future<void> stopRecording() async {
    String? path = await _recorder.stopRecorder();
    isRecording = false;
    update();

    File audioFile = File(path!);
    selectedFiles = [audioFile];
    update();
    }

   String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? "$user1-$user2" : "$user2-$user1";
  }

  // Pick a single media file (image or video)
  Future<void> pickSingleMedia() async {
    final pickedFile = await _picker.pickMedia();
    if (pickedFile != null) {
      selectedFiles = [File(pickedFile.path)];
      update();
    }
  }

  // Pick multiple media files
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

  // Pick an image from the Camera
  Future<void> pickImageFromCamera() async {
  try {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      selectedFiles = [imageFile];
      update();
    } else {
      
    }
  } catch (e) {
    
  }
}


  // Upload selected files to Cloudinary and save in Firestore
  Future<void> uploadMediaToChat(String senderId, String receiverId, String chatId) async {
    if (selectedFiles.isEmpty) return;
    EasyLoading.show(status: 'Sending..');
    List<String> imageUrls = [];
    List<String> videoUrls = [];
     List<String> audioUrls = [];

    for (var file in selectedFiles) {
      String? uploadedUrl = await CloudinaryService.uploadFile(file);
        if (uploadedUrl != null) {
      if (_isVideo(file.path)) {
        videoUrls.add(uploadedUrl);
      } else if (_isAudio(file.path)) { 
        audioUrls.add(uploadedUrl);
      } else {
        imageUrls.add(uploadedUrl);
      }
    } else {
      print("Upload failed for ${file.path}");
    }
    }

    await saveMessageToFirestore(
      senderId: senderId,
      receiverId: receiverId,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
      videoUrls: videoUrls.isNotEmpty ? videoUrls : null,
       audioUrls: audioUrls.isNotEmpty ? audioUrls : null,
      chatId: chatId,
    );

    selectedFiles.clear();
    update();
    EasyLoading.dismiss();
    EasyLoading.showSuccess('Sending Complete!');
  }


  Future<void> saveMessageToFirestore({
  required String senderId,
  required String receiverId,
  List<String>? imageUrls,
  List<String>? videoUrls,
  List<String>? audioUrls,
  required String chatId,
}) async {
  try {
    DocumentReference chatRef = firestore.collection("chats").doc(chatId);
    CollectionReference messages = chatRef.collection('messages');

    Map<String, dynamic> messageData = {
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    // Determine type and message content
    String messageType = 'text';
    String lastMessagePreview = 'New Message';

    if (imageUrls != null && imageUrls.isNotEmpty) {
      messageData['image_media'] = imageUrls;
      messageType = 'media';
      lastMessagePreview = '📷 Photo';
    }

    if (videoUrls != null && videoUrls.isNotEmpty) {
      messageData['video_media'] = videoUrls;
      messageType = 'media';
      lastMessagePreview = '🎥 Video';
    }

    if (audioUrls != null && audioUrls.isNotEmpty) {
      messageData['audios'] = audioUrls;
      messageType = 'media';
      lastMessagePreview = '🎵 Audio';
    }

    messageData['type'] = messageType;

    // Only save if there is at least one media type
    if (messageData.length > 4) { // senderId, receiverId, timestamp, read + media
      await messages.add(messageData);

      await chatRef.update({
        "lastMessage": lastMessagePreview,
        "lastMessageTime": FieldValue.serverTimestamp(),
      });

      print("Message saved to Firestore!");
    } else {
      print("Message not sent because it has no content.");
    }
  } catch (e) {
    print("Error saving message: $e");
  }
}


  // Save message to Firestore
  // Future<void> saveMessageToFirestore({
  //   required String senderId,
  //   required String receiverId,
  //   List<String>? imageUrls,
  //   List<String>? videoUrls,
  //     List<String>? audioUrls,
  //   required String chatId,
  // }) async {
  //   try {
  //     DocumentReference chatRef = firestore.collection("chats").doc(chatId);
  //     CollectionReference messages = FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages');
      

  //     Map<String, dynamic> messageData = {
  //       'senderId': senderId,
  //       'receiverId': receiverId,
  //       'timestamp': FieldValue.serverTimestamp(),
  //       'read': false,
  //       'type': imageUrls != null || videoUrls != null  ? 'media' : 'text',
  //     };
      
  //     if (imageUrls != null && imageUrls.isNotEmpty) {
  //       messageData['image_media'] = imageUrls;
  //     }
      
  //     if (videoUrls != null && videoUrls.isNotEmpty) {
  //       messageData['video_media'] = videoUrls;
  //     }
  //      if (audioUrls != null && audioUrls.isNotEmpty) {
  //     messageData['audios'] = audioUrls;
  //   }
      
  //     if (messageData.length > 2) {
  //       await messages.add(messageData);
  //       await chatRef.update({
  //       "lastMessage": imageUrls != null
  //           ? "📷 Photo"
  //           : videoUrls != null
  //               ? "🎥 Video"
  //               : "New Message",
  //       "lastMessageTime": FieldValue.serverTimestamp(),
  //     });
  //       print("Message saved to Firestore!");
  //     } else {
  //       print("Message not sent because it has no content.");
  //     }
  //   } catch (e) {
  //     print("Error saving message: $e");
  //   }
  // }

  // Determine if the file is a video
  bool _isVideo(String filePath) {
    List<String> videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => filePath.toLowerCase().endsWith(ext));
  }

// Determine if the file is an audio
  bool _isAudio(String path) {
  final extension = path.split('.').last.toLowerCase();
  return ['mp3', 'aac', 'm4a', 'wav', 'ogg'].contains(extension);
}

 

//Sending text message
  Future<void> sendMessage(
      String senderId, String receiverId, String text,String chatId) async {
    try {
     DocumentReference chatRef = firestore.collection("chats").doc(chatId);
      await firestore
          .collection("chats")
          .doc(chatId)
          .collection("messages")
          .add({
        "senderId": senderId,
        "receiverId": receiverId,
        "text": text,
        "type": "text",
        "timestamp": FieldValue.serverTimestamp(),
        'read': false,
      });
      await chatRef.update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
