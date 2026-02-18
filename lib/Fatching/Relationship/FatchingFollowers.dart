import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:timeago/timeago.dart' as timeago;

class Fatchingfollowers extends StatefulWidget {
  const Fatchingfollowers({super.key});

  @override
  State<Fatchingfollowers> createState() => _FatchingfollowersState();
}

class _FatchingfollowersState extends State<Fatchingfollowers> {
  Relationshipcontroller relationshipcontroller =
      Get.put(Relationshipcontroller());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: relationshipcontroller.getFollowers(),
      builder: (context, snapshot) {

         if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
         if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No Followers",style: TextStyle(color: purpal,fontSize: 14,),));
        }
        var requests = snapshot.data!;

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index];
           final timestamp = request['timestamp'] is Timestamp
    ? request['timestamp'] as Timestamp
    : Timestamp.now();
            // ignore: unused_local_variable
            final timeAgo = formatTimestamp(timestamp);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(request['senderId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const ListTile(
                    leading: CircleAvatar(),
                    title: Text('Loading...'),
                  );
                }

                if (!userSnapshot.hasData ||
                    userSnapshot.data!.data() == null) {
                  return const ListTile(
                    leading: CircleAvatar(child: Icon(Icons.error)),
                    title: Text('User not found'),
                  );
                }

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final fullName = userData['fullName'] ?? 'Unknown User';
                final profileImage = userData['profileImage'];
                // ignore: unused_local_variable

                final timeAgo = formatTimestamp(timestamp);

                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 48,
                      backgroundImage: profileImage != null
                          ? NetworkImage(profileImage)
                          : null,
                      child: profileImage == null
                          ? Text(fullName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(timeAgo),
                        if (request['message'] != null)
                          Text(request['message']),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
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
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await relationshipcontroller
                                                  .removeFollower(
                                                      request['senderId']);
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
                                borderRadius: BorderRadius.circular(18)),
                            child: Center(
                                child: Text(
                              "Unfollow",
                              style: ButtonTextStyle(whit, 12, FontWeight.w500),
                            )),
                          ),
                        ),
                      ],
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
  return timeago.format(timestamp.toDate(), locale: 'en');
}
