import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:timeago/timeago.dart' as timeago;

class Fatchingfollowings extends StatefulWidget {
  const Fatchingfollowings({super.key});

  @override
  State<Fatchingfollowings> createState() => _FatchingfollowingsState();
}

class _FatchingfollowingsState extends State<Fatchingfollowings> {
  Relationshipcontroller relationshipcontroller = Get.put(Relationshipcontroller());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: relationshipcontroller.getFollowing(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Following",style: TextStyle(color: purpal,fontSize: 14,),));
        }

        var followingList = snapshot.data!;

        return ListView.builder(
          itemCount: followingList.length,
          itemBuilder: (context, index) {
            var following = followingList[index];
            
            
            final receiverId = following['receiverId'] ?? ''; 

            if (receiverId.isEmpty) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.error)),
                title: Text('Invalid user ID'),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Users').doc(receiverId).get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Loading...'),
                  );
                }

                if (!userSnapshot.hasData || userSnapshot.data!.data() == null) {
                  return const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.error)),
                    title: Text('User not found'),
                  );
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                final fullName = userData['fullName'] ?? 'Unknown User';
                final profileImage = userData['profileImage'];

               
               String timeAgo = "Unknown time";
                if (following.containsKey('timestamp')) {
                  final timestamp = following['timestamp'] as Timestamp;
                  timeAgo = formatTimestamp(timestamp);
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                      child: profileImage == null ? Text(fullName[0].toUpperCase()) : null,
                    ),
                    title: Text(fullName),
                    subtitle: Text(timeAgo),
                    trailing: GestureDetector(
                      onTap: () {
                        showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 116,
                                  width: 236,
                                  child: AlertDialog(
                                    elevation: 20,
                                    backgroundColor: whit,
                                    content: Text(
                                      textAlign: TextAlign.center,
                                      "Are you sure you want to Unfollow the user?",
                                      style: robotostyle(
                                          black, 14, FontWeight.w400),
                                    ),
                                    actions: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Cancel",
                                              style: robotostyle(semigray, 16,
                                                  FontWeight.w600),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () async{
                                              Navigator.pop(context);
                                        await relationshipcontroller.removeFollowerAndFollowing(receiverId);
                                            },
                                            child: Text(
                                              "Confirm",
                                              style: robotostyle(
                                                  purpal, 16, FontWeight.w600),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                      },
                      child: Container(
                        height: 28,
                        width: 68,
                        decoration: BoxDecoration(
                          color: purpal,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            "Unfollow",
                            style: ButtonTextStyle(whit, 12, FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
String formatTimestamp(Timestamp timestamp) {
    return timeago.format(timestamp.toDate());
  }