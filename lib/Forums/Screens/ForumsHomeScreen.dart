
import 'package:baseliae_flutter/Forums/ForumsController/DiscussionUploadingController.dart';

import 'package:baseliae_flutter/Forums/Screens/CreatQuestionScreen.dart';
import 'package:baseliae_flutter/Forums/Screens/ForumsSearchScreen.dart';
import 'package:baseliae_flutter/Forums/Widgets/ForumPostCard.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Forumshomescreen extends StatefulWidget {
  const Forumshomescreen({super.key});

  @override
  State<Forumshomescreen> createState() => _ForumshomescreenState();
}

class _ForumshomescreenState extends State<Forumshomescreen> {
  final List<String> categories = [
    'General',
    'Bible',
    'Question',
    'Motivation'
  ];
  String selectedCategory = 'General';

  final TextEditingController searchController = TextEditingController();

  final DiscussionUploadingController discussionUploadingController =
      Get.put(DiscussionUploadingController()); 

     

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(Icons.arrow_back, color: Colors.purple),
        ),
        title: Text(
          "Forums",
          style: robotostyle(black, 24, FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => Get.to(() => Creatquestionscreen()),
              child: Icon(Icons.add_circle, color: Colors.purple, size: 32),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: searchController,
              onTap: (){
                Get.to(() => ForumSearchScreen());
              },
              decoration: InputDecoration(
                hintText: "Search Question..",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

         
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      
                      });
                     
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? pinkish
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.purple : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16),

         

          

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Forums')
                  .where('category', isEqualTo: selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No posts found in $selectedCategory'));
                }

                final forumDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: forumDocs.length,
                  itemBuilder: (context, index) {
                    final forumData = forumDocs[index];
                    final userId = forumData['userId'];
                   

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) return SizedBox();

                        

                        return ForumPostCard(forumData: forumData,);

                       
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
