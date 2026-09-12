import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageKitService {
  static const String _uploadUrl = "https://upload.imagekit.io/api/v1/files/upload";

  static const String _privateKey = "private_NlE/pbCsRc5Tnfc87M1fVHFyKAs=";

  static Future<String?> uploadImage(File imageFile) async {
    final request = http.MultipartRequest("POST", Uri.parse(_uploadUrl));

    final auth = base64Encode(utf8.encode("$_privateKey:"));
    request.headers['Authorization'] = "Basic $auth";

    request.fields['fileName'] =
    "auto_${DateTime.now().millisecondsSinceEpoch}.jpg";

    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['url'];
    } else {
      print("ImageKit Upload Failed: $responseBody");
      return null;
    }
  }
}
