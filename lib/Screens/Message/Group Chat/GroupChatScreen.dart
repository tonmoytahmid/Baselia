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

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<Map<String, dynamic>> members;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.members,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  TextEditingController messageController = TextEditingController();
  ChatController chatController = Get.put(ChatController());
  final ChatService _chatService = ChatService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    _chatService.markMessagesAsRead(widget.groupId, currentUserId);
  }

  void _startGroupCall(bool isVideoCall) {
    String callID = "call_${DateTime.now().millisecondsSinceEpoch}";
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;
    String userName = FirebaseAuth.instance.currentUser!.displayName ?? "User";

    // Create the call document in Firestore before starting the call
    FirebaseFirestore.instance.collection("calls").doc(callID).set({
      "callID": callID,
      "callerID": currentUserID,
      "callerName": userName,
      "groupID": widget.groupId,
      "isVideoCall": isVideoCall,
      "timestamp": DateTime.now(),
      "status": "incoming", // Track call status
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        // final callConfig = isVideoCall
        //     ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
        //     : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
        //       ..useSpeakerWhenJoining = true;

        // return ZegoUIKitPrebuiltCall(
        //   appID: ZegoConfig.appID,
        //   appSign: ZegoConfig.appSign,
        //   callID: callID,
        //   userID: currentUserID,
        //   userName: userName,
        //   plugins: [],
        //   config: callConfig,
        // );
        return Container(); // Temporary placeholder
      }),
    );
  }

  // Function to listen for incoming group calls
  void _listenForIncomingGroupCalls() {
    FirebaseFirestore.instance
        .collection("calls")
        .where("groupID", isEqualTo: widget.groupId)
        .where("status", isEqualTo: "incoming")
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        var callData = snapshot.docs.first.data();
        String callID = callData["callID"];
        String callerID = callData["callerID"];
        String callerName = callData["callerName"];
        bool isVideoCall = callData["isVideoCall"];

        // Show dialog only if the current user is NOT the caller
        if (callerID != currentUserId) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("Incoming ${isVideoCall ? "Video" : "Voice"} Call"),
              content: Text("$callerName is calling your group..."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          // final callConfig = isVideoCall
                          //     ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
                          //     : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
                          //       ..useSpeakerWhenJoining = true;

                          // return ZegoUIKitPrebuiltCall(
                          //   appID: ZegoConfig.appID,
                          //   appSign: ZegoConfig.appSign,
                          //   callID: callID,
                          //   userID: currentUserId,
                          //   userName: FirebaseAuth.instance.currentUser!.displayName ?? "User",
                          //   plugins: [],
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenForIncomingGroupCalls();
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        backgroundColor: whit,
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
                "https://cdn-icons-png.flaticon.com/512/847/847969.png"),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName, style: TextStyle(fontSize: 18)),
            Text(
              widget.members.isNotEmpty
                  ? widget.members
                      .map((e) => e['fullName'].toString())
                      .join(", ")
                  : "No members found",
              style: TextStyle(fontSize: 12, color: black),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _startGroupCall(false);
            },
            icon: const Icon(Icons.call, color: Colors.purple),
          ),
          IconButton(
            onPressed: () {
              _startGroupCall(true);
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
                      .doc(widget.groupId)
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

                        bool isMe = messageData['senderId'] ==
                            FirebaseAuth.instance.currentUser!.uid;

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
                                  senderId: widget.groupId,
                                  currentUser:
                                      FirebaseAuth.instance.currentUser!.uid,
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
                        IconButton(
                          icon: const Icon(Icons.mic, color: purpal),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: purpal),
                          onPressed: () {},
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
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            widget.groupId,
                                            messageController.text,
                                            widget.groupId);
                                        messageController.clear();
                                      }
                                      chatController.uploadMediaToChat(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          widget.groupId,
                                          widget.groupId);
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
