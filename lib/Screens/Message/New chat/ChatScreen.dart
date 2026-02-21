// ignore_for_file: unused_local_variable

import 'package:baseliae_flutter/Controller/Chats/ChatController.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/chatBubble.dart';
import 'package:baseliae_flutter/Service/Chatservice.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class Chatscreen extends StatefulWidget {
  final String reciverId;
  final String userName;
  final String? userImage;
  final String chatId;

  const Chatscreen({
    super.key,
    required this.reciverId,
    required this.userName,
    this.userImage,
    required this.chatId,
  });

  @override
  State<Chatscreen> createState() => _ChatscreenState();
}

class _ChatscreenState extends State<Chatscreen> {
  TextEditingController messageController = TextEditingController();
  ChatController chatController = Get.put(ChatController());
  String senderId = FirebaseAuth.instance.currentUser!.uid;
  final ChatService _chatService = ChatService();

  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode ? "$user1-$user2" : "$user2-$user1";
  }

  @override
  void initState() {
    super.initState();
    listenForIncomingCalls();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.chatId, senderId);
  }

  void listenForIncomingCalls() {
    FirebaseFirestore.instance
        .collection("calls")
        .where("receiverID", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where("status", isEqualTo: "incoming")
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var callData = snapshot.docs.first.data();
        String callID = callData["callID"];
        String callerID = callData["callerID"];
        String callerName = callData["callerName"];
        bool isVideoCall = callData["isVideoCall"];

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Incoming ${isVideoCall ? "Video" : "Voice"} Call"),
            content: Text("$callerName is calling you..."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        // final callConfig = isVideoCall
                        //     ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                        //     : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
                        //   ..turnOnCameraWhenJoining = false
                        //   ..turnOnMicrophoneWhenJoining = true
                        //   ..useSpeakerWhenJoining = true;

                        // return ZegoUIKitPrebuiltCall(
                        //   appID: ZegoConfig.appID,
                        //   appSign: ZegoConfig.appSign,
                        //   callID: callID,
                        //   userID: FirebaseAuth.instance.currentUser!.uid,
                        //   userName:
                        //       FirebaseAuth.instance.currentUser!.displayName ??
                        //           "User",
                        //   plugins: [ZegoUIKitSignalingPlugin()],
                        //   config: callConfig,
                        // );
                        return Container(); // Temporary placeholder
                      },
                    ),
                  );
                },
                child: Text("Accept"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  FirebaseFirestore.instance
                      .collection("calls")
                      .doc(callID)
                      .update({
                    "status": "rejected",
                  });
                },
                child: Text("Reject"),
              ),
            ],
          ),
        );
      }
    });
  }

  void startCall(bool isVideoCall) {
    String callID = "call_${DateTime.now().millisecondsSinceEpoch}";
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    String userName = FirebaseAuth.instance.currentUser!.displayName ?? "User";

    // Create the call document in Firestore before starting the call
    FirebaseFirestore.instance.collection("calls").doc(callID).set({
      "callID": callID,
      "callerID": currentUserID,
      "callerName": userName,
      "receiverID": widget.reciverId,
      "isVideoCall": isVideoCall,
      "timestamp": DateTime.now(),
      "status":
          "incoming", // You can use status to track if the call is ongoing or missed
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        // final callConfig = isVideoCall
        //     ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
        //     : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
        //   ..turnOnCameraWhenJoining = false
        //   ..turnOnMicrophoneWhenJoining = true
        //   ..useSpeakerWhenJoining = true;

        // return ZegoUIKitPrebuiltCall(
        //   appID: ZegoConfig.appID,
        //   appSign: ZegoConfig.appSign,
        //   callID: callID,
        //   userID: currentUserID,
        //   userName: userName,
        //   plugins: [ZegoUIKitSignalingPlugin()],
        //   config: callConfig,
        // );
        return Container(); // Temporary placeholder
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    String chatId = getChatId(senderId, widget.reciverId);
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 21),
          child: Material(
            elevation: 1.5,
            shape: const CircleBorder(),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.purple),
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.userImage != null
                  ? NetworkImage(widget.userImage!)
                  : null,
              child: widget.userImage == null
                  ? Text(widget.userName[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  Text(
                    "Online",
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              startCall(false);
            },
            icon: const Icon(Icons.call, color: Colors.purple),
          ),
          IconButton(
            onPressed: () {
              startCall(true);
            },
            icon: const Icon(Icons.videocam, color: Colors.purple),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.purple),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .doc(widget.chatId)
                      .collection("messages")
                      .orderBy("timestamp", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No messages yet"));
                    }
                    var messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var messageData =
                            messages[index].data() as Map<String, dynamic>;

                        String text = messageData['text'] ?? '';

                        dynamic audioMedia = messageData.containsKey('audios')
                            ? messageData['audios']
                            : null;

                        dynamic imageMedia =
                            messageData.containsKey('image_media')
                                ? messageData['image_media']
                                : null;
                        dynamic videoMedia =
                            messageData.containsKey('video_media')
                                ? messageData['video_media']
                                : null;

                        List<dynamic> mediaList =
                            messageData.containsKey('multiple_media')
                                ? messageData['multiple_media']
                                : [];

                        List<String> mediaUrls = [];

                        if (imageMedia != null) {
                          if (imageMedia is List) {
                            mediaUrls
                                .addAll(imageMedia.map((e) => e.toString()));
                          } else {
                            mediaUrls.add(imageMedia.toString());
                          }
                        }

                        if (videoMedia != null) {
                          if (videoMedia is List) {
                            mediaUrls
                                .addAll(videoMedia.map((e) => e.toString()));
                          } else {
                            mediaUrls.add(videoMedia.toString());
                          }
                        }

                        if (audioMedia != null) {
                          if (audioMedia is List) {
                            mediaUrls
                                .addAll(audioMedia.map((e) => e.toString()));
                          } else {
                            mediaUrls.add(audioMedia.toString());
                          }
                        }

                        bool isMe = messageData['senderId'] == senderId;

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: Row(
                              mainAxisAlignment: isMe
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                ChatBubble(
                                  senderId: widget.reciverId,
                                  currentUser: senderId,
                                  text: text,
                                  mediaUrls: mediaUrls,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2),
                      ],
                    ),
                    child: Row(
                      children: [
                        GetBuilder<ChatController>(
                          builder: (chatController) {
                            return IconButton(
                              icon: Icon(
                                chatController.isRecording
                                    ? Icons.stop
                                    : Icons.mic,
                                color: purpal,
                              ),
                              onPressed: () {
                                if (chatController.isRecording) {
                                  chatController.stopRecording();
                                } else {
                                  chatController.startRecording();
                                }
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: purpal),
                          onPressed: () {
                            chatController.pickImageFromCamera();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library, color: purpal),
                          onPressed: () {
                            chatController.pickMultipleMedia();
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: TextField(
                              controller: messageController,
                              decoration: InputDecoration(
                                  hintText: "Type a message...",
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 15),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.send, color: purpal),
                                    onPressed: () {
                                      if (messageController.text.isNotEmpty) {
                                        chatController.sendMessage(
                                            senderId,
                                            widget.reciverId,
                                            messageController.text,
                                            widget.chatId);
                                        messageController.clear();
                                      }
                                      chatController.uploadMediaToChat(senderId,
                                          widget.reciverId, widget.chatId);
                                    },
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AudioMessageBubble extends StatelessWidget {
  final String audioUrl;
  final bool isMe;

  const AudioMessageBubble({
    super.key,
    required this.audioUrl,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Container(
              width: 100,
              height: 2,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text(
              "0:20",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
