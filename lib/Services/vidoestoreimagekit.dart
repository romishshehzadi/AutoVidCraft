import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageKitService {
  // 🔴 ImageKit Credentials
  static const String _publicKey = 'public_toXYV6gxJQzqH+M7mkeQQUbAM2A=';
  static const String _privateKey = 'private_NlE/pbCsRc5Tnfc87M1fVHFyKAs=';

  // ✅ ImageKit URL Endpoint
  static const String _uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';

  static Future<String?> uploadVideo(File videoFile) async {
    try {
      print("📤 Uploading to ImageKit...");
      print("📁 File path: ${videoFile.path}");

      // Check file exists
      if (!await videoFile.exists()) {
        print("❌ Video file does not exist!");
        return null;
      }

      // Get file size for logging
      int fileSize = await videoFile.length();
      print("📊 File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB");

      // ✅ CORRECT AUTHENTICATION - Sirf Private Key with colon
      String authString = '${_privateKey}:';  // ← IMPORTANT: colon at the end
      String encodedAuth = base64Encode(utf8.encode(authString));

      var request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // ✅ CORRECT Authorization header
      request.headers['Authorization'] = 'Basic $encodedAuth';

      // Add file
      request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));

      // Add metadata
      request.fields['fileName'] = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      request.fields['folder'] = '/ai_videos';
      request.fields['useUniqueFileName'] = 'true';

      print("📡 Sending request to ImageKit...");
      print("🔑 Auth header: Basic $encodedAuth");

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      print("📡 Response status code: ${response.statusCode}");
      print("📡 Response body: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? videoUrl = jsonResponse['url'];
        print('✅✅✅ IMAGEKIT UPLOAD SUCCESSFUL! ✅✅✅');
        print('🔗 Video URL: $videoUrl');
        print('📁 File ID: ${jsonResponse['fileId']}');
        return videoUrl;
      } else {
        print('❌ ImageKit Upload Failed!');
        print('❌ Status Code: ${response.statusCode}');
        print('❌ Error Message: ${jsonResponse['message'] ?? 'Unknown error'}');
        print('❌ Help: ${jsonResponse['help'] ?? 'No help available'}');
        return null;
      }

    } catch (e) {
      print('❌❌❌ IMAGEKIT EXCEPTION: $e');
      return null;
    }
  }
}