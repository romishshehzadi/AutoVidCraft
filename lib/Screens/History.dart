import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

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
          title: const Text(
            "Video History",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // Optional: Add select multiple delete feature
            IconButton(
              onPressed: () {
                _showDeleteAllDialog(context, userId);
              },
              icon: const Icon(Icons.delete_sweep,color: Colors.white,),
              tooltip: 'Delete All Videos',
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('videos')
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 80, color: Colors.white30),
                    SizedBox(height: 16),
                    Text("No videos yet", style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                    Text("Generate your first video!", style: TextStyle(color: Colors.white38)),
                  ],
                ),
              );
            }
      
            final videos = snapshot.data!.docs;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final doc = videos[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildVideoCard(
                  context,
                  data,
                  doc.id,  // Pass document ID for delete/edit operations
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> data, String docId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF1B2235), Color(0xFF252C48)],
        ),
      ),
      child: Dismissible(
        key: Key(docId),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.red,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        confirmDismiss: (direction) async {
          return await _showDeleteConfirmDialog(context);
        },
        onDismissed: (direction) async {
          await _deleteVideo(context, docId, data['videoUrl']);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF1B2235), Color(0xFF252C48)],
            ),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black26,
                  ),
                  child: const Icon(Icons.videocam,color: Color(0xFF6366F1), size: 30),
                ),
                title: Text(
                  data['title'] ?? 'AI Video',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['date']} • ${data['status']}",
                      style: TextStyle(
                        color: data['status'] == 'Completed' ? Colors.greenAccent : Colors.orangeAccent,
                        fontSize: 12,
                      ),
                    ),
                    if (data['selectedVoice'] != null)
                      Text("Voice: ${data['selectedVoice']}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        data['duration'] ?? '0:00',
                        style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit Button
                    IconButton(
                      onPressed: () {
                        _showEditDialog(context, docId, data['title'] ?? 'AI Video');
                      },
                      icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () async {
                        final shouldDelete = await _showDeleteConfirmDialog(context);
                        if (shouldDelete == true) {
                          await _deleteVideo(context, docId, data['videoUrl']);
                        }
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayScreen(
                        videoUrl: data['videoUrl'],
                        title: data['title'] ?? 'AI Video',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show edit dialog for video title
  Future<void> _showEditDialog(BuildContext context, String docId, String currentTitle) async {
    final TextEditingController titleController = TextEditingController(text: currentTitle);

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2235),
          title: const Text(
            'Edit Video Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter video name',
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF6366F1)),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.black26,
            ),
            autofocus: true,
            maxLength: 50,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty && newTitle != currentTitle) {
                  await _updateVideoTitle(context, docId, newTitle);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Update video title in Firestore
  Future<void> _updateVideoTitle(BuildContext context, String docId, String newTitle) async {
    try {
      await FirebaseFirestore.instance
          .collection('videos')
          .doc(docId)
          .update({
        'title': newTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video name updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating name: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete video from Firestore and local storage
  Future<void> _deleteVideo(BuildContext context, String docId, String videoUrl) async {
    try {
      // Delete local video file if it exists
      if (!videoUrl.startsWith('http')) {
        final videoFile = File(videoUrl);
        if (await videoFile.exists()) {
          await videoFile.delete();
          print('Local video deleted: $videoUrl');
        }
      }

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('videos')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete all videos
  Future<void> _deleteAllVideos(BuildContext context, String userId) async {
    try {
      final videosSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .where('userId', isEqualTo: userId)
          .get();

      // Delete local files first
      for (var doc in videosSnapshot.docs) {
        final data = doc.data();
        final videoUrl = data['videoUrl'];

        if (!videoUrl.startsWith('http')) {
          final videoFile = File(videoUrl);
          if (await videoFile.exists()) {
            await videoFile.delete();
          }
        }
      }

      // Delete all from Firestore
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in videosSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All videos deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting all videos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show delete confirmation dialog
  Future<bool?> _showDeleteConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2235),
          title: const Text(
            'Delete Video',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete this video? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Show delete all confirmation dialog
  void _showDeleteAllDialog(BuildContext context, String userId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2235),
          title: const Text(
            'Delete All Videos',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete ALL videos? This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete All'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _deleteAllVideos(context, userId);
    }
  }
}

// Video Player Screen (Updated with better error handling)
class VideoPlayScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayScreen({super.key, required this.videoUrl, required this.title});

  @override
  State<VideoPlayScreen> createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      if (widget.videoUrl.startsWith('http')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        final file = File(widget.videoUrl);
        if (!await file.exists()) {
          setState(() {
            _errorMessage = "Video file not found. It may have been deleted.";
          });
          return;
        }
        _controller = VideoPlayerController.file(file);
      }

      await _controller!.initialize();
      await _controller!.play();

      setState(() {
        _isInitialized = true;
        _isPlaying = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading video: $e";
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              _showVideoInfoDialog(context);
            },
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (_controller!.value.isPlaying) {
                          _controller!.pause();
                          _isPlaying = false;
                        } else {
                          _controller!.play();
                          _isPlaying = true;
                        }
                      });
                    },
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF6366F1),
                        bufferedColor: Colors.grey,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  Text(
                    _getDurationString(_controller!.value.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDurationString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showVideoInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B2235),
          title: const Text('Video Info', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${widget.title}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Text('Path: ${widget.videoUrl}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              if (_controller != null && _controller!.value.isInitialized)
                Text('Duration: ${_getDurationString(_controller!.value.duration)}',
                    style: const TextStyle(color: Colors.white70)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }
}