import 'package:baseliae_flutter/Models/ChargePageModel.dart';
import 'package:baseliae_flutter/Repository/ChurchPageRepo.dart';
import 'package:baseliae_flutter/Screens/Profile/ChurchpageProfile/ChurchpageProfile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FetchChurchPages extends StatelessWidget {
  final String userId;
  const FetchChurchPages({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChurchPageModel>>(
      stream: fetchChurchPagesFromUserGroups(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No church pages found.'));
        }

        final churchPages = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: churchPages.length,
          itemBuilder: (context, index) {
            final page = churchPages[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(page.profileImage),
              ),
              title: Text(page.churchName),
              subtitle: Text(page.churchLocation),
              onTap: () {
                Get.to(() => ChurchProfileScreen(), arguments: {
                  'churchPageId': page.churchPageId,
                  'churchName': page.churchName,
                  'coverImage': page.coverImage,
                  'profileImage': page.profileImage,
                  'ownersName': page.ownersName,
                  'churchLocation': page.churchLocation,
                  'followerscount': page.followersCount,
                  'followingcount': page.followingCount,
                  'postcount': page.postCount,
                  'about': page.about,
                });

                // Get.toNamed('/churchpage_detail', arguments: {
                //   'churchPageId': page.churchPageId,
                //   'churchName': page.churchName,
                //   'coverImage': page.coverImage,
                //   'profileImage': page.profileImage,
                //   'ownersName': page.ownersName,
                //   'churchLocation': page.churchLocation,
                // });
              },
            );
          },
        );
      },
    );
  }
}
