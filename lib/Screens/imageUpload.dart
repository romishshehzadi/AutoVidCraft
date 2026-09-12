import 'dart:io';
import 'dart:ui';
import 'package:auto/services/image_firestore_service.dart';
import 'package:auto/services/imagekit_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';

// -------------------- CreateVideoUploadMobile Screen --------------------
class CreateVideoUploadMobile extends StatefulWidget {
  final Function(String imagePath) onNext;
  final VoidCallback onBack;

  const CreateVideoUploadMobile({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<CreateVideoUploadMobile> createState() =>
      _CreateVideoUploadMobileState();
}

class _CreateVideoUploadMobileState extends State<CreateVideoUploadMobile> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? _format;
  String? _dimensions;
  String? _size;
  bool _isUploading = false;

  // ---------------- Pick image from gallery ----------------
  Future<void> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,        // ✅ Add max width
        maxHeight: 1920,       // ✅ Add max height
        imageQuality: 85,      // ✅ Add compression
      );
      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      print("❌ Gallery pick error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------- Pick image from camera ----------------
  Future<void> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,        // ✅ Add max width
        maxHeight: 1920,       // ✅ Add max height
        imageQuality: 85,      // ✅ Add compression
      );
      if (image != null) {
        await Gal.putImage(image.path, album: 'Auto-VidCraft');
        await _processImage(image);
      }
    } catch (e) {
      print("❌ Camera pick error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to take photo: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------- Process image metadata ----------------
  Future<void> _processImage(XFile image) async {
    try {
      final file = File(image.path);

      // Check if file exists
      if (!await file.exists()) {
        throw Exception("File does not exist");
      }

      // Check file size
      final bytes = await file.length();
      final sizeInMB = bytes / (1024 * 1024);
      print("📸 Image size: ${sizeInMB.toStringAsFixed(2)} MB");

      // Don't process if image is too large (>50MB)
      if (sizeInMB > 50) {
        throw Exception("Image too large (${sizeInMB.toStringAsFixed(2)} MB). Max 50MB.");
      }

      // Decode image with error handling
      final decoded = await decodeImageFromList(await file.readAsBytes());

      setState(() {
        _selectedImage = file;
        _format = image.name.split('.').last.toUpperCase();
        _dimensions = "${decoded.width} × ${decoded.height}";
        _size = "${sizeInMB.toStringAsFixed(2)} MB";
      });

      print("✅ Image processed: ${_dimensions}, ${_size}");

    } catch (e) {
      print("❌ Error processing image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error processing image: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------- Upload image to ImageKit and save to Firestore ----------------
  Future<void> uploadAndSave() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      print("📤 Starting upload...");

      // Upload to ImageKit
      final imageUrl = await ImageKitService.uploadImage(_selectedImage!);

      if (imageUrl != null) {
        print("✅ Image uploaded to ImageKit: $imageUrl");

        // Save metadata to Firestore
        await ImageFirestoreService.saveImageData(
          imageUrl: imageUrl,
          format: _format ?? "",
          size: _size ?? "",
          dimensions: _dimensions ?? "",
        );

        print("✅ Metadata saved to Firestore");

        // ✅ IMPORTANT: Send local path to next screen, not URL
        widget.onNext(_selectedImage!.path);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ Upload successful! Proceeding..."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception("ImageKit upload failed - returned null");
      }
    } catch (e) {
      print("❌ Upload failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload failed: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  // ---------------- Remove selected image ----------------
  void removeImage() {
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
          ),
          title: Text(
            "Upload Your Image",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'font4',
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: _selectedImage == null
                    ? buildUploadArea()
                    : buildPreviewArea(),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white54),
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: widget.onBack,
                      child: Text(
                        "Cancel",
                        style: TextStyle(fontFamily: 'font6'),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _selectedImage == null
                        ? Container()
                        : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: Size(double.infinity, 48),
                        ),
                        onPressed: _isUploading ? null : uploadAndSave,
                        child: _isUploading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'font6',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Upload area buttons ----------------
  Widget buildUploadArea() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
            ),
            child: Icon(Icons.upload, size: 38, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            "Drag & drop your image",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'font6'
            ),
          ),
          SizedBox(height: 4),
          Text(
            "or click to browse from your device",
            style: TextStyle(
                color: Colors.white60,
                fontSize: 12,
                fontFamily: 'font4'
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.image),
            label: Text(
              "Choose from Gallery",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'font6'
              ),
            ),
            onPressed: pickFromGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: Size(double.infinity, 48),
              side: BorderSide(color: Colors.white70),
            ),
          ),
          SizedBox(height: 8),
          OutlinedButton.icon(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            label: Text(
              "Take Photo",
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'font6'
              ),
            ),
            onPressed: pickFromCamera,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white70),
              minimumSize: Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Preview selected image ----------------
  Widget buildPreviewArea() {
    return Column(
      children: [
        // Image preview with error handling
        AspectRatio(
          aspectRatio: 16 / 9,
          child: _selectedImage != null
              ? Image.file(
            _selectedImage!,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print("❌ Image preview error: $error");
              return Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.white54, size: 50),
                      SizedBox(height: 8),
                      Text(
                        "Failed to load image",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              );
            },
          )
              : Container(color: Colors.grey[900]),
        ),
        SizedBox(height: 12),

        // Remove button
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: removeImage,
          ),
        ),

        // Success indicator
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                "Image selected successfully",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'font4'
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18),

        // Image details
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildDetailRow("Format:", _format ?? "-"),
              buildDetailRow("Dimensions:", _dimensions ?? "-"),
              buildDetailRow("Size:", _size ?? "-"),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Detail row helper ----------------
  Widget buildDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                color: Colors.white60,
                fontSize: 13,
                fontFamily: 'font4'
            ),
          ),
          SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'font4'
            ),
          ),
        ],
      ),
    );
  }
}