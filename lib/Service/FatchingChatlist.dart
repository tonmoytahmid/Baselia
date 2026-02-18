import 'package:baseliae_flutter/Screens/Message/Group%20Chat/GroupChatScreen.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/ChatScreen.dart';
import 'package:baseliae_flutter/Service/Chatservice.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatListScreen extends StatelessWidget {
  final ChatService _chatService = ChatService();

  ChatListScreen({super.key});

  String _formatLastMessageTime(Timestamp timestamp) {
    return timeago.format(timestamp.toDate());
  }

  Future<bool> _isLastMessageRead(String chatId) async {
    try {
      var messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      
      if (messagesSnapshot.docs.isNotEmpty) {
        return messagesSnapshot.docs.first['read'] ?? false;
      }
    } catch (e) {
      print("Error fetching read status: $e");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatService.getChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No chats available"));
        }

       var chats = List<Map<String, dynamic>>.from(snapshot.data!)
  ..sort((a, b) {
    Timestamp timeA = (a['lastMessageTime'] ?? Timestamp.now()) as Timestamp;
    Timestamp timeB = (b['lastMessageTime'] ?? Timestamp.now()) as Timestamp;
    return timeB.compareTo(timeA);
  });

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chat = chats[index];
            bool isGroup = chat['isGroup'];
            String chatName = isGroup ? chat['groupName'] : "Unknown User";
            String receiverId = "", receiverImage = "";

            if (!isGroup && chat['members'] != null) {
              var otherMember = (chat['members'] as List)
                  .firstWhere((m) => m['id'] != _chatService.currentUserId, orElse: () => null);
              if (otherMember != null) {
                chatName = otherMember['fullName'] ?? "Unknown User";
                receiverId = otherMember['id'] ?? "";
                receiverImage = otherMember['profileImage'] ?? "";
              }
            }

            Timestamp lastMessageTime = chat['lastMessageTime'] ?? Timestamp.now();
            String lastMessageTimeAgo = _formatLastMessageTime(lastMessageTime);

            return FutureBuilder<bool>(
              future: _isLastMessageRead(chat['chatId']),
              builder: (context, readSnapshot) {
                bool isRead = readSnapshot.data ?? false;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      isGroup
                          ? "https://cdn-icons-png.flaticon.com/512/847/847969.png"
                          : receiverImage,
                    ),
                  ),
                  title: Text(chatName),
                  subtitle: Text(
                    chat['lastMessage'] ?? 'No messages yet',
                    style: robotostyle(isRead ? black : semigray, 12, FontWeight.w400),
                  ),
                  trailing: Text(
                    lastMessageTimeAgo,
                    style: robotostyle(semigray, 12, FontWeight.w400),
                  ),
                  onTap: () {
                    isGroup
                        ? Get.to(() => GroupChatScreen(
                              groupId: chat['chatId'],
                              groupName: chat['groupName'],
                              members: List<Map<String, dynamic>>.from(chat['members']),
                            ))
                        : Get.to(() => Chatscreen(
                              reciverId: receiverId,
                              userName: chatName,
                              userImage: receiverImage,
                              chatId: chat['chatId'],
                            ));
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}