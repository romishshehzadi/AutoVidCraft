import 'package:auto/Screens/AuthScreen.dart';
import 'package:auto/Screens/History.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  String userName = '';
  String userEmail = '';
  bool _isLoggingOut = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadProfileImage();
  }

  // Load profile image from Firestore
  Future<void> _loadProfileImage() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final imageUrl = data?['profileImageUrl'] as String?;

        if (imageUrl != null && imageUrl.isNotEmpty) {
          setState(() {
            _profileImageUrl = imageUrl;
          });
        }
      }
    }
  }

  // Logout method with backend integration
  Future<void> _logoutUser() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // 1. Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // 2. Clear any local data if needed (optional)
      await _clearLocalData();

      // 3. Navigate to Auth screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const GlassAuthScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Handle logout errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // Optional: Clear any local data
  Future<void> _clearLocalData() async {
    try {
      // Example: Clear shared preferences if you're using them
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

      // Clear any cached data
      // YourCacheManager.clearCache();
    } catch (e) {
      print('Failed to clear local data: $e');
    }
  }

  // Upload profile picture - Updated with enhanced UI
  Future<void> _uploadProfilePicture() async {
    final ImagePicker picker = ImagePicker();

    // Show option to choose from gallery or camera with enhanced UI
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1524),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              border: Border.all(color: const Color(0xFF6366F1), width: 1),
            ),
            child: Column(
              children: [
                // Header with gradient
                Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Cancel Icon
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        // Heading
                        const Text(
                          'Profile Picture',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'font8',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Delete Icon - only show if profile image exists
                        _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                ); // Close bottom sheet first
                                _showDeleteConfirmationDialog();
                              },
                            )
                            : Container(
                              width: 48,
                            ), // Empty container for spacing
                      ],
                    ),
                  ),
                ),

                // Body options
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        // Camera option
                        Card(
                          color: const Color(0xFF1B2235),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 1,
                            ),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text(
                              'Take Photo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'font8',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              'Use camera to take a new photo',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'font9',
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white70,
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await _pickImage(ImageSource.camera);
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Gallery option
                        Card(
                          color: const Color(0xFF1B2235),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Color(0xFF6366F1),
                              width: 1,
                            ),
                          ),
                          elevation: 5,
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text(
                              'Choose from Gallery',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'font8',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: const Text(
                              'Select photo from your device gallery',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'font9',
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.white70,
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await _pickImage(ImageSource.gallery);
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // View current photo option (if exists)
                        if (_profileImageUrl != null &&
                            _profileImageUrl!.isNotEmpty)
                          Card(
                            color: const Color(0xFF1B2235),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: const BorderSide(
                                color: Colors.amber,
                                width: 1,
                              ),
                            ),
                            elevation: 5,
                            child: ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.withOpacity(0.2),
                                  border: Border.all(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.visibility,
                                  color: Colors.amber,
                                ),
                              ),
                              title: const Text(
                                'View Current Photo',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'font8',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: const Text(
                                'View your current profile picture',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'font9',
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.white70,
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                _viewCurrentProfilePicture();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null && user != null) {
        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                backgroundColor: Color(0xFF1B2235),
                content: Row(
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(width: 16),
                    Text('Uploading...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
        );

        // For now, we'll store the file path locally
        // In a real app, you would upload to Firebase Storage
        // For this example, we'll just update Firestore with the local path
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({
              'profileImageUrl': image.path,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        setState(() {
          _profileImageUrl = image.path;
        });

        Navigator.pop(context); // Close loading dialog
        _showSnack('Profile picture updated');
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog if open
      _showErrorSnack('Failed to upload image: $e');
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2235),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1),
          ),
          title: const Row(
            children: [
              // Icon(Icons.delete_outline, color: Colors.red, size: 28),
              // SizedBox(width: 12),
              Text(
                "Delete Profile Picture",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'font8',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to delete your profile picture? This action cannot be undone.",
            style: TextStyle(color: Colors.white70, fontFamily: 'font9'),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70, fontFamily: 'font9'),
              ),
            ),

            // Delete button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProfilePicture();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Delete",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'font8',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Delete profile picture
  Future<void> _deleteProfilePicture() async {
    if (user == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1B2235),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF6366F1), width: 1),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF6366F1)),
                const SizedBox(width: 16),
                Text(
                  'Deleting...',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'font8',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
    );

    try {
      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
            'profileImageUrl': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Clear local state
      setState(() {
        _profileImageUrl = null;
      });

      Navigator.pop(context); // Close loading dialog

      // Show success message
      _showSnack('Profile picture deleted successfully');
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      _showErrorSnack('Failed to delete profile picture: $e');
    }
  }

  // View current profile picture in full screen
  void _viewCurrentProfilePicture() {
    if (_profileImageUrl == null || _profileImageUrl!.isEmpty) {
      _showErrorSnack('No profile picture available');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // Image container
              Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      _profileImageUrl!.startsWith('http')
                          ? Image.network(
                            _profileImageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                  color: const Color(0xFF6366F1),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.broken_image,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'font9',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                          : Image.file(
                            File(_profileImageUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Image not found',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'font9',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),

              // Close button
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Image source indicator
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _profileImageUrl!.startsWith('http')
                        ? 'Cloud Storage'
                        : 'Local Device',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'font9',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1524),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'My Profile',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'font8',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body:
            user == null
                ? const Center(
                  child: Text(
                    "No user logged in",
                    style: TextStyle(color: Colors.white),
                  ),
                )
                : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== PROFILE CARD =====
                          Card(
                            color: const Color(0xFF1B2235),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Profile Picture with upload option
                                  GestureDetector(
                                    onTap: _uploadProfilePicture,
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF6366F1),
                                                Color(0xFF8B5CF6),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            image:
                                                _profileImageUrl != null
                                                    ? DecorationImage(
                                                      image:
                                                          _profileImageUrl!
                                                                  .startsWith(
                                                                    'http',
                                                                  )
                                                              ? NetworkImage(
                                                                _profileImageUrl!,
                                                              )
                                                              : FileImage(
                                                                    File(
                                                                      _profileImageUrl!,
                                                                    ),
                                                                  )
                                                                  as ImageProvider,
                                                      fit: BoxFit.cover,
                                                    )
                                                    : null,
                                          ),
                                          child: StreamBuilder<DocumentSnapshot>(
                                            stream:
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(user!.uid)
                                                    .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: Colors.white,
                                                      ),
                                                );
                                              }
      
                                              if (!snapshot.hasData ||
                                                  !snapshot.data!.exists) {
                                                final displayName =
                                                    user!.displayName ?? '';
                                                final email = user!.email ?? '';
      
                                                String displayLetter = 'U';
                                                if (displayName.isNotEmpty) {
                                                  displayLetter =
                                                      displayName[0]
                                                          .toUpperCase();
                                                } else if (email.isNotEmpty) {
                                                  final emailName =
                                                      email.split('@').first;
                                                  if (emailName.isNotEmpty) {
                                                    displayLetter =
                                                        emailName[0]
                                                            .toUpperCase();
                                                  }
                                                }
      
                                                return _profileImageUrl == null
                                                    ? Center(
                                                      child: Text(
                                                        displayLetter,
                                                        style: const TextStyle(
                                                          fontSize: 28,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    )
                                                    : const SizedBox.shrink();
                                              }
      
                                              final data =
                                                  snapshot.data!.data()
                                                      as Map<String, dynamic>?;
                                              userName =
                                                  data?['name']?.toString() ?? '';
                                              userEmail =
                                                  data?['email']?.toString() ??
                                                  '';
                                              final imageUrl =
                                                  data?['profileImageUrl']
                                                      as String?;
      
                                              if (imageUrl != null &&
                                                  imageUrl.isNotEmpty &&
                                                  _profileImageUrl == null) {
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      setState(() {
                                                        _profileImageUrl =
                                                            imageUrl;
                                                      });
                                                    });
                                              }
      
                                              String displayLetter =
                                                  _getFirstLetterForAvatar(
                                                    userName,
                                                    userEmail,
                                                  );
      
                                              return _profileImageUrl == null
                                                  ? Center(
                                                    child: Text(
                                                      displayLetter,
                                                      style: const TextStyle(
                                                        fontSize: 28,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                  : const SizedBox.shrink();
                                            },
                                          ),
                                        ),
                                        // Edit icon overlay
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF6366F1),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: StreamBuilder<DocumentSnapshot>(
                                      stream:
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(user!.uid)
                                              .snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        }
      
                                        if (!snapshot.hasData ||
                                            !snapshot.data!.exists) {
                                          userName =
                                              user!.displayName ?? 'No Name';
                                          userEmail = user!.email ?? 'No Email';
      
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: 'font6',
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                userEmail,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontFamily: 'font9',
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // FIX: Added Expanded for UID text to prevent overflow
                                              LayoutBuilder(
                                                builder: (context, constraints) {
                                                  return Container(
                                                    width: constraints.maxWidth,
                                                    child: Text(
                                                      user!.uid,
                                                      style: const TextStyle(
                                                        color: Colors.white38,
                                                        fontFamily: 'font9',
                                                        fontSize: 12,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        }
      
                                        final data =
                                            snapshot.data!.data()
                                                as Map<String, dynamic>?;
                                        userName =
                                            data?['name']?.toString() ??
                                            user!.displayName ??
                                            'No Name';
                                        userEmail =
                                            data?['email']?.toString() ??
                                            user!.email ??
                                            'No Email';
      
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userName,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'font6',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              userEmail,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontFamily: 'font9',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            // FIX: Added LayoutBuilder for UID text to prevent overflow
                                            LayoutBuilder(
                                              builder: (context, constraints) {
                                                return Container(
                                                  width: constraints.maxWidth,
                                                  child: Text(
                                                    user!.uid,
                                                    style: const TextStyle(
                                                      color: Colors.white38,
                                                      fontFamily: 'font9',
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
      
                          const SizedBox(height: 30),
      
                          // ===== ACTION BUTTONS =====
                          _actionButton("Edit Profile", Icons.person, () async {
                            final result =
                                await Navigator.push<Map<String, String>>(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => EditProfileScreen(
                                          userId: user!.uid,
                                          name: userName,
                                          email: userEmail,
                                        ),
                                  ),
                                );
                            if (result != null) {
                              _showSnack("Profile updated successfully");
                            }
                          }),
                          const SizedBox(height: 12),
                          _actionButton("Change Password", Icons.lock, () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        ChangePasswordScreen(userId: user!.uid),
                              ),
                            );
                            if (result != null && result) {
                              _showSnack("Password updated successfully");
                            }
                          }),
                          const SizedBox(height: 12),
                          _actionButton("Upgrade Plan", Icons.upgrade, () async {
                            final result = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UpgradeScreen(plan: "Free Plan"),
                              ),
                            );
                            if (result != null) {
                              _showSnack("Plan upgraded to $result");
                            }
                          }),
      
                          const SizedBox(height: 30),
                          // ===== VIDEO HISTORY SECTION - =====
                          const Text(
                            "My Recent Videos",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'font8'),
                          ),
                          const SizedBox(height: 12),

                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('videos')
                                .where('userId', isEqualTo: user!.uid)
                                .orderBy('createdAt', descending: true) // ✅ FIXED: timestamp → createdAt
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text(
                                  "No videos uploaded yet.",
                                  style: TextStyle(color: Colors.white70, fontFamily: 'font9'),
                                );
                              }
                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;

                                  // ✅ FIXED: Get date from createdAt
                                  String dateStr = 'Unknown';
                                  if (data['createdAt'] != null) {
                                    if (data['createdAt'] is Timestamp) {
                                      dateStr = (data['createdAt'] as Timestamp).toDate().toString().split('.')[0];
                                    }
                                  }

                                  // Get video URL
                                  String videoUrl = data['videoUrl'] ?? data['videoLocalPath'] ?? '';

                                  return Card(
                                    color: const Color(0xFF141827),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      leading: const Icon(Icons.videocam, color: Color(0xFF6366F1)),
                                      title: Text(
                                        data['title'] ?? 'Untitled Video',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white, fontFamily: 'font8'),
                                      ),
                                      subtitle: Text(
                                        "Date: $dateStr", // ✅ FIXED: Using createdAt
                                        style: const TextStyle(color: Colors.white60, fontFamily: 'font9'),
                                      ),
                                      trailing: const Icon(Icons.play_circle_outline, color: Color(0xFF6366F1), size: 28),
                                      onTap: () {
                                        // ✅ VIDEO PLAY ON TAP
                                        if (videoUrl.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => VideoPlayScreen(
                                                videoUrl: videoUrl,
                                                title: data['title'] ?? 'AI Video',
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Video URL not available'),
                                              backgroundColor: Colors.orange,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // ===== LOGOUT BUTTON (UPDATED) =====
                    Positioned(
                      bottom: 20,
                      left: 24,
                      right: 24,
                      child:
                          _isLoggingOut
                              ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Logging out...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'font10',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ElevatedButton.icon(
                                onPressed: () {
                                  _showLogoutConfirmationDialog();
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'font10',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: Colors.deepPurpleAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                    ),
                  ],
                ),
      ),
    );
  }

  // ===== HELPER METHODS =====
  Widget _actionButton(String title, IconData icon, VoidCallback onTap) {
    return Card(
      color: const Color(0xFF1B2235),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF6366F1),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white70,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show logout confirmation dialog
  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2235),
          title: const Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'font8',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(color: Colors.white70, fontFamily: 'font9'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white70, fontFamily: 'font9'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logoutUser(); // Proceed with logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'font8',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Get first letter for avatar - priority: Name > Email
  String _getFirstLetterForAvatar(String name, String email) {
    if (name.trim().isNotEmpty) {
      return name.trim()[0].toUpperCase();
    } else if (email.trim().isNotEmpty) {
      // Extract the first letter from email (before @ symbol)
      final emailName = email.split('@').first;
      if (emailName.isNotEmpty) {
        return emailName[0].toUpperCase();
      }
    }
    return 'U'; // Default letter
  }
}

// ===== EDIT PROFILE SCREEN =====
class EditProfileScreen extends StatefulWidget {
  final String userId;
  final String name;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.name;
    _emailController.text = widget.email;
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update in Firestore
      await _firestore.collection('users').doc(widget.userId).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update in Firebase Auth (display name)
      await FirebaseAuth.instance.currentUser?.updateDisplayName(
        _nameController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Return updated data
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
      });
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1524),
        appBar: AppBar(
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'font8',
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name Field
              const Text(
                "Name",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'font9',
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF1B2235),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your name",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Email Field
              const Text(
                "Email",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'font9',
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF1B2235),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter your email",
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                    enabled: false,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Note: Changing email requires verification. Contact support for assistance.",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontFamily: 'font9',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "Save Changes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'font8',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

// ===== CHANGE PASSWORD SCREEN (UPDATED WITH FIREBASE) =====
class ChangePasswordScreen extends StatefulWidget {
  final String userId;
  const ChangePasswordScreen({super.key, required this.userId});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters long'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Update password in Firebase Auth
        await user.updatePassword(_newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to update password';
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak';
      } else if (e.code == 'requires-recent-login') {
        errorMessage = 'Please re-login and try again';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1524),
        appBar: AppBar(
          title: const Text(
            "Change Password",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'font8',
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          // FIX: Added SingleChildScrollView to prevent overflow
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Password
              const Text(
                "Current Password",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'font9',
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF1B2235),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _currentPasswordController,
                    obscureText: _obscureCurrent,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter current password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCurrent = !_obscureCurrent;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // New Password
              const Text(
                "New Password",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'font9',
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF1B2235),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter new password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureNew = !_obscureNew;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Confirm New Password
              const Text(
                "Confirm New Password",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'font9',
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF1B2235),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Confirm new password",
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirm = !_obscureConfirm;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "Note: Password must be at least 6 characters long",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontFamily: 'font9',
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "Change Password",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'font8',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 20), // Extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

// ===== UPGRADE SCREEN =====
class UpgradeScreen extends StatelessWidget {
  final String plan;
  const UpgradeScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1524),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Upgrade Plan",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'font8',
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                color: const Color(0xFF1B2235),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Upgrade your plan from $plan to Pro",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, "Pro"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                ),
                child: const Text(
                  "Upgrade to Pro",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'font8',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
