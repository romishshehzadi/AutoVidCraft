import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:auto/Screens/bottom%20navigation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Services/vidoestoreimagekit.dart' show ImageKitService;
import '../api_service.dart' show ColabApiService;


// ------------------- Video Ready Screen -------------------
class VideoReadyScreen extends StatefulWidget {
  final String imageUrl;
  final File? videoFile;
  final VoidCallback onRegenerate;
  final VoidCallback onCreateNew;

  // Parameters to receive all selected data
  final Map<String, dynamic>? selectedVoice;
  final Map<String, dynamic>? selectedTemplate;
  final Map<String, dynamic>? selectedCharacter;
  final Map<String, dynamic>? selectedFilter;
  final String? transcribedText;
  final String? voiceLanguage;

  const VideoReadyScreen({
    super.key,
    required this.imageUrl,
    this.videoFile,
    required this.onRegenerate,
    required this.onCreateNew,
    this.selectedVoice,
    this.selectedTemplate,
    this.selectedCharacter,
    this.selectedFilter,
    this.transcribedText,
    this.voiceLanguage,
  });

  @override
  State<VideoReadyScreen> createState() => _VideoReadyScreenState();
}

class _VideoReadyScreenState extends State<VideoReadyScreen> {
  double musicVolume = 0.75;
  String selectedQuality = '720p HD';
  bool isDownloading = false;
  bool isSharing = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.videoFile != null && await widget.videoFile!.exists()) {
      _videoController = VideoPlayerController.file(widget.videoFile!);
      await _videoController!.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
      _videoController!.play();
      _videoController!.setLooping(true);
    }
  }
  // Inside your _showShareOptions function
  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Share Video',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(color: Colors.white24),

            // ✅ WhatsApp - SAHI TARIQA
            ListTile(
              leading: FaIcon(FontAwesomeIcons.whatsapp, color: const Color(0xFF25D366), size: 24),
              title: const Text('WhatsApp', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await _shareToSpecificPlatform('WhatsApp');
              },
            ),

            // ✅ Facebook - SAHI TARIQA
            ListTile(
              leading: FaIcon(FontAwesomeIcons.facebook, color: const Color(0xFF1877F2), size: 24),
              title: const Text('Facebook', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await _shareToSpecificPlatform('Facebook');
              },
            ),

            // ✅ TikTok - SAHI TARIQA
            ListTile(
              leading: FaIcon(FontAwesomeIcons.tiktok, color: Colors.black, size: 24),
              title: const Text('TikTok', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await _shareToSpecificPlatform('TikTok');
              },
            ),

            // ✅ Instagram - SAHI TARIQA
            ListTile(
              leading: FaIcon(FontAwesomeIcons.instagram, color: const Color(0xFFE4405F), size: 24),
              title: const Text('Instagram', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await _shareToSpecificPlatform('Instagram');
              },
            ),

            // Save to Gallery
            ListTile(
              leading: const Icon(Icons.download, color: Colors.orange),
              title: const Text('Save to Gallery', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await _saveToGallery();
              },
            ),

            // Other Apps
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Other Apps', style: TextStyle(color: Colors.white70)),
              onTap: () async {
                Navigator.pop(context);
                await _shareVideoToOtherApps();
              },
            ),

            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  // void _showShareOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF1E1E2F),
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (_) {
  //       return Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           const SizedBox(height: 12),
  //           const Text(
  //             'Share Video',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 16,
  //               fontFamily: 'font6',
  //             ),
  //           ),
  //           const Divider(color: Colors.white24),
  //           _buildShareTile('WhatsApp', Icons.phone, Colors.green),
  //           _buildShareTile('Facebook', Icons.facebook, Colors.blue),
  //           _buildShareTile('TikTok', Icons.tiktok, Colors.black),
  //           _buildShareTile('Instagram', Icons.integration_instructions_outlined, Colors.purple),
  //           _buildShareTile('Save to Gallery', Icons.download, Colors.orange),
  //           _buildShareTile('Other Apps', Icons.share, Colors.white),
  //           const SizedBox(height: 12),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // ListTile _buildShareTile(String platform, IconData icon, Color color) {
  //   return ListTile(
  //     leading: Icon(icon, color: color),
  //     title: Text(
  //       platform,
  //       style: const TextStyle(color: Colors.white70, fontFamily: 'font4'),
  //     ),
  //     onTap: () async {
  //       Navigator.pop(context);
  //       if (platform == 'Save to Gallery') {
  //         await _saveToGallery();
  //       } else if (platform == 'Other Apps') {
  //         await _shareVideoToOtherApps();
  //       } else {
  //         await _shareToSpecificPlatform(platform);
  //       }
  //     },
  //   );
  // }

  Future<void> _shareToSpecificPlatform(String platform) async {
    if (widget.videoFile == null) {
      _showSnackBar('No video file available', Colors.red);
      return;
    }

    setState(() {
      isSharing = true;
    });

    try {
      String shareText = 'Check out my AI-generated video!';
      if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty) {
        shareText = widget.transcribedText!;
      }

      await Share.shareXFiles(
        [XFile(widget.videoFile!.path)],
        text: shareText,
        subject: 'AI Generated Video',
      );

      _showSnackBar('Shared to $platform successfully!', Colors.green);
    } catch (e) {
      print('❌ Share error: $e');
      _showSnackBar('Error sharing video: $e', Colors.red);
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  Future<void> _shareVideoToOtherApps() async {
    if (widget.videoFile == null) {
      _showSnackBar('No video file available', Colors.red);
      return;
    }

    setState(() {
      isSharing = true;
    });

    try {
      await Share.shareXFiles(
        [XFile(widget.videoFile!.path)],
        text: 'Check out my AI-generated video!\n\n${widget.transcribedText ?? ''}',
        subject: 'AI Generated Video',
      );
      _showSnackBar('Opening share dialog...', Colors.green);
    } catch (e) {
      print('❌ Share error: $e');
      _showSnackBar('Error sharing video: $e', Colors.red);
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  Future<void> _saveToGallery() async {
    if (widget.videoFile == null) {
      _showSnackBar('No video file available', Colors.red);
      return;
    }

    setState(() {
      isDownloading = true;
    });

    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _showSnackBar('Storage permission denied', Colors.red);
        setState(() {
          isDownloading = false;
        });
        return;
      }

      await Gal.putVideo(widget.videoFile!.path);
      _showSnackBar('Video saved to gallery successfully!', Colors.green);

    } catch (e) {
      print('❌ Save to gallery error: $e');
      if (e.toString().contains('No such file')) {
        _showSnackBar('Video file not found', Colors.red);
      } else {
        _showSnackBar('Could not save to gallery, saving to downloads...', Colors.orange);
        await _saveToDownloads();
      }
    } finally {
      if (mounted) {
        setState(() {
          isDownloading = false;
        });
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.photos.isGranted) {
        return true;
      }
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) {
        return true;
      }
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final photosStatus = await Permission.photos.request();
      return photosStatus.isGranted;
    }
    return false;
  }

  Future<void> _saveToDownloads() async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (await downloadsDir.exists()) {
        final fileName = 'ai_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final newFile = File('${downloadsDir.path}/$fileName');
        await widget.videoFile!.copy(newFile.path);
        _showSnackBar('Video saved to Downloads: $fileName', Colors.green);
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'ai_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final newFile = File('${appDir.path}/$fileName');
      await widget.videoFile!.copy(newFile.path);
      _showSnackBar('Video saved to app documents: $fileName', Colors.green);

    } catch (e) {
      _showSnackBar('Error saving video: $e', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildOptionChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<int> _getVideoFileSize() async {
    if (widget.videoFile != null && await widget.videoFile!.exists()) {
      return await widget.videoFile!.length();
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E2F),
        appBar: AppBar(
          flexibleSpace: Container(
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
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          title: const Text(
            'Video Ready!',
            style: TextStyle(color: Colors.white, fontFamily: 'font6'),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your AI-generated video is ready to preview and export',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font4'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white12,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _isVideoInitialized && _videoController != null
                        ? Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_videoController!),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.5),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                _videoController!.value.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty)
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.transcribedText!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: widget.voiceLanguage == 'ur_PK'
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          ),
                      ],
                    )
                        : (widget.videoFile != null
                        ? Image.file(
                      widget.videoFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        );
                      },
                    )
                        : (widget.imageUrl.startsWith("http")
                        ? Image.network(widget.imageUrl, fit: BoxFit.cover)
                        : Image.file(
                      File(widget.imageUrl),
                      fit: BoxFit.cover,
                    ))),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Video Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'font6',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (widget.selectedVoice != null ||
                        widget.selectedTemplate != null ||
                        widget.selectedCharacter != null ||
                        widget.selectedFilter != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Options',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (widget.selectedVoice != null)
                                  _buildOptionChip(
                                    icon: Icons.audio_file,
                                    label: 'Audio • ${widget.selectedVoice!['duration'] ?? '0'}s',
                                    color: Colors.purple,
                                  ),
                                if (widget.selectedTemplate != null)
                                  _buildOptionChip(
                                    icon: Icons.auto_awesome,
                                    label: 'Template: ${widget.selectedTemplate!['name'] ?? 'Standard'}',
                                    color: Colors.blue,
                                  ),
                                if (widget.selectedCharacter != null)
                                  _buildOptionChip(
                                    icon: Icons.person,
                                    label: '${widget.selectedCharacter!['emoji'] ?? '👤'} ${widget.selectedCharacter!['name'] ?? 'Character'}',
                                    color: Colors.orange,
                                  ),
                                if (widget.selectedFilter != null)
                                  _buildOptionChip(
                                    icon: Icons.filter_alt,
                                    label: 'Filter: ${widget.selectedFilter!['name'] ?? 'Normal'}',
                                    color: Colors.green,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Duration', style: TextStyle(color: Colors.white70, fontFamily: 'font4')),
                        Text(
                          _videoController != null && _videoController!.value.isInitialized
                              ? '${_videoController!.value.duration.inMinutes}:${(_videoController!.value.duration.inSeconds % 60).toString().padLeft(2, '0')}'
                              : '0:00',
                          style: const TextStyle(color: Colors.white, fontFamily: 'font4'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quality', style: TextStyle(color: Colors.white70, fontFamily: 'font4')),
                        DropdownButton<String>(
                          value: selectedQuality,
                          dropdownColor: const Color(0xFF1E1E2F),
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                          items: ['720p HD', '1080p Full HD', '4K Ultra HD']
                              .map((quality) => DropdownMenuItem(
                            value: quality,
                            child: Text(
                              quality,
                              style: const TextStyle(color: Colors.white, fontFamily: 'font4'),
                            ),
                          ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedQuality = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Format', style: TextStyle(color: Colors.white70, fontFamily: 'font4')),
                        Text('MP4', style: TextStyle(color: Colors.white, fontFamily: 'font4')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FutureBuilder<int>(
                      future: _getVideoFileSize(),
                      builder: (context, snapshot) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Size', style: TextStyle(color: Colors.white70, fontFamily: 'font4')),
                            Text(
                              snapshot.hasData ? _formatFileSize(snapshot.data!) : 'Calculating...',
                              style: const TextStyle(color: Colors.white, fontFamily: 'font4'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: isDownloading ? null : _saveToGallery,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: isDownloading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Download',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font6'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: isSharing ? null : _showShareOptions,
                          icon: isSharing
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(Icons.share, color: Colors.white70),
                          label: Text(
                            isSharing ? 'Sharing...' : 'Share',
                            style: const TextStyle(color: Colors.white70, fontFamily: 'font6'),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: widget.onRegenerate,
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          label: const Text(
                            'Regenerate',
                            style: TextStyle(color: Colors.white70, fontFamily: 'font6'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomNavScreen(),
                    ),
                        (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Back to Dashboard',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font6'),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: widget.onCreateNew,
                child: const Text(
                  'Create New Video',
                  style: TextStyle(color: Color(0xFF6366F1), fontSize: 16, fontFamily: 'font6'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- Video Generate Screen (COMPLETELY UPDATED WITH PROMPT) -------------------
class CreateVideoGenerateMobile extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onCancel;
  final String imageUrl;
  final File? audioFile;
  final String? imagePath;

  // ✅ ADDED: Text prompt parameter
  final String? prompt;

  final String? transcribedText;
  final String? voiceLanguage;
  final Map<String, dynamic>? selectedVoice;
  final Map<String, dynamic>? selectedTemplate;
  final Map<String, dynamic>? selectedCharacter;
  final Map<String, dynamic>? selectedFilter;

  const CreateVideoGenerateMobile({
    super.key,
    required this.onComplete,
    required this.onCancel,
    required this.imageUrl,
    this.audioFile,
    this.imagePath,
    this.prompt,  // ✅ ADD THIS LINE
    this.transcribedText,
    this.voiceLanguage,
    this.selectedVoice,
    this.selectedTemplate,
    this.selectedCharacter,
    this.selectedFilter,
  });

  @override
  State<CreateVideoGenerateMobile> createState() => _CreateVideoGenerateMobileState();
}

class AIModel {
  final String name;
  String status;
  double progress;
  AIModel({required this.name, this.status = 'pending', this.progress = 0});
}

class _CreateVideoGenerateMobileState extends State<CreateVideoGenerateMobile> {
  List<AIModel> models = [
    AIModel(name: 'Blip model'),
    AIModel(name: 'texttovidoe '),
    AIModel(name: 'freesound'),
    AIModel(name: 'vidoe generate'),
    AIModel(name: 'Music Selection'),
    AIModel(name: 'Video Rendering'),
    AIModel(name: 'Upload to Cloud'),
  ];

  int estimatedTime = 180;
  int currentModelIndex = 0;
  Timer? timer;
  Timer? progressTimer;
  File? generatedVideoFile;
  bool isGenerating = false;
  String? errorMessage;
  ColabApiService? apiService;

  @override
  void initState() {
    super.initState();
    apiService = ColabApiService();

    print("🎬 VideoGenerate Screen Received:");
    print("   - Image: ${widget.imageUrl}");
    print("   - Image Path: ${widget.imagePath}");
    print("   - 📝 TEXT PROMPT: ${widget.prompt}");
    print("   - 🎤 TRANSCRIBED TEXT: ${widget.transcribedText}");
    print("   - Voice: ${widget.selectedVoice}");
    print("   - Template: ${widget.selectedTemplate}");
    print("   - Character: ${widget.selectedCharacter}");
    print("   - Filter: ${widget.selectedFilter}");

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => estimatedTime = max(0, estimatedTime - 1));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    progressTimer?.cancel();
    super.dispose();
  }

  Future<void> generateVideo() async {
    if (widget.imagePath == null) {
      setState(() {
        errorMessage = 'Image file is missing';
      });
      return;
    }

    setState(() {
      isGenerating = true;
      errorMessage = null;
    });

    try {
      // ✅ CRITICAL: PROPER PROMPT PRIORITY LOGIC
      String prompt;

      // Priority 1: Voice input (transcribed text from voice recording)
      if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty) {
        prompt = widget.transcribedText!;
        print("🎤 USING VOICE TRANSCRIPT: $prompt");
      }
      // Priority 2: Text prompt (manual user input from text field)
      else if (widget.prompt != null && widget.prompt!.isNotEmpty) {
        prompt = widget.prompt!;
        print("📝 USING TEXT PROMPT: $prompt");
      }
      // Priority 3: Default prompt
      else {
        prompt = 'Create a beautiful cinematic video with smooth camera movement, dramatic lighting, and artistic effects';
        print("⚠️ USING DEFAULT PROMPT: $prompt");
      }

      print("🎯 FINAL PROMPT SENT TO API: $prompt");
      print("📡 Calling API with image: ${widget.imagePath}");

      final isHealthy = await apiService!.checkHealth();
      if (!isHealthy) {
        throw Exception('API service is not available. Please check your connection');
      }

      final imageFile = File(widget.imagePath!);

      final result = await apiService!.uploadAndGenerate(
        imageFile: imageFile,
        prompt: prompt,  // ✅ THIS IS WHAT MATTERS
        onProgress: (progress, message) {
          if (mounted) {
            setState(() {
              int modelIndex = (progress / 14.28).floor();
              if (modelIndex < models.length && modelIndex >= 0) {
                for (int i = 0; i <= modelIndex; i++) {
                  if (i < models.length && models[i].status != 'completed') {
                    models[i].status = i == modelIndex ? 'processing' : 'completed';
                    models[i].progress = i == modelIndex ? (progress % 14.28) * 7 : 100;
                  }
                }
              }
              estimatedTime = max(10, (100 - progress) ~/ 2);
            });
          }
        },
      );

      if (result['success'] == true && result['video_file'] != null) {
        print("✅ Video generated successfully!");
        print("✅ Video path: ${result['video_file']!.path}");

        setState(() {
          models[6].status = 'processing';
          models[6].progress = 50;
        });

        // Upload to ImageKit
        String? videoUrl;
        try {
          print("📤 Uploading to ImageKit...");
          videoUrl = await ImageKitService.uploadVideo(result['video_file']);
          if (videoUrl == null) {
            print("⚠️ ImageKit upload failed, using local path");
            videoUrl = result['video_file']?.path ?? '';
          } else {
            print("✅ Uploaded to ImageKit: $videoUrl");
          }
          setState(() {
            models[6].progress = 100;
            models[6].status = 'completed';
          });
        } catch (e) {
          print("❌ ImageKit error: $e");
          videoUrl = result['video_file']?.path ?? '';
          setState(() {
            models[6].progress = 100;
            models[6].status = 'completed';
          });
        }

        // Save to Firebase
        try {
          final String userId = FirebaseAuth.instance.currentUser!.uid;

          int durationInSeconds = 0;
          try {
            final controller = VideoPlayerController.file(result['video_file']);
            await controller.initialize();
            durationInSeconds = controller.value.duration.inSeconds;
            await controller.dispose();
          } catch (e) {
            durationInSeconds = 30;
          }

          final minutes = durationInSeconds ~/ 60;
          final seconds = durationInSeconds % 60;
          final formattedDuration = '$minutes:${seconds.toString().padLeft(2, '0')}';

          final fileSize = await result['video_file']!.length();
          String formattedSize = '';
          if (fileSize < 1024) {
            formattedSize = '$fileSize B';
          } else if (fileSize < 1024 * 1024) {
            formattedSize = '${(fileSize / 1024).toStringAsFixed(1)} KB';
          } else {
            formattedSize = '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
          }

          // Determine title based on input type
          String title;
          if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty) {
            title = widget.transcribedText!.substring(0, widget.transcribedText!.length > 50 ? 50 : widget.transcribedText!.length);
          } else if (widget.prompt != null && widget.prompt!.isNotEmpty) {
            title = widget.prompt!.substring(0, widget.prompt!.length > 50 ? 50 : widget.prompt!.length);
          } else {
            title = 'AI Generated Video';
          }

          await FirebaseFirestore.instance.collection('videos').add({
            'userId': userId,
            'title': title,
            'prompt': prompt,
            'videoUrl': videoUrl,
            'videoLocalPath': result['video_file']?.path ?? '',
            'imageUrl': widget.imageUrl,
            'status': 'Completed',
            'date': DateTime.now().toString().substring(0, 16),
            'duration': formattedDuration,
            'durationSeconds': durationInSeconds,
            'fileSize': formattedSize,
            'createdAt': FieldValue.serverTimestamp(),
            'selectedVoice': widget.selectedVoice?['name'],
            'selectedTemplate': widget.selectedTemplate?['name'],
            'selectedCharacter': widget.selectedCharacter?['name'],
            'selectedFilter': widget.selectedFilter?['name'],
            'voiceLanguage': widget.voiceLanguage,
            'transcribedText': widget.transcribedText,
            'textPrompt': widget.prompt,  // ✅ Save text prompt separately
          });

          print("✅ Saved to Firebase!");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Video saved to history!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          print("❌ Firebase error: $e");
        }

        setState(() {
          generatedVideoFile = result['video_file'];
          isGenerating = false;
          for (var model in models) {
            model.status = 'completed';
            model.progress = 100;
          }
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VideoReadyScreen(
                imageUrl: widget.imageUrl,
                videoFile: result['video_file'],
                selectedVoice: widget.selectedVoice,
                selectedTemplate: widget.selectedTemplate,
                selectedCharacter: widget.selectedCharacter,
                selectedFilter: widget.selectedFilter,
                transcribedText: widget.transcribedText,
                voiceLanguage: widget.voiceLanguage,
                onRegenerate: () {
                  Navigator.pop(context);
                  widget.onCancel();
                },
                onCreateNew: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ),
          );
        }
      } else {
        throw Exception(result['error'] ?? 'Generation failed - no video created');
      }

    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        errorMessage = e.toString();
        isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void startProcessing() {
    if (currentModelIndex >= models.length) {
      return;
    }

    setState(() => models[currentModelIndex].status = 'processing');

    progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        AIModel model = models[currentModelIndex];
        if (model.progress < 100) {
          model.progress = min(100, model.progress + Random().nextDouble() * 15);
        }
      });
    });

    Future.delayed(Duration(milliseconds: 2000 + Random().nextInt(2000)), () {
      if (!mounted) return;
      progressTimer?.cancel();
      setState(() {
        models[currentModelIndex].progress = 100;
        models[currentModelIndex].status = 'completed';
        currentModelIndex++;
      });
      startProcessing();
    });
  }

  double get overallProgress {
    if (isGenerating) return 95.0;
    if (models.isEmpty) return 0;
    return models.map((e) => e.progress).reduce((a, b) => a + b) / models.length;
  }

  String formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(1, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'processing': return Colors.blue;
      case 'completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Icon getStatusIcon(String status) {
    switch (status) {
      case 'processing': return const Icon(Icons.autorenew, color: Colors.blue, size: 16);
      case 'completed': return const Icon(Icons.check_circle, color: Colors.green, size: 16);
      default: return const Icon(Icons.circle, color: Colors.grey, size: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
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
          title: Text(
            "AI Processing",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'font4'),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          "Creating your video with ${models.length} AI models",
                          style: const TextStyle(fontSize: 14, color: Colors.white70, fontFamily: 'font4'),
                        ),
                        const SizedBox(height: 20),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: widget.imageUrl.startsWith('http')
                                    ? Image.network(
                                  widget.imageUrl,
                                  fit: BoxFit.contain,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white54),
                                      ),
                                    );
                                  },
                                )
                                    : Image.file(
                                  File(widget.imageUrl),
                                  fit: BoxFit.contain,
                                  height: 150,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey[900],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.white54),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            // Show text prompt overlay if available (and no voice)
                            if (widget.prompt != null && widget.prompt!.isNotEmpty && (widget.transcribedText == null || widget.transcribedText!.isEmpty))
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.9),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.edit_note, size: 14, color: Colors.green.shade200),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Text Prompt",
                                            style: TextStyle(
                                              color: Colors.green.shade200,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.prompt!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            // Show voice overlay if voice input
                            if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.9),
                                        Colors.transparent,
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.translate, size: 14, color: Colors.blue.shade200),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Voice: ${widget.voiceLanguage == 'ur_PK' ? 'اردو' : 'English'}",
                                            style: TextStyle(
                                              color: Colors.blue.shade200,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.transcribedText!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: widget.voiceLanguage == 'ur_PK'
                                            ? TextAlign.right
                                            : TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[900]!.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(color: Colors.white, fontFamily: 'font4'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Overall Progress",
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'font4'),
                                  ),
                                  Text(
                                    "${overallProgress.toStringAsFixed(0)}%",
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: overallProgress / 100,
                                backgroundColor: Colors.white24,
                                color: const Color(0xFF6366F1),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Estimated time remaining",
                                    style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'font4'),
                                  ),
                                  Text(
                                    isGenerating ? "Finalizing..." : formatTime(estimatedTime),
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: models.map((model) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          getStatusIcon(model.status),
                                          const SizedBox(width: 8),
                                          Text(
                                            model.name,
                                            style: TextStyle(
                                              color: getStatusColor(model.status),
                                              fontSize: 14,
                                              fontFamily: 'font4',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "${model.progress.toStringAsFixed(0)}%",
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: model.progress / 100,
                                    backgroundColor: Colors.white24,
                                    color: getStatusColor(model.status),
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: isGenerating ? null : widget.onCancel,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isGenerating
                          ? const LinearGradient(colors: [Colors.grey, Colors.grey])
                          : const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                    ),
                    child: Center(
                      child: Text(
                        isGenerating ? "Processing..." : "Cancel Processing",
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font6'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: isGenerating ? null : () {
                    print("🎬 Generate button pressed - starting video generation...");
                    startProcessing();
                    generateVideo();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isGenerating
                          ? const LinearGradient(
                        colors: [Colors.grey, Colors.grey],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: isGenerating
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        "Generate Video",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font6'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}