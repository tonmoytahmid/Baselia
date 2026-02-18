import 'package:baseliae_flutter/Screens/Profile/FriendsProfle.dart/DisplayFirendsProfile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Searchscreen extends StatefulWidget {
  const Searchscreen({super.key});

  @override
  State<Searchscreen> createState() => _SearchscreenState();
}

class _SearchscreenState extends State<Searchscreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    final result = await FirebaseFirestore.instance
        .collection('Users') // Replace with your Firestore collection name
        .where('fullName', isGreaterThanOrEqualTo: query)
        .where('fullName', isLessThan: '$query\uf8ff')
        .get();

    setState(() {
      _searchResults = result.docs.map((doc) {
        return {
          'uid': doc.id, // Firestore document ID (User UID)
          'fullName': doc['fullName'],
          'profileImage':
              doc['profileImage'], // Make sure your Firestore has this field
        };
      }).toList();
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
              controller: _searchController,
                onEditingComplete: () =>
                                FocusScope.of(context).unfocus(),
                            onTapOutside: (event) =>
                                FocusScope.of(context).unfocus(),
              onChanged:
                  _searchUsers, // Call the search function when user types
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
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profileImage'] != null
                        ? NetworkImage(user['profileImage'])
                        : const AssetImage('assets/default_user.png')
                            as ImageProvider,
                  ),
                  title: Text(user['fullName']),
                  onTap: () {
                    Get.to(() => Displayfirendsprofile(
                        FrienduId: user['uid'])); // Return UID on tap
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
