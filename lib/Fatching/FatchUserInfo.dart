import 'package:baseliae_flutter/Models/UserModel.dart';
import 'package:baseliae_flutter/Repository/UserRepo.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Fatchuserinfo extends StatefulWidget {
  const Fatchuserinfo({super.key});

  @override
  State<Fatchuserinfo> createState() => _FatchuserinfoState();
}

class _FatchuserinfoState extends State<Fatchuserinfo> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Usermodel?>(
      stream: getUserStream(user!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('User not found.'));
        }

        final userData = snapshot.data!;
        return GestureDetector(
          onTap: () {
            Get.toNamed('/profile', arguments: {
              'profilepic': userData.profileImage,
              'coverpic': userData.coverImage,
              'fullname': userData.fullName,
              'bio': userData.bio,
              'about': userData.about,
              'uid': userData.uid,
              'location': userData.location,
              'followerscount': userData.followersCount,
              'followingcount': userData.followingCount,
              'postcount': userData.postCount,
              'accountType': userData.accountType
            });
          },
          child: ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(userData.profileImage),
            ),
            title: Row(
              children: [
                Text(
                  userData.fullName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                if (userData.accountType == 'Celebrities / VIPs')
                  Image.asset(
                    'assets/images/CelebrityUserbage.png',
                    height: 20,
                  ),
                if (userData.accountType == 'Church Leader')
                  Image.asset(
                    'assets/images/Chargeleaderbage.png',
                    height: 20,
                  ),
              ],
            ),
            subtitle: Text(userData.email),
          ),
        );
      },
    );
  }
}
