import 'package:baseliae_flutter/Bible/Screen/BibleScreen.dart';
import 'package:baseliae_flutter/Controller/MenueController/UsersessionController.dart';
import 'package:baseliae_flutter/Forums/Screens/ForumsHomeScreen.dart';
import 'package:baseliae_flutter/Helper/MenuItemList.dart';
import 'package:baseliae_flutter/Screens/Menu/DonationScreen.dart';
import 'package:baseliae_flutter/Screens/Pages/RequestScreen.dart';
import 'package:baseliae_flutter/Screens/Settings/SettingsScreen.dart';
import 'package:baseliae_flutter/Screens/Switchprofle/SwitchprofileScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Fatchingmenuitems extends StatefulWidget {
  const Fatchingmenuitems({super.key});

  @override
  State<Fatchingmenuitems> createState() => _FatchingmenuitemsState();
}

class _FatchingmenuitemsState extends State<Fatchingmenuitems> {
  final List<MenuItem> menuItems = [
    MenuItem(title: 'Groups', icon: Icons.group),
    MenuItem(title: 'Donation', icon: Icons.volunteer_activism),
    MenuItem(title: 'Bible', icon: Icons.menu_book),
    MenuItem(title: 'Church Pages', icon: Icons.church),
    MenuItem(title: 'Activity', icon: Icons.analytics),
    MenuItem(title: 'Forums', icon: Icons.forum),
    MenuItem(title: 'Connections', icon: Icons.group),
    MenuItem(title: 'Notification', icon: Icons.notifications),
    MenuItem(title: 'Switch Profile', icon: Icons.switch_account),
    MenuItem(title: 'Settings', icon: Icons.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.2,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Container(
            height: 60,
            width: 170,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black.withOpacity(0.1)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _handleNavigation(context, index);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(item.icon, size: 30, color: purpal),
                    SizedBox(height: 10),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void _handleNavigation(BuildContext context, int index) {
  switch (index) {
    // case 0:
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => GroupsScreen()));
    //   break;
    case 1:
      Get.to(() => Donationscreen(),
          transition: Transition.leftToRightWithFade,
          duration: Duration(seconds: 1));
      break;
    case 2:
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => BookHomePage()));
      break;
    // case 3:
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => ChurchPagesScreen()));
    //   break;
    // case 4:
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => ActivityScreen()));
    //   break;
    case 5:
      Get.to(() => Forumshomescreen(),
          transition: Transition.leftToRightWithFade,
          duration: Duration(seconds: 1));
      break;
    case 6:
      Get.to(() => Requestscreen(),
          transition: Transition.leftToRightWithFade,
          duration: Duration(seconds: 1));
      break;
    // case 7:
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen()));
    //   break;
    case 8:
      // Get.find<MenuControllers>().switchToProfile(true);
      // Get.off(() => SwitchProfileScreen());
      _openChurchPageSelector(context);

      break;

    case 9:
      Get.to(() => Settingscreen(),
          transition: Transition.rightToLeftWithFade,
          duration: Duration(seconds: 1));
      break;
    default:
      break;
  }
}

void _openChurchPageSelector(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userDoc =
      await FirebaseFirestore.instance.collection('Users').doc(uid).get();

  // Get the list of church page document IDs the user is linked to
  List<dynamic> churchPageIds = userDoc['groups'] ?? [];

  if (churchPageIds.isEmpty) {
    Get.snackbar("No Pages", "You don't have any church pages to switch to.");
    return;
  }

  List<Map<String, dynamic>> churchPages = [];

  for (String pageId in churchPageIds) {
    final doc = await FirebaseFirestore.instance
        .collection('ChurchPages')
        .doc(pageId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      data['docId'] = doc.id; // Add document ID manually
      churchPages.add(data);
    }
  }

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: churchPages.length,
        itemBuilder: (_, index) {
          final page = churchPages[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(page['profileImage'] ?? ''),
            ),
            title: Text(page['churchName'] ?? 'Unnamed Church'),
            subtitle: Text(page['churchLocation'] ?? ''),
            onTap: () {
              // ✅ Switch session using document ID
              final selectedPageId = page['docId'];

              Get.find<UserSessionController>().switchToChurchPage(
                selectedPageId,
                {
                  'name': page['churchName'],
                  'image': page['profileImage'],
                  'location': page['churchLocation'],
                },
              );

              Get.back(); // Close bottom sheet
              Get.off(() => SwitchProfileScreen()); // Navigate to switch screen
            },
          );
        },
      ),
    ),
  );
}
