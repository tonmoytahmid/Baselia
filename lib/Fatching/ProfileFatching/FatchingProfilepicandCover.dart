// import 'package:baseliae_flutter/Models/UserModel.dart';
// import 'package:baseliae_flutter/Repository/UserRepo.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'package:flutter/material.dart';
//
// class Fatchingprofilepicandcover extends StatefulWidget {
//
//   const Fatchingprofilepicandcover({super.key});
//
//   @override
//   State<Fatchingprofilepicandcover> createState() => _FatchingprofilepicandcoverState();
// }
//
// class _FatchingprofilepicandcoverState extends State<Fatchingprofilepicandcover> {
//   User? user = FirebaseAuth.instance.currentUser;
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Usermodel?>(
//
//        future: getUser(user!.uid),
//        builder: (context, snapshot) {
//          if (snapshot.connectionState == ConnectionState.waiting) {
//            return Center(child: CircularProgressIndicator());
//          }
//          if (snapshot.hasError) {
//            return Center(child: Text('Error: ${snapshot.error}'));
//          }
//          if (!snapshot.hasData || snapshot.data == null) {
//            return Center(child: Text('User not found.'));
//          }
//          final userData = snapshot.data!;
//          return Container(
//            child: Stack(children: [
//              Container(
//                width: double.infinity,
//                height: 200,
//                decoration: BoxDecoration(
//                  image: DecorationImage(
//                    image: NetworkImage(userData.coverImage),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//              Container(
//                width: 100,
//                height: 100,
//                decoration: BoxDecoration(
//                  shape: BoxShape.circle,
//                  image: DecorationImage(
//                    image: NetworkImage(userData.profileImage),
//                    fit: BoxFit.cover,
//                  ),
//                ),
//              ),
//          ]));
//        });
//   }
// }