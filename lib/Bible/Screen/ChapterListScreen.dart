import 'dart:convert';
import 'package:baseliae_flutter/Bible/Models/VerseModel.dart';

import 'package:baseliae_flutter/Style/AppStyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterListPage extends StatefulWidget {
  final String abbrev;
  final String language;
  final int totalChapters;
  final String? name;
  final int? selectedChapter;
  final String bookId;

  const ChapterListPage({
    super.key,
    required this.abbrev,
    required this.language,
    required this.totalChapters,
    required this.name,
    this.selectedChapter = 1,
    required this.bookId,
  });

  @override
  State<ChapterListPage> createState() => _ChapterListPageState();
}

class _ChapterListPageState extends State<ChapterListPage> {
  int? selectedChapter = 1;
  Future<versemodel>? versesFuture;
  bool showChapters = true;
  bool isDarkMode = false;
  List<String> savedVerses = [];

  Map<String, Set<int>> highlightedVerseIdsPerBookChapter = {};

  // Map<int, Set<int>> highlightedVerseIdsPerChapter = {};
  late ScrollController _scrollController;
  double fontSize = 14;

  static const String savedVersesKey = 'savedVerses';
  static const String highlightedVersesKey = 'highlightedVerses';
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    selectedChapter = widget.selectedChapter ?? 1;

    loadSavedData().then((_) {
      setState(() {
        versesFuture = fetchVerses(selectedChapter!);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedChapter != null) {
        double offset = (widget.selectedChapter! - 1) * 70.0;
        _scrollController.jumpTo(offset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Future<void> loadSavedData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final saved = prefs.getStringList(savedVersesKey) ?? [];
  //   final highlightedJson = prefs.getString('highlightedVersesJson') ?? '{}';

  //   setState(() {
  //     savedVerses = saved;

  //     final Map<String, dynamic> decodedMap = json.decode(highlightedJson);

  //     highlightedVerseIdsPerChapter = decodedMap.map((key, value) => MapEntry(
  //         int.parse(key),
  //         (value as List<dynamic>).map((e) => e as int).toSet()));
  //   });
  // }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(savedVersesKey) ?? [];
    final highlightedJson = prefs.getString(highlightedVersesKey) ?? '{}';

    setState(() {
      savedVerses = saved;
      final Map<String, dynamic> decodedMap = json.decode(highlightedJson);
      highlightedVerseIdsPerBookChapter = decodedMap.map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>).map((e) => e as int).toSet(),
        ),
      );
      print("Highlight Map loaded: $highlightedVerseIdsPerBookChapter");
    });
  }

  // Future<void> saveHighlightedVerses() async {

  //   final prefs = await SharedPreferences.getInstance();

  //   final Map<String, List<int>> mapToSave = highlightedVerseIdsPerChapter.map(
  //     (key, value) => MapEntry(key.toString(), value.toList()),
  //   );

  //   await prefs.setString('highlightedVersesJson', json.encode(mapToSave));
  // }

  Future<void> saveHighlightedVerses() async {
    final prefs = await SharedPreferences.getInstance();

    final Map<String, List<int>> mapToSave =
        highlightedVerseIdsPerBookChapter.map(
      (key, value) => MapEntry(key, value.toList()),
    );

    await prefs.setString(highlightedVersesKey, json.encode(mapToSave));
  }

  Future<void> saveSavedVerses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(savedVersesKey, savedVerses);
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
    final langCode = mapLanguageToCode(widget.language);
    final url =
        'https://basillia.genzit.xyz/api/v1/books/bible/verses?language=$langCode&abbrev=${widget.abbrev}&chapter=$chapter';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return versemodel.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load verses');
    }
  }

  void shareVerse(String text) {
    Share.share(text);
  }

  void changeChapter(int delta) {
    if (selectedChapter == null) {
      setState(() {
        selectedChapter = 1;
        versesFuture = fetchVerses(1);
      });
    } else {
      final newChap = selectedChapter! + delta;
      if (newChap >= 1 && newChap <= widget.totalChapters) {
        setState(() {
          selectedChapter = newChap;
          versesFuture = fetchVerses(newChap);
        });
      }
    }
  }

  Future<void> toggleHighlightVerse(int verseId) async {
    final chapter = selectedChapter ?? 1;
    final key = '${widget.bookId}_$chapter'; // unique key per book + chapter

    setState(() {
      final highlightedSet = highlightedVerseIdsPerBookChapter[key] ?? <int>{};
      final newSet = Set<int>.from(highlightedSet);

      if (newSet.contains(verseId)) {
        newSet.remove(verseId);
      } else {
        newSet.add(verseId);
      }

      highlightedVerseIdsPerBookChapter[key] = newSet;
    });

    await saveHighlightedVerses(); // Save after state update
    print(
        "Toggled highlight for $key => ${highlightedVerseIdsPerBookChapter[key]}");
  }

  bool isVerseHighlighted(int verseId) {
    final chapter = selectedChapter ?? 1;
    final key = '${widget.bookId}_$chapter';
    return highlightedVerseIdsPerBookChapter[key]?.contains(verseId) ?? false;
  }

  // void toggleHighlightVerse(int verseId) {
  //   final chapter = selectedChapter ?? 1;

  //   setState(() {
  //     final highlightedSet = highlightedVerseIdsPerChapter[chapter] ?? <int>{};

  //     if (highlightedSet.contains(verseId)) {
  //       highlightedSet.remove(verseId);
  //     } else {
  //       highlightedSet.add(verseId);
  //     }
  //     highlightedVerseIdsPerChapter[chapter] = highlightedSet;
  //   });

  //   saveHighlightedVerses();
  // }

  void saveVerse(String verseText) {
    if (!savedVerses.contains(verseText)) {
      setState(() {
        savedVerses.add(verseText);
      });
      saveSavedVerses(); // save persistently
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verse saved')),
      );
    }
  }

  void showSavedVersesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Saved Verses',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(Icons.bookmark, color: Colors.purple),
          ],
        ),
        content: savedVerses.isEmpty
            ? const Text('No verses saved yet.',
                style: TextStyle(color: Colors.grey))
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: savedVerses.length,
                  itemBuilder: (context, index) {
                    final verse = savedVerses[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          verse,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.share, color: Colors.green),
                              tooltip: 'Share',
                              onPressed: () => shareVerse(verse),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete',
                              onPressed: () {
                                setState(() {
                                  savedVerses.removeAt(index);
                                });
                                saveSavedVerses();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Verse removed')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void increaseFontSize() {
    setState(() {
      fontSize = (fontSize + 2).clamp(12, 24);
    });
  }

  void decreaseFontSize() {
    setState(() {
      fontSize = (fontSize - 2).clamp(12, 24);
    });
  }

  Future<void> saveLastReadData({
    required String bookId,
    required int chapter,
    required String bookName,
    required int totalChapters,
    required String abbrev,
    required String language,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastReadBookId', bookId); // Save bookId
    await prefs.setInt('lastReadChapter_$bookId', chapter);
    await prefs.setString('lastReadBookName_$bookId', bookName);
    await prefs.setInt('lastReadTotalChapters_$bookId', totalChapters);
    await prefs.setString('lastReadAbbrev_$bookId', abbrev); // Save abbrev
    await prefs.setString(
        'lastReadLanguage_$bookId', language); // Save language
    await prefs.setString(
      'lastReadTimestamp_$bookId',
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langCode = mapLanguageToCode(widget.language);
    final theme = isDarkMode ? ThemeData.dark() : ThemeData.light();

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        appBar: AppBar(
          backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
          title: Text("Bible › ${widget.name}",
              style: robotostyle(
                  isDarkMode ? Colors.white : const Color(0XFF343434),
                  20,
                  FontWeight.w600)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  showChapters = !showChapters;
                });
              },
              child: Text(
                showChapters ? "Hide Options" : "Show Options",
                style: robotostyle(Colors.purple, 16, FontWeight.w400),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showChapters)
                SizedBox(
                  height: 70,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    itemCount: widget.totalChapters,
                    itemBuilder: (context, index) {
                      final chap = index + 1;
                      final isSelected = chap == selectedChapter;
                      return GestureDetector(
                        onTap: () async {
                          await loadSavedData();

                          setState(() {
                            selectedChapter = chap;
                            versesFuture = fetchVerses(chap);
                          });

                          await saveLastReadData(
                            bookId: widget.bookId,
                            chapter: selectedChapter!,
                            bookName: widget.name ?? '',
                            totalChapters: widget.totalChapters,
                            abbrev: widget.abbrev,
                            language: widget.language,
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              const Text("Chap",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.purple
                                      : Colors.purple.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "$chap",
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.purple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (showChapters) const Divider(),
              Expanded(
                child: selectedChapter == null
                    ? Center(
                        child: Text(
                          "Tap on a chapter to view verses",
                          style: GoogleFonts.lora(
                              fontSize: 18, color: Colors.grey[600]),
                        ),
                      )
                    : FutureBuilder<versemodel>(
                        future: versesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.hasData) {
                            final verses = snapshot.data!.data ?? [];
                            if (verses.isEmpty) {
                              return const Center(
                                  child: Text('No verses found'));
                            }

                            String fullVersesText = verses
                                .map((v) => '${v.id} ${v.verse}')
                                .join('  ');

                            return Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            ' Chapter $selectedChapter',
                                            style: GoogleFonts.lora(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: verses.map((verse) {
                                            final currentChapter =
                                                selectedChapter ?? 1;
                                            // final isHighlighted =
                                            //     highlightedVerseIdsPerChapter[
                                            //                 currentChapter]
                                            //             ?.contains(verse.id) ??
                                            //         false;

                                            final isHighlighted =
                                                isVerseHighlighted(
                                                    verse.id ?? 0);

                                            return GestureDetector(
                                              onTap: () => toggleHighlightVerse(
                                                  verse.id!.toInt()),
                                              onLongPress: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                    title: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons.menu_book,
                                                            color:
                                                                Colors.purple),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(
                                                            "Verse ${verse.id} Options"),
                                                      ],
                                                    ),
                                                    content: Text(
                                                      verse.verse ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                    actions: [
                                                      ElevatedButton.icon(
                                                        icon: const Icon(
                                                            Icons.copy),
                                                        label:
                                                            const Text("Copy"),
                                                        onPressed: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      '${verse.id} ${verse.verse}'));
                                                          Navigator.of(context)
                                                              .pop();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                                content: Text(
                                                                    'Verse copied')),
                                                          );
                                                        },
                                                      ),
                                                      ElevatedButton.icon(
                                                        icon: const Icon(
                                                          Icons.bookmark_add,
                                                          color: Colors.white,
                                                        ),
                                                        label: const Text(
                                                          "Save",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.deepPurple,
                                                        ),
                                                        onPressed: () {
                                                          saveVerse(
                                                            verse.verse ?? '',
                                                          );
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      ElevatedButton.icon(
                                                        icon: const Icon(
                                                          Icons.share,
                                                          color: Colors.white,
                                                        ),
                                                        label: const Text(
                                                          "Share",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                        onPressed: () {
                                                          shareVerse(
                                                              '${verse.id} ${verse.verse}');
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: const Text(
                                                            "Cancel"),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6,
                                                        horizontal: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: isHighlighted
                                                      ? Colors.purple
                                                          .withOpacity(0.15)
                                                      : Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.05),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    )
                                                  ],
                                                ),
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: GoogleFonts.lora(
                                                      fontSize: fontSize,
                                                      height: 1.6,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.black87,
                                                    ),
                                                    children: [
                                                      WidgetSpan(
                                                        alignment:
                                                            PlaceholderAlignment
                                                                .middle,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 6),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.purple
                                                                .shade300,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                            verse.id.toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TextSpan(
                                                          text: verse.verse ??
                                                              ''),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        Divider(
                                          color: Colors.grey[300],
                                          thickness: 1,
                                          height: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Pagination Controls
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Chapter: $selectedChapter",
                                        style: robotostyle(Color(0XFF878E9E),
                                            12, FontWeight.w500),
                                      ),
                                      Row(
                                        children: [
                                          // Back Button
                                          ElevatedButton.icon(
                                            onPressed:
                                                selectedChapter != null &&
                                                        selectedChapter! > 1
                                                    ? () => changeChapter(-1)
                                                    : null,
                                            icon: const Icon(Icons.arrow_back),
                                            label: const Text("Back"),
                                          ),
                                          const SizedBox(
                                              width:
                                                  10), // spacing between buttons
                                          // Next Button
                                          ElevatedButton.icon(
                                            onPressed:
                                                selectedChapter != null &&
                                                        selectedChapter! <
                                                            widget.totalChapters
                                                    ? () => changeChapter(1)
                                                    : null,
                                            icon:
                                                const Icon(Icons.arrow_forward),
                                            label: const Text("Next"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return const Center(child: Text('No verses found'));
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 10,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                    onPressed: showSavedVersesDialog,
                    icon: const Icon(Icons.bookmark, color: Colors.purple)),
                // ElevatedButton.icon(
                //   icon: const Icon(Icons.bookmark),
                //   label: const Text('Saved'),
                //   onPressed: showSavedVersesDialog,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.purple,
                //     padding:
                //         const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   ),
                // ),
                IconButton(
                  icon: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  tooltip: 'Toggle Dark Mode',
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields, color: Colors.purple),
                  onPressed: () {
                    // Toggle font size between 14 and 20
                    if (fontSize == 14) {
                      setState(() {
                        fontSize = 20;
                      });
                    } else {
                      setState(() {
                        fontSize = 14;
                      });
                    }
                  },
                  tooltip: 'Toggle Font Size',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.purple),
                  onSelected: (value) {
                    if (value == 'copy_all') {
                      Clipboard.setData(
                          ClipboardData(text: savedVerses.join('\n\n')));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('All saved verses copied')),
                      );
                    } else if (value == 'share_all') {
                      Share.share(savedVerses.join('\n\n'));
                    } else if (value == 'clear_all') {
                      setState(() {
                        savedVerses.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved verses cleared')),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'copy_all',
                      child: Text('Copy all saved verses'),
                    ),
                    const PopupMenuItem(
                      value: 'share_all',
                      child: Text('Share all saved verses'),
                    ),
                    const PopupMenuItem(
                      value: 'clear_all',
                      child: Text('Clear all saved verses'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
