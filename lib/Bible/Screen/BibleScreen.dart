import 'dart:convert';
import 'package:baseliae_flutter/Bible/Screen/ChapterListScreen.dart';
import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'BookdetailsScreen.dart';

class BookHomePage extends StatefulWidget {
  const BookHomePage({super.key});

  @override
  State<BookHomePage> createState() => _BookHomePageState();
}

class _BookHomePageState extends State<BookHomePage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  List<dynamic> allBooks = [];
  List<Map<String, dynamic>> recentlyRead = [];

  @override
  void initState() {
    super.initState();
    fetchAllBooks();
    loadRecentlyReadData();
  }

  Future<void> fetchAllBooks() async {
    final response = await http
        .get(Uri.parse('https://basillia.genzit.xyz/api/v1/books/all'));
    if (response.statusCode == 200) {
      setState(() {
        allBooks = json.decode(response.body);
      });
    }
  }

  Future<void> loadRecentlyReadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBookId = prefs.getString('lastReadBookId');

    if (savedBookId != null) {
      final savedBookName =
          prefs.getString('lastReadBookName_$savedBookId') ?? '';
      final savedChapter = prefs.getInt('lastReadChapter_$savedBookId') ?? 1;
      final totalChapters =
          prefs.getInt('lastReadTotalChapters_$savedBookId') ?? 1;
      final abbrev = prefs.getString('lastReadAbbrev_$savedBookId') ?? '';
      final language =
          prefs.getString('lastReadLanguage_$savedBookId') ?? 'English';

      setState(() {
        recentlyRead = [
          {
            '_id': savedBookId,
            'name': savedBookName,
            'currentChapter': savedChapter,
            'totalChapters': totalChapters,
            'abbrev': abbrev,
            'language': language,
            'fromRecentlyRead': true,
          }
        ];
      });
    }
  }

  Widget buildBookCard(dynamic book) {
    return GestureDetector(
      onTap: () {
        if (book['_id'] != null) {
          if (book['fromRecentlyRead'] == true) {
            Get.to(() => ChapterListPage(
                  bookId: book['_id'],
                  abbrev: book['abbrev'] ?? '',
                  name: book['name'] ?? '',
                  language: book['language'] ?? 'English',
                  totalChapters: book['totalChapters'] ?? 1,
                  selectedChapter: book['currentChapter'] ?? 1,
                ));
          } else {
            Get.to(() => BookDetailPage(bookId: book['_id']));
          }
        } else {
          Get.snackbar("Error", "Book ID is missing!");
        }
      },
      child: Container(
        height: 154,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 247, 242, 247),
        ),
        child: Row(
          children: [
            Container(
              width: 111,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://g.christianbook.com/dg/product/cbd/f400/160341.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(book['language'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Spacer(),
                  Text(
                      "Chapter ${book['currentChapter'] ?? 1} of ${book['totalChapters'] ?? 1}"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
        backgroundColor: whit,
        iconTheme: const IconThemeData(color: purpal),
        title: Text("Bible",
            style: robotostyle(const Color(0XFF343434), 18, FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.purple),
                      hintText: 'Search for books...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu_rounded, color: Colors.purple)),
              ],
            ),
            if (recentlyRead.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Continue Reading',
                      style: TextStyle(
                          color: const Color(0XFF343434),
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  Text("See More",
                      style: robotostyle(
                          const Color(0XFF808080), 14, FontWeight.w400)),
                ],
              ),
              ...recentlyRead.map(buildBookCard),
            ],
            const SizedBox(height: 20),
            const Text(
              'Suggested',
              style: TextStyle(
                color: Color(0XFF343434),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allBooks.length > 10 ? 10 : allBooks.length,
                itemBuilder: (context, index) {
                  final book = allBooks[index];
                  return GestureDetector(
                    onTap: () {
                      if (book['_id'] != null) {
                        Get.to(() => BookDetailPage(bookId: book['_id']));
                      }
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              image: DecorationImage(
                                image: NetworkImage(
                                  book['cover'] ??
                                      'https://g.christianbook.com/dg/product/cbd/f400/160341.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              book['name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Explore More',
                    style: TextStyle(
                        color: const Color(0XFF343434),
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
              ],
            ),
            ...allBooks.map((book) => buildBookCard({
                  '_id': book['_id'],
                  'name': book['name'],
                  'image_url': book['cover'] ?? '',
                  'currentChapter': book['currentChapter'] ?? 1,
                  'totalChapters': book['chapters'].length,
                })),
          ],
        ),
      ),
    );
  }
}
