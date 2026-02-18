// // import 'dart:convert';
// import 'dart:convert';

// import 'package:baseliae_flutter/Bible/Models/VerseModel.dart';
// import 'package:baseliae_flutter/Style/AppStyle.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // for Clipboard
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:share_plus/share_plus.dart';

// class ChapterListPage extends StatefulWidget {
//   final String abbrev;
//   final String language;
//   final int totalChapters;
//   final String? name;

//   const ChapterListPage({
//     Key? key,
//     required this.abbrev,
//     required this.language,
//     required this.totalChapters,
//     required this.name,
//   }) : super(key: key);

//   @override
//   State<ChapterListPage> createState() => _ChapterListPageState();
// }

// class _ChapterListPageState extends State<ChapterListPage> {
//   int? selectedChapter;
//   Future<versemodel>? versesFuture;
//   bool showChapters = true;

//   String mapLanguageToCode(String language) {
//     switch (language.toLowerCase()) {
//       case 'english':
//         return 'en';
//       case 'french':
//         return 'fr';
//       case 'spanish':
//         return 'es';
//       default:
//         return 'en';
//     }
//   }

//   Future<versemodel> fetchVerses(int chapter) async {
//     final langCode = mapLanguageToCode(widget.language);
//     final url =
//         'https://basillia.genzit.xyz/api/v1/books/bible/verses?language=$langCode&abbrev=${widget.abbrev}&chapter=$chapter';
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final jsonBody = json.decode(response.body);
//       return versemodel.fromJson(jsonBody);
//     } else {
//       throw Exception('Failed to load verses');
//     }
//   }

//   void shareVerse(String text) {
//     Share.share(text);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final langCode = mapLanguageToCode(widget.language);

//     return Scaffold(
//       appBar: AppBar(
//         iconTheme: IconThemeData(color: Colors.purple),
//         title: Text("Bible › ${widget.name}",style: robotostyle(Color(0XFF343434), 20, FontWeight.w600),),
//         actions: [
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 showChapters = !showChapters;
//               });
//             },
//             child: Text(
//               showChapters ? "Hide Options" : "Show Options",
//               style: robotostyle(purpal, 16, FontWeight.w400),
//             ),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(top: 12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Horizontal chapter list
//             if (showChapters)
//               SizedBox(
//                 height: 70,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.totalChapters,
//                   itemBuilder: (context, index) {
//                     final chap = index + 1;
//                     final isSelected = chap == selectedChapter;
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedChapter = chap;
//                           versesFuture = fetchVerses(chap);
//                         });
//                       },
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                         child: Column(
//                           children: [
//                             const Text(
//                               "Chap",
//                               style:
//                                   TextStyle(fontSize: 12, color: Colors.grey),
//                             ),
//                             const SizedBox(height: 4),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 12, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? Colors.purple
//                                     : Colors.purple.shade100,
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 "$chap",
//                                 style: TextStyle(
//                                   color:
//                                       isSelected ? Colors.white : Colors.purple,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             if (showChapters) const Divider(),

//             // Verses preview
//             Expanded(
//               child: selectedChapter == null
//                   ? Center(
//                       child: Text(
//                         "Tap on a chapter to view verses",
//                         style: GoogleFonts.lora(
//                             fontSize: 18, color: Colors.grey[600]),
//                       ),
//                     )
//                   : FutureBuilder<versemodel>(
//                       future: versesFuture,
//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         } else if (snapshot.hasError) {
//                           return Center(
//                               child: Text('Error: ${snapshot.error}'));
//                         } else if (snapshot.hasData) {
//                           final verses = snapshot.data!.data ?? [];
//                           if (verses.isEmpty) {
//                             return const Center(child: Text('No verses found'));
//                           }

//                           // Prepare full verses text to copy
//                           String fullVersesText = verses
//                               .map((v) => '${v.id} ${v.verse}')
//                               .join('  ');

//                           return SingleChildScrollView(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 8),
//                             child: Column(
//                               children: [
//                                 Text(
//                                   ' Chapter ${selectedChapter}',
//                                   style: GoogleFonts.lora(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 16),
//                                 GestureDetector(
//                                   onLongPress: () {
//                                     showDialog(
//                                       context: context,
//                                       builder: (context) => AlertDialog(
//                                         title: const Text("Options"),
//                                         content: const Text(
//                                             "Copy, highlight, or more options"),
//                                         actions: [
//                                           TextButton(
//                                             onPressed: () {
//                                               Clipboard.setData(ClipboardData(
//                                                   text: fullVersesText));
//                                               Navigator.of(context).pop();
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                     content: Text(
//                                                         'Copied all verses')),
//                                               );
//                                             },
//                                             child: const Text("Copy"),
//                                           ),
//                                           TextButton(
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                     content: Text(
//                                                         'Highlight not implemented')),
//                                               );
//                                             },
//                                             child: const Text("Highlight"),
//                                           ),
//                                           IconButton(
//                                             icon: const Icon(Icons.more_vert),
//                                             onPressed: () {
//                                               Navigator.of(context).pop();
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                     content: Text(
//                                                         'More options clicked')),
//                                               );
//                                             },
//                                           )
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                   child: SelectableText.rich(
//                                     TextSpan(
//                                       style: GoogleFonts.lora(
//                                         fontSize: 14,
//                                         height: 1.6,
//                                         color: Colors.black87,
//                                       ),
//                                       children: [
//                                         for (int i = 0;
//                                             i < verses.length;
//                                             i++) ...[
//                                           WidgetSpan(
//                                             alignment:
//                                                 PlaceholderAlignment.middle,
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       horizontal: 8,
//                                                       vertical: 6),
//                                               margin: const EdgeInsets.only(
//                                                   right: 8),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.purple.shade100,
//                                                 borderRadius:
//                                                     BorderRadius.circular(6),
//                                               ),
//                                               child: Text(
//                                                 verses[i].id.toString(),
//                                                 style: const TextStyle(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Colors.purple,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           TextSpan(
//                                             text: (verses[i].verse ?? '') + ' ',
//                                           ),
//                                           if ((i + 1) % 3 == 0)
//                                             WidgetSpan(
//                                               child: const SizedBox(
//                                                   height: 20), // spacing
//                                               alignment:
//                                                   PlaceholderAlignment.middle,
//                                             ),
//                                         ],
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           return const Center(child: Text('No verses found'));
//                         }
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
