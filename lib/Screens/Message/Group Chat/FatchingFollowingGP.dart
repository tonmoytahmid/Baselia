import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:baseliae_flutter/Controller/RelationshipController/RelationshipController.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';

class Fatchingfollowinggp extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectionChanged;

  const Fatchingfollowinggp({super.key, required this.onSelectionChanged});

  @override
  State<Fatchingfollowinggp> createState() => _FatchingfollowinggpState();
}

class _FatchingfollowinggpState extends State<Fatchingfollowinggp> {
  Relationshipcontroller relationshipcontroller = Get.put(Relationshipcontroller());
  List<Map<String, dynamic>> selectedUsers = [];

  void _toggleSelection(String userId, Map<String, dynamic> userData) {
    setState(() {
      bool isSelected = selectedUsers.any((user) => user['id'] == userId);

      if (isSelected) {
        selectedUsers.removeWhere((user) => user['id'] == userId);
      } else {
        selectedUsers.add(userData);
      }

      widget.onSelectionChanged(selectedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: relationshipcontroller.getFollowing(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No Following", style: TextStyle(color: purpal, fontSize: 14)),
          );
        }

        var followingList = snapshot.data!;

        return ListView.builder(
          itemCount: followingList.length,
          itemBuilder: (context, index) {
            var following = followingList[index];
            final userId = following['receiverId'] ?? '';

            if (userId.isEmpty) {
              return const ListTile(
                leading: CircleAvatar(child: Icon(Icons.error)),
                title: Text('Invalid user ID'),
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
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

                bool isSelected = selectedUsers.any((user) => user['id'] == userId);

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ListTile(
                    onTap: () => _toggleSelection(userId, {
                      'id': userId,
                      'fullName': fullName,
                      'profileImage': profileImage,
                    }),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImage != null ? NetworkImage(profileImage) : null,
                      child: profileImage == null ? Text(fullName[0].toUpperCase()) : null,
                    ),
                    title: Text(fullName,style: robotostyle(black, 14, FontWeight.w500),),
                    trailing: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? Colors.purple : Colors.grey,
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
