
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Groupchatsearch extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onSelectionChanged;
  const Groupchatsearch({super.key, required this.onSelectionChanged});

  @override
  State<Groupchatsearch> createState() => _GroupchatsearchState();
}

class _GroupchatsearchState extends State<Groupchatsearch> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
 String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final result = await FirebaseFirestore.instance
        .collection('Users') // Replace with your Firestore collection name
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: '$query\uf8ff')
        .get();

    setState(() {
      _searchResults = result.docs .where((doc) => doc.id != currentUserId) .map((doc) {
        return {
          'uid': doc.id, // Firestore document ID (User UID)
          'fullName': doc['fullName'],
          'profileImage':
              doc['profileImage'], // Make sure your Firestore has this field
        };
      }).toList();
    });
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.only(left: 21),
          child: Material(
            elevation: 1.5,
            shape: const CircleBorder(),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.purple),
              ),
            ),
          ),
        ),
        title: const Text(
          "Search",
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
              controller: _searchController,
              onChanged:
                  _searchUsers, 
              decoration: InputDecoration(
                fillColor: Colors.grey[200],
                filled: true,
                contentPadding: const EdgeInsets.all(12),
                hintText: "Search users...",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Search results list
          Expanded(
            child:ListView.builder(
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
           
            final user = _searchResults[index];

                final fullName = user['fullName'] ?? 'Unknown User';
                final profileImage = user['profileImage'];
                final userId = user['uid'];
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
                    ? Colors.purple
                    : Colors.grey,
              ),
            );
          },
        )
          ),
        ],
      ),
    );
  }
}
