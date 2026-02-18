import 'package:baseliae_flutter/Fatching/ProfileFatching/FatchingOwnersPost.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/AboutScreen.dart'
    show Aboutscreen;
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/PhotosScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Style/AppStyle.dart';

class ChurchProfileScreen extends StatefulWidget {
  const ChurchProfileScreen({super.key});

  @override
  State<ChurchProfileScreen> createState() => _ChurchProfileScreenState();
}

class _ChurchProfileScreenState extends State<ChurchProfileScreen>
    with SingleTickerProviderStateMixin {
  String churchName = Get.arguments['churchName'];
  String profileImage = Get.arguments['profileImage'];
  String coverImage = Get.arguments['coverImage'];
  String ownersName = Get.arguments['ownersName'];
  String churchLocation = Get.arguments['churchLocation'];
  String churchPageId = Get.arguments['churchPageId'];

  String followerscount = (Get.arguments['followerscount'] ?? 0).toString();
  String followingcount = (Get.arguments['followingcount'] ?? 0).toString();
  int postCount =
      int.tryParse(Get.arguments['postcount']?.toString() ?? '0') ?? 0;
  String about = Get.arguments['about'] ?? '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ChurchPages')
          .doc(churchPageId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var pageData = snapshot.data!;
        profileImage = pageData['profileImage'] ?? '';
        coverImage = pageData['coverImage'] ?? '';
        churchName = pageData['churchName'] ?? '';
        churchLocation = pageData['churchLocation'] ?? '';
        // ownersName = pageData['ownersName'] ?? '';

        return Scaffold(
          backgroundColor: whit,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: true,
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
                                image: coverImage.isEmpty
                                    ? AssetImage(
                                        "assets/images/default_cover.jpg")
                                    : CachedNetworkImageProvider(coverImage)
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
                                    onPressed: () => ShowCoveroptionforPage(
                                        context, churchPageId, coverImage),
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
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: black, width: 2),
                                image: DecorationImage(
                                  image:
                                      CachedNetworkImageProvider(profileImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 40,
                            left: 10,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: purpal),
                              onPressed: () => Get.back(),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  churchName,
                                  style:
                                      robotostyle(black, 18, FontWeight.bold),
                                ),
                                IconButton(
                                  icon:
                                      Icon(Icons.notifications, color: purpal),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                            Text(
                              churchLocation,
                              style:
                                  robotostyle(semigray, 13, FontWeight.normal),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Add a story or event
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: purpal,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text('+ Add Story',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      // Navigate to edit screen
                                    },
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit, color: purpal),
                                        SizedBox(width: 4),
                                        Text('Edit Page',
                                            style: TextStyle(color: purpal)),
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
                    color: const Color(0XFFF8F4F8),
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
                Fatchingownerspost(UserId: churchPageId),
                Photosscreen(
                  uid: churchPageId,
                ),
                // Text("Data"),

                Aboutscreen(
                  about: about,
                  location: churchLocation,
                  followerscount: followerscount,
                  followingcount: followingcount,
                  postcount: postCount.toString(),
                ),

                // FatchingChurchPosts(churchPageId: churchPageId),
                // ChurchPhotosScreen(churchPageId: churchPageId),
                // AboutChurchScreen(
                //   name: churchName,
                //   location: churchLocation,
                //   owner: ownersName,
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void showProfileOptionsBottomSheet(
    BuildContext context, String uid, String profilepic) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              icon: Icons.image,
              text: "View Profile Picture",
              color: Colors.black,
              onTap: () {},
            ),
            _buildOption(
              icon: Icons.upload,
              text: "Upload Profile Picture",
              color: Colors.black,
              onTap: () {},
            ),
            _buildOption(
              icon: Icons.delete,
              text: "Delete Profile Picture",
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet
              },
            ),
          ],
        ),
      );
    },
  );
}

void ShowCoveroptionforPage(BuildContext context, String uid, String coverpic) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption(
              icon: Icons.image,
              text: "View Cover Picture",
              color: Colors.black,
              onTap: () {},
            ),
            _buildOption(
              icon: Icons.upload,
              text: "Upload Cover Picture",
              color: Colors.black,
              onTap: () {},
            ),
            _buildOption(
              icon: Icons.delete,
              text: "Delete Cover Picture",
              color: Colors.red,
              onTap: () {},
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildOption({
  required IconData icon,
  required String text,
  required Color color,
  VoidCallback? onTap,
}) {
  return ListTile(
    leading: Icon(icon, color: color),
    title: Text(
      text,
      style: TextStyle(color: color, fontWeight: FontWeight.w500),
    ),
    onTap: onTap,
  );
}
