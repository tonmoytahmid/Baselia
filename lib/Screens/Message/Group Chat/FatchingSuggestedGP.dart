import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FetchingSuggestedGP extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectionChanged;

  const FetchingSuggestedGP({super.key, required this.onSelectionChanged});

  @override
  State<FetchingSuggestedGP> createState() => _FetchingSuggestedGPState();
}

class _FetchingSuggestedGPState extends State<FetchingSuggestedGP> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> selectedUsers = []; // Store selected users

  void _toggleSelection(String userId, Map<String, dynamic> userData) {
    setState(() {
      bool isSelected = selectedUsers.any((user) => user['id'] == userId);

      if (isSelected) {
        selectedUsers.removeWhere((user) => user['id'] == userId);
      } else {
        selectedUsers.add(userData);
      }

      // Send selected users to parent widget
      widget.onSelectionChanged(selectedUsers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').
       where('uid', isNotEqualTo: auth.currentUser!.uid). snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No users found",style: TextStyle(color: purpal,fontSize: 14),));
        }

        var usersList = snapshot.data!.docs;

        return ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            var userData = usersList[index].data() as Map<String, dynamic>;
            final userId = usersList[index].id;
            final fullName = userData['fullName'] ?? 'Unknown User';
            final profileImage = userData['profileImage'];

            return ListTile(
              onTap: () => _toggleSelection(userId, {
                'id': userId,
                'fullName': fullName,
                'profileImage': profileImage,
              }),
              title: Text(fullName,style: robotostyle(black, 14, FontWeight.w500),),
              leading: CircleAvatar(
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null ? Text(fullName[0].toUpperCase()) : null,
              ),
              trailing: Icon(
                selectedUsers.any((user) => user['id'] == userId)
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: selectedUsers.any((user) => user['id'] == userId)
                    ? purpal
                    : Colors.grey,
              ),
            );
          },
        );
      },
    );
  }
}
