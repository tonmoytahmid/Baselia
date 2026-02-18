import 'package:baseliae_flutter/Fatching/ProfileFatching/FatchingOwnersPost.dart';
import 'package:baseliae_flutter/Helper/ProfileHelper.dart';
import 'package:baseliae_flutter/Repository/UserRepo.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/AboutScreen.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/PhotosScreen.dart';
import 'package:baseliae_flutter/Screens/Settings/UpdateProfileInfoScreen.dart';
import 'package:baseliae_flutter/Screens/Story/CreatStoryScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:get/get.dart';

class Profilescreen extends StatefulWidget {
  const Profilescreen({super.key});

  @override
  State<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends State<Profilescreen>
    with SingleTickerProviderStateMixin {
  String name = Get.arguments['fullname'];
  String bio = Get.arguments['bio'];
  String profilepics = Get.arguments['profilepic'];
  String coverpics = Get.arguments['coverpic'];
  String uid = Get.arguments['uid'];
  String location = Get.arguments['location'];
  String followerscount = (Get.arguments['followerscount'] ?? 0).toString();
  String followingcount = (Get.arguments['followingcount'] ?? 0).toString();
  int followersCount =
      int.tryParse(Get.arguments['followerscount']?.toString() ?? '0') ?? 0;
  int followingCount =
      int.tryParse(Get.arguments['followingcount']?.toString() ?? '0') ?? 0;
  int postCount =
      int.tryParse(Get.arguments['postcount']?.toString() ?? '0') ?? 0;
  String about = Get.arguments['about'];
  String accountType = Get.arguments['accountType'];

  String profilepic = '';
  String coverpic = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    fetchProfilePic(uid).then((value) {
      setState(() {
        profilepic = value;
      });
    });

    fetchCoverPic(uid).then((value) {
      setState(() {
        coverpic = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance.collection('Users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data!;
          profilepic = userData['profileImage'] ?? '';
          coverpic = userData['coverImage'] ?? '';

          return DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: whit,
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: false,
                    expandedHeight: 460,
                    backgroundColor: whit,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 220,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: coverpic.isEmpty
                                        ? AssetImage(
                                            "assets/images/default_cover.jpg")
                                        : CachedNetworkImageProvider(coverpic)
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                  top: 170,
                                  right: 20,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: black,
                                      ),
                                    ),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () =>
                                            showCoverOptionsBottomSheet(
                                                context, uid, coverpic),
                                        icon: Icon(
                                          Icons.add_a_photo,
                                          color: semigray,
                                        ),
                                      ),
                                    ),
                                  )),
                              Positioned(
                                top: 180,
                                left: 20,
                                child: GestureDetector(
                                  onTap: () => showProfileOptionsBottomSheet(
                                      context, uid, profilepic),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(color: black, width: 2),
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                            profilepic),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
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
                          const SizedBox(height: 60),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(name,
                                            style: robotostyle(
                                                black, 18, FontWeight.bold)),
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
                                    IconButton(
                                      icon: Icon(
                                        Icons.notifications_active_outlined,
                                        color: semigray,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ],
                                ),
                                if (bio.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(bio,
                                      style: robotostyle(
                                          semigray, 13, FontWeight.normal)),
                                ],
                                const SizedBox(height: 10),
                                Text(
                                  'Followers ${formatCount(followersCount)}',
                                  style:
                                      robotostyle(purpal, 13, FontWeight.w500),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Get.to(() => StoryUploadScreen());
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: purpal,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Text('+ Add Story',
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Get.to(
                                              () => Updateprofileinfoscreen());
                                        },
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit, color: purpal),
                                            SizedBox(width: 4),
                                            Text('Edit Profile',
                                                style:
                                                    TextStyle(color: purpal)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(50),
                      child: Container(
                        color: Color(0XFFF8F4F8),
                        child: TabBar(
                          controller: _tabController,
                          indicatorColor: purpal,
                          labelColor: purpal,
                          unselectedLabelColor: Colors.grey,
                          tabs: const [
                            Tab(text: 'Posts'),
                            Tab(text: 'Photos'),
                            Tab(text: 'About'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    Fatchingownerspost(UserId: uid),
                    Photosscreen(uid: uid),
                    Aboutscreen(
                      about: about,
                      location: location,
                      followerscount: followerscount,
                      followingcount: followingcount,
                      postcount: postCount.toString(),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

String formatCount(int count) {
  if (count >= 1000) {
    double formattedCount = count / 1000;
    return "${formattedCount.toStringAsFixed(1)}K";
  }
  return count.toString();
}
