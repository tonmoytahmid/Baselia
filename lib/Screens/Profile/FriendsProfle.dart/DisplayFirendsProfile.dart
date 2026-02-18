import 'package:baseliae_flutter/Component/ContainerComponent.dart';
import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
import 'package:baseliae_flutter/Fatching/ProfileFatching/FatchingOwnersPost.dart';
import 'package:baseliae_flutter/Screens/Message/New%20chat/ChatScreen.dart';

import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/AboutScreen.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/PhotosScreen.dart';
import 'package:baseliae_flutter/Service/FollowService.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Displayfirendsprofile extends StatefulWidget {
  String? FrienduId;
  Displayfirendsprofile({super.key, required this.FrienduId});

  @override
  State<Displayfirendsprofile> createState() => _DisplayfirendsprofileState();
}

class _DisplayfirendsprofileState extends State<Displayfirendsprofile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final FollowService _followService = FollowService();
  final Relationshipcontroller relationshipcontroller =
      Get.put(Relationshipcontroller());

  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool isFriend = false;
  bool isRequested = false;

  Future<void> checkFriendStatus() async {
    // ignore: unnecessary_null_comparison
    if (currentUser!.uid == null) return;

    Map<String, bool> status =
        await _followService.checkFriendStatus(widget.FrienduId.toString());

    if (mounted) {
      setState(() {
        isFriend = status['isFriend'] ?? false;
        isRequested = status['isRequested'] ?? false;
      });
    }
  }

  Future<void> sendFollowRequest() async {
    await _followService.sendFollowRequest(widget.FrienduId.toString());
    await checkFriendStatus();
  }

  Future<void> cancelFollowRequest() async {
    await _followService.cancelFollowRequest(widget.FrienduId.toString());
    await checkFriendStatus();
  }

  Future<void> createChat(List<Map<String, dynamic>> members, String senderId,
      String receiverId) async {
    String getChatId(String user1, String user2) {
      return user1.hashCode <= user2.hashCode
          ? "$user1-$user2"
          : "$user2-$user1";
    }

    try {
      String chatId = getChatId(senderId, receiverId);

      User? currentUser = auth.currentUser;
      if (currentUser == null) return;

      await firestore.collection('chats').doc(chatId).set({
        'chatId': chatId,
        'isGroup': false,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'members': members,
        'membersIds': members.map((m) => m['id']).toList(),
      });

      Get.to(() => Chatscreen(
            reciverId:
                members.firstWhere((m) => m['id'] != currentUser.uid)['id'],
            userName: members
                .firstWhere((m) => m['id'] != currentUser.uid)['fullName'],
            userImage: members
                .firstWhere((m) => m['id'] != currentUser.uid)['profileImage'],
            chatId: chatId,
          ));
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    checkFriendStatus();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: whit,
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.FrienduId)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var userData = userSnapshot.data!.data() as Map<String, dynamic>?;

            if (userData == null) {
              return Center(child: Text('User not found!'));
            }

            // User details
            String name = userData['fullName'] ?? 'No Name';
            String uid = userData['uid'];
            String bio = userData['bio'] ?? 'No Bio';
            String profilepic = userData['profileImage'] ?? '';
            String coverpic = userData['coverImage'] ?? '';
            int followersCount = userData['followersCount'] ?? 0;
            int followingCount = userData['followingCount'] ?? 0;
            int postCount = userData['postCount'] ?? 0;
            String abo = userData['about'] ?? 'No Bio';
            String loc = userData['location'] ?? 'No Bio';
            String accountType = userData['accountType'];

            List<Map<String, dynamic>> members = [
              {
                'id': auth.currentUser!.uid,
                'fullName': auth.currentUser!.displayName ?? "You",
                'profileImage': auth.currentUser!.photoURL ?? "",
              },
              {
                'id': uid,
                'fullName': name,
                'profileImage': profilepic,
              }
            ];

            return CustomScrollView(slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                backgroundColor: whit,
                expandedHeight: 310,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              color: semigray,
                              border: Border.all(
                                color: black,
                              ),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  coverpic,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            left: 20,
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 249, 248, 248),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      icon: Icon(
                                        Icons.arrow_back_outlined,
                                        color: purpal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 40,
                            right: 10,
                            child: Row(
                              children: [
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 249, 248, 248),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: purpal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 250,
                        left: 20,
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: semigray,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: black,
                              ),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  profilepic,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                  delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Text(name,
                                      style: robotostyle(
                                          black, 16, FontWeight.w600)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  if (accountType == 'Celebrities / VIPs')
                                    Image.asset(
                                      'assets/images/CelebrityUserbage.png',
                                      height: 20,
                                    ),
                                  if (accountType == 'Church Leader')
                                    Image.asset(
                                      'assets/images/Chargeleaderbage.png',
                                      height: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(bio,
                                  style: robotostyle(
                                      semigray, 12, FontWeight.w500)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_active_outlined,
                                  color: semigray,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('Followers ${formatCount(followersCount)}',
                              style: robotostyle(purpal, 12, FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 140,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: purpal,
                                backgroundColor: Colors.white,
                                side: const BorderSide(color: purpal),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                if (isFriend) {
                                  // Handle unfollowing logic
                                  relationshipcontroller
                                      .removeFollowerAndFollowing(
                                          widget.FrienduId.toString());
                                  relationshipcontroller.removeFollower(
                                      widget.FrienduId.toString());
                                  setState(() {
                                    isFriend = false;
                                  });
                                } else if (isRequested) {
                                  // Handle canceling request logic
                                  cancelFollowRequest();
                                } else {
                                  // Send follow request
                                  sendFollowRequest();
                                }
                              },
                              child: Text(
                                isFriend
                                    ? 'Unfollow'
                                    : isRequested
                                        ? 'Requested'
                                        : 'Follow',
                                style: TextStyle(color: purpal),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 140,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: purpal),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () {
                                createChat(members, auth.currentUser!.uid,
                                    widget.FrienduId.toString());
                              },
                              child: Text('Message'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  color: Color(0XFFF8F4F8),
                  child: TabBar(
                    indicatorColor: purpal,
                    labelColor: purpal,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Posts'),
                      Tab(text: 'Photos'),
                      Tab(text: 'About'),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: TabBarView(
                    children: [
                      Fatchingownerspost(UserId: widget.FrienduId),
                      Photosscreen(
                        uid: widget.FrienduId,
                      ),
                      Aboutscreen(
                        about: abo,
                        location: loc,
                        followerscount: followersCount.toString(),
                        followingcount: followingCount.toString(),
                        postcount: postCount.toString(),
                      ),
                    ],
                  ),
                ),
              ]))
            ]);
          },
        ),
      ),
    );
  }
}
