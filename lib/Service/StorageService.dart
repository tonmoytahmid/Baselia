import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:mime/mime.dart';
import 'dart:convert';

class CloudinaryService {
  static const String cloudName = "dwtnhtcxw";
  static const String uploadPreset = "Baselia"; // If using unsigned uploads
  static const String apiKey = "454249884151742";
  static const String apiSecret = "aUkRjPIAcGRJHE7VlA_-rmB49rA";

  static Future<String?> uploadFile(File file) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/upload");
    
    var request = http.MultipartRequest("POST", url);
    
    request.fields['upload_preset'] = uploadPreset;
    request.fields['cloud_name'] = cloudName;

    var mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', 
        file.path, 
        contentType: MediaType.parse(mimeType),
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse["secure_url"]; // Cloudinary URL
    } else {
      print("Failed to upload: ${response.statusCode}");
      return null;
    }
  }

  


 
}
