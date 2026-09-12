import 'package:cloud_firestore/cloud_firestore.dart';

class ImageFirestoreService {
  static Future<void> saveImageData({
    required String imageUrl,
    required String format,
    required String size,
    required String dimensions,
  }) async {
    await FirebaseFirestore.instance.collection("uploaded_images").add({
      "imageUrl": imageUrl,
      "format": format,
      "size": size,
      "dimensions": dimensions,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
