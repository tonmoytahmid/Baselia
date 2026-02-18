import 'package:baseliae_flutter/Controller/PostController/UploadcoverImage.dart';
import 'package:baseliae_flutter/Controller/PostController/UploadprofileImage.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/UploadCoverScreen.dart';
import 'package:baseliae_flutter/Screens/Profile/OwnersProfile.dart/UploadprofileScreen.dart';
import 'package:baseliae_flutter/Widgets/Posting/FullScreenImageview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String formatCount(int count) {
  if (count >= 1000) {
    double formattedCount = count / 1000;
    return "${formattedCount.toStringAsFixed(1)}K";
  }
  return count.toString();
}

void showProfileOptionsBottomSheet(
    BuildContext context, String uid, String profilepic) {
  final Uploadprofileimage uploadprofileimage = Get.put(Uploadprofileimage());

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
              onTap: () {
                Get.to(() => FullScreenImageView(
                      imageUrl: profilepic,
                    ));
              },
            ),
            _buildOption(
              icon: Icons.upload,
              text: "Upload Profile Picture",
              color: Colors.black,
              onTap: () {
                Get.to(() => Uploadprofilescreen(), arguments: {'uid': uid});
              },
            ),
            _buildOption(
              icon: Icons.delete,
              text: "Delete Profile Picture",
              color: Colors.red,
              onTap: () async {
                Navigator.pop(context); // Close bottom sheet

                await uploadprofileimage.deleteUserProfileImage(
                  uid,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

void showCoverOptionsBottomSheet(
    BuildContext context, String uid, String coverpic) {
  final UploadcoverImage uploadcoverimage = Get.put(UploadcoverImage());
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
              onTap: () {
                Get.to(() => FullScreenImageView(
                      imageUrl: coverpic,
                    ));
              },
            ),
            _buildOption(
              icon: Icons.upload,
              text: "Upload Cover Picture",
              color: Colors.black,
              onTap: () {
                Get.to(() => Uploadcoverscreen(), arguments: {'uid': uid});
              },
            ),
            _buildOption(
              icon: Icons.delete,
              text: "Delete Cover Picture",
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                uploadcoverimage.deleteUserCoverImage(
                  uid,
                );
              },
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