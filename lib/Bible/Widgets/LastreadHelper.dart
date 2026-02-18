// import 'package:shared_preferences/shared_preferences.dart';

// class LastReadHelper {
//   static Future<void> saveLastReadData({
//     required String bookId,
//     required int chapter,
//     required String bookName,
//     required String verseText,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('lastReadChapter_$bookId', chapter);
//     await prefs.setString('lastReadBookName_$bookId', bookName);
//     await prefs.setString('lastReadVerseText_$bookId', verseText);
//     await prefs.setString(
//       'lastReadTimestamp_$bookId',
//       DateTime.now().toIso8601String(),
//     );
//   }
// }

// import 'package:shared_preferences/shared_preferences.dart';

// class LastReadHelper {
//   static Future<void> saveLastReadData({
//     required String bookId,
//     required int chapter,
//     required String bookName,
//     required String verseText,
//     required int totalChapters, // added parameter
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('lastReadChapter_$bookId', chapter);
//     await prefs.setString('lastReadBookName_$bookId', bookName);
//     await prefs.setString('lastReadVerseText_$bookId', verseText);
//     await prefs.setString('lastReadTimestamp_$bookId', DateTime.now().toIso8601String());

//     // Save total chapters with key per bookId
//     await prefs.setInt('lastReadTotalChapters_$bookId', totalChapters);
//   }

//   static Future<int?> getTotalChapters(String bookId) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('totalChapters_$bookId');
//   }
// }

// import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

// Future<void> saveLastReadData({
//   required String bookId,
//   required int chapter,
//   required String bookName,
//   required int totalChapters,
// }) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setInt('lastReadChapter_$bookId', chapter);
//   await prefs.setString('lastReadBookName_$bookId', bookName);
//   await prefs.setString(
//       'lastReadTimestamp_$bookId', DateTime.now().toIso8601String());
//   await prefs.setInt('lastReadTotalChapters_$bookId', totalChapters);
// }

