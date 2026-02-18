import 'package:baseliae_flutter/Bible/Models/SingleBookModel.dart';
import 'package:baseliae_flutter/Bible/Models/VerseModel.dart';

import 'package:baseliae_flutter/Bible/Screen/ChapterListScreen.dart';
import 'package:baseliae_flutter/Bible/Widgets/PercentindicatorWidget.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Paste your singelbook and Chapters class here...
class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  singelbook? book;
  bool isLoading = true;
  Color bg = Color(0XFF343434);
  versemodel? lastReadVerses;
  int lastReadChapter = 1;
  String lastReadBookName = '';
  String lastReadVerse = '';
  DateTime? lastReadTime;
  int? savedTotalChapters;
  int? lastReadTotalChapters;
  String lastReadAbbrev = 'gn';
  String lastReadLanguage = 'eng';
  String lastReadBookId = '';
  @override
  void initState() {
    super.initState();
    loadLastReadData();
    fetchBookDetail();
    fetchLastReadChapter();
  }

  String mapLanguageToCode(String language) {
    switch (language.toLowerCase()) {
      case 'english':
        return 'en';
      case 'french':
        return 'fr';
      case 'spanish':
        return 'es';
      default:
        return 'en';
    }
  }

  Future<versemodel> fetchVerses(int chapter) async {
    if (book == null || book!.chapters == null || book!.chapters!.isEmpty) {
      throw Exception("Book or chapters not loaded yet.");
    }

    final langCode = mapLanguageToCode(book!.language ?? 'fr');
    final abbrev = book!.abbrev ?? 'gn'; // fallback if abbrev is null

    final url =
        'https://basillia.genzit.xyz/api/v1/books/bible/verses?language=$langCode&abbrev=$abbrev&chapter=$chapter';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return versemodel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load verses');
    }
  }

  Future<void> fetchBookDetail() async {
    final url = 'https://basillia.genzit.xyz/api/v1/books/${widget.bookId}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        book = singelbook.fromJson(data);
        isLoading = false;
      });
      await loadLastReadData();
      await fetchLastReadChapter(); // fetch verses after book load
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchLastReadChapter() async {
    try {
      final abbrev = book?.abbrev ?? 'gn';
      final language = book?.language ?? 'fr';
      final langCode = mapLanguageToCode(language);
      final totalChapters = book?.chapters?.length ?? 0;

      for (int i = totalChapters; i >= 1; i--) {
        final chapterBook = book?.chapters?[i - 1];
        final currentBookId = chapterBook?.sId ?? '';

        final url =
            'https://basillia.genzit.xyz/api/v1/books/bible/verses?language=$langCode&abbrev=$abbrev&chapter=$i';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final jsonBody = json.decode(response.body);
          final verseData = versemodel.fromJson(jsonBody);

          final hasRead =
              verseData.data?.any((v) => v.verse?.trim().isNotEmpty ?? false) ??
                  false;

          if (hasRead) {
            print('Chapter $i has been read');
            setState(() {
              lastReadTotalChapters = verseData.chapters ?? 0;
              lastReadChapter = i;
              lastReadVerses = verseData;
            });

            await saveLastReadData(
              bookId: currentBookId,
              chapter: i,
              bookName: chapterBook!.name ?? '',
              verseText: verseData.data?.first.verse ?? '',
              // Pass total chapters
            );

            break;
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching last read chapter: $e");
    }
  }

  Future<void> saveLastReadData({
    required String bookId,
    required int chapter,
    required String bookName,
    required String verseText,
    // required int latestReadTotalChapters,  // added parameter
    // added parameter
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastReadChapter_$bookId', chapter);
    await prefs.setString('lastReadBookName_$bookId', bookName);
    await prefs.setString('lastReadVerseText_$bookId', verseText);
    await prefs.setString(
        'lastReadTimestamp_$bookId', DateTime.now().toIso8601String());
    // await prefs.setInt('lastReadTotalChapters_$bookId', latestReadTotalChapters);

    await prefs.setInt(
        'lastReadTotalChapters_$bookId', book?.chapters?.length ?? 1);
    await prefs.setString('lastReadAbbrev_$bookId', book?.abbrev ?? 'gn');
    await prefs.setString('lastReadLanguage_$bookId', book?.language ?? 'eng');
    await prefs.setString('lastReadBookId', bookId);
  }

  Future<void> loadLastReadData() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBookId = prefs.getString('lastReadBookId');

    if (savedBookId != null) {
      final savedChapter = prefs.getInt('lastReadChapter_$savedBookId');
      final savedBookName = prefs.getString('lastReadBookName_$savedBookId');
      final savedTimestamp = prefs.getString('lastReadTimestamp_$savedBookId');
      final savedTotalChapters =
          prefs.getInt('lastReadTotalChapters_$savedBookId');
      final savedAbbrev = prefs.getString('lastReadAbbrev_$savedBookId');
      final savedLanguage = prefs.getString('lastReadLanguage_$savedBookId');

      if (savedChapter != null) {
        setState(() {
          lastReadChapter = savedChapter;
          lastReadBookName = savedBookName ?? '';
          lastReadTime =
              savedTimestamp != null ? DateTime.parse(savedTimestamp) : null;
          lastReadTotalChapters = savedTotalChapters ?? 1;
          lastReadAbbrev = savedAbbrev ?? 'gn';
          lastReadLanguage = savedLanguage ?? 'eng';
          lastReadBookId = savedBookId;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastReadChapterName = (book?.chapters != null &&
            lastReadChapter >= 1 &&
            lastReadChapter <= book!.chapters!.length)
        ? book!.chapters![lastReadChapter - 1].name
        : null;

    double percentage = 0;

    percentage = lastReadTotalChapters != null && lastReadTotalChapters! > 0
        ? (lastReadChapter / lastReadTotalChapters!).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: whit,
      appBar: AppBar(
          backgroundColor: whit,
          iconTheme: const IconThemeData(color: purpal),
          centerTitle: true,
          title: Text(
            "Bible",
            style: robotostyle(bg, 18, FontWeight.w600),
          )),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : book == null
              ? const Center(child: Text("Failed to load book"))
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Continue Reading",
                              style: robotostyle(bg, 20, FontWeight.w600)),
                          Text("See More",
                              style: robotostyle(
                                  Color(0XFF808080), 14, FontWeight.w400)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 111,
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(
                                  'https://g.christianbook.com/dg/product/cbd/f400/160341.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    book!.name ?? 'No Name',
                                    style: TextStyle(
                                        color: bg,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.end,
                                // crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Total Books: ${book!.chapters?.length ?? 0}",
                                    style: robotostyle(
                                        Color(0XFF808080), 12, FontWeight.w400),
                                  ),
                                  SizedBox(width: 20),
                                  BookProgressWidget(
                                    percentRead: percentage,
                                  )
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Last reading - ${lastReadBookName ?? ''} '
                                'Chapter $lastReadChapter\n',
                                style: robotostyle(
                                    Color(0XFF808080), 12, FontWeight.w400),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  if (lastReadChapter >= 1 &&
                                      lastReadTotalChapters! >=
                                          lastReadChapter) {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterListPage(
                                          bookId: lastReadBookId.isNotEmpty
                                              ? lastReadBookId
                                              : widget.bookId,
                                          name: lastReadBookName,
                                          abbrev: lastReadAbbrev,
                                          language: lastReadLanguage,
                                          totalChapters:
                                              lastReadTotalChapters ?? 1,
                                          selectedChapter: lastReadChapter,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      await loadLastReadData();
                                      await fetchLastReadChapter();
                                      if (mounted) setState(() {});
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'No last read chapter found')),
                                    );
                                  }
                                },
                                child: Container(
                                  height: 40,
                                  width: 186,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: purpal,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Continue',
                                    style:
                                        robotostyle(whit, 14, FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: book!.chapters?.length ?? 0,
                          itemBuilder: (context, index) {
                            final chapterBook = book!.chapters![index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                height: 85,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 241, 233, 241),
                                  // borderRadius: BorderRadius.circular(),
                                ),
                                child: ListTile(
                                  title: Text(
                                    chapterBook.name ?? 'Chapter',
                                    style: robotostyle(Color(0XFF1E2022), 17.73,
                                        FontWeight.w600),
                                  ),
                                  subtitle: Text(
                                    " ${chapterBook.chapters ?? 0} Chapters",
                                    style: robotostyle(Color(0XFF77838F), 12.01,
                                        FontWeight.w400),
                                  ),
                                  trailing: Container(
                                      width: 104.84,
                                      height: 34.09,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        "Explore",
                                        style: robotostyle(Color(0XFF77838F),
                                            11.93, FontWeight.w700),
                                      )),
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterListPage(
                                          bookId: chapterBook.sId ?? '',
                                          name: chapterBook.name ?? 'Chapter',
                                          abbrev: chapterBook.abbrev ?? 'gn',
                                          language: book?.language ?? 'fr',
                                          totalChapters:
                                              chapterBook.chapters ?? 1,
                                        ),
                                      ),
                                    );

                                    if (result == true) {
                                      await loadLastReadData();
                                      await fetchLastReadChapter();
                                      if (mounted) setState(() {});
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
