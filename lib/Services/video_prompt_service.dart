// services/video_prompt_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoPromptService {
  /// Save video prompt text and image URL to Firestore
  static Future<void> saveVideoPrompt({
    required String textPrompt,
    required String imageUrl,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not logged in";

      await FirebaseFirestore.instance.collection('video_prompts').add({
        'userId': user.uid,
        'text_prompt': textPrompt,   // ✅ This is the prompt text
        'imageUrl': imageUrl,        // ✅ This is the image path/url
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Video prompt saved successfully!");
    } catch (e) {
      print("Error saving video prompt: $e");
      rethrow;
    }
  }
}
