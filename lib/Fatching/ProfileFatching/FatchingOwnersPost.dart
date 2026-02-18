import 'package:baseliae_flutter/Controller/PostController/FatchingOwnwerspostController.dart';

import 'package:baseliae_flutter/Widgets/Posting/PostCardWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class Fatchingownerspost extends StatefulWidget {
  String?UserId;
   Fatchingownerspost({super.key,required this.UserId});

  @override
  State<Fatchingownerspost> createState() => _FatchingownerspostState();
}

class _FatchingownerspostState extends State<Fatchingownerspost> {
  FetchingOwnerPostController fatchingpostcontroller =
      Get.put(FetchingOwnerPostController());
FirebaseAuth auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        
        future: fatchingpostcontroller.fetchOwnerPosts(widget.UserId!), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts available"));
          }

          return ListView.builder(
           
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return PostCard(post: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}
