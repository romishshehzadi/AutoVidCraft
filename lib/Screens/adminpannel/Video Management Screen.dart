import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import '../../../Services/firebase_admin_service.dart';

class VideoManagementScreen extends StatefulWidget {
  const VideoManagementScreen({super.key});

  @override
  State<VideoManagementScreen> createState() => _VideoManagementScreenState();
}

class _VideoManagementScreenState extends State<VideoManagementScreen> {
  final FirebaseAdminService _adminService = FirebaseAdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _filteredVideos = [];

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videos = await _adminService.getAllVideos();
      setState(() {
        _videos = videos;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_videos);

    if (_selectedStatusFilter != 'All') {
      filtered = filtered.where((video) =>
      video['status'] == _selectedStatusFilter
      ).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((video) =>
      video['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          video['userName'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          video['userId'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    setState(() {
      _filteredVideos = filtered;
    });
  }

  void _searchVideos(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  Future<void> _updateVideoStatus(Map<String, dynamic> video, String newStatus) async {
    final String action = newStatus == 'Approved' ? 'approve' : 'reject';

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('${newStatus} Video', style: const TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to $action "${video['title']}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              newStatus,
              style: TextStyle(color: newStatus == 'Approved' ? Colors.greenAccent : Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    final bool success = await _adminService.updateVideoStatus(video['id'], newStatus);

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      await _loadVideos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video ${video['title']} ${newStatus.toLowerCase()} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update video status'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteVideo(Map<String, dynamic> video) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete Video', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${video['title']}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    // Also delete local file if exists
    final videoUrl = video['videoUrl'];
    if (videoUrl != null && !videoUrl.startsWith('http')) {
      final videoFile = File(videoUrl);
      if (await videoFile.exists()) {
        await videoFile.delete();
      }
    }

    final bool success = await _adminService.deleteVideo(video['id']);

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      await _loadVideos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted successfully'), backgroundColor: Colors.green),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete video'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ============ PLAY VIDEO FUNCTION ============
  void _playVideo(Map<String, dynamic> video) {
    final String videoUrl = video['videoUrl'] ?? '';
    final String title = video['title'] ?? 'Video';

    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video URL not found'), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayScreen(
          videoUrl: videoUrl,
          title: title,
        ),
      ),
    );
  }

  void _viewVideoDetails(Map<String, dynamic> video) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(video['title'] ?? 'Video Details', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('User:', video['userName'] ?? 'Unknown'),
              const SizedBox(height: 8),
              _buildDetailRow('User ID:', video['userId'] ?? 'No User ID'),
              const SizedBox(height: 8),
              _buildDetailRow('Email:', video['userEmail'] ?? 'No email'),
              const SizedBox(height: 8),
              _buildDetailRow('Status:', video['status'] ?? 'Pending'),
              const SizedBox(height: 8),
              _buildDetailRow('Views:', '${video['views'] ?? 0}'),
              const SizedBox(height: 8),
              _buildDetailRow('Likes:', '${video['likes'] ?? 0}'),
              const SizedBox(height: 8),
              _buildDetailRow('Duration:', video['duration'] ?? '00:00'),
              const SizedBox(height: 8),
              _buildDetailRow('Created:', _formatDate(video['createdAt'])),
              if (video['description'] != null && video['description'].isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildDetailRow('Description:', video['description']),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Unknown';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return 'Unknown';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.greenAccent;
      case 'pending':
        return Colors.orangeAccent;
      case 'rejected':
        return Colors.redAccent;
      default:
        return Colors.white54;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_empty;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Video Management Admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'font4',
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadVideos,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                _buildSearchAndFilter(),
                _buildStatsRow(),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildVideoList(),
                ),
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            style: const TextStyle(color: Colors.white),
            onChanged: _searchVideos,
            decoration: InputDecoration(
              hintText: 'Search by title, user or User ID...',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () {
                  _searchVideos('');
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white12,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'All'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending', 'Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Approved', 'Approved'),
                const SizedBox(width: 8),
                _buildFilterChip('Rejected', 'Rejected'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label, style: TextStyle(
        color: _selectedStatusFilter == value ? Colors.white : Colors.white,
      )),
      selected: _selectedStatusFilter == value,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? value : 'All';
        });
        _applyFilters();
      },
      backgroundColor: Colors.white12,
      selectedColor: Colors.deepPurpleAccent,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildStatsRow() {
    final int totalVideos = _videos.length;
    final int approvedCount = _videos.where((v) => v['status'] == 'Approved').length;
    final int pendingCount = _videos.where((v) => v['status'] == 'Pending').length;
    final int rejectedCount = _videos.where((v) => v['status'] == 'Rejected').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard('Total', totalVideos, Colors.white),
          const SizedBox(width: 8),
          _buildStatCard('Approved', approvedCount, Colors.greenAccent),
          const SizedBox(width: 8),
          _buildStatCard('Pending', pendingCount, Colors.orangeAccent),
          const SizedBox(width: 8),
          _buildStatCard('Rejected', rejectedCount, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 10)),
            Text('$count', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideos,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedStatusFilter != 'All'
                  ? 'No videos match your filters'
                  : 'No videos found',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
            if (_searchQuery.isNotEmpty || _selectedStatusFilter != 'All') ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedStatusFilter = 'All';
                  });
                  _applyFilters();
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredVideos.length,
      itemBuilder: (context, index) {
        final Map<String, dynamic> video = _filteredVideos[index];
        final String status = video['status'] ?? 'Pending';
        final Color statusColor = _getStatusColor(status);
        final bool isPending = status == 'Pending';

        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.2),
              child: Icon(
                _getStatusIcon(status),
                color: statusColor,
                size: 20,
              ),
            ),
            title: Text(
              video['title'] ?? 'Untitled',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By: ${video['userName'] ?? 'Unknown'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'User ID: ${video['userId'] ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
                Text(
                  'Views: ${video['views'] ?? 0} • Created: ${_formatDate(video['createdAt'])}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play Button - Click to play video
                IconButton(
                  onPressed: () => _playVideo(video),
                  icon: const Icon(Icons.play_circle_filled, color: Colors.tealAccent, size: 28),
                  tooltip: 'Play Video',
                ),
                // View Details Button
                IconButton(
                  onPressed: () => _viewVideoDetails(video),
                  icon: const Icon(Icons.info, color: Colors.blueAccent, size: 22),
                  tooltip: 'View Details',
                ),
                // Approve Button (only for pending)
                if (isPending)
                  IconButton(
                    onPressed: () => _updateVideoStatus(video, 'Approved'),
                    icon: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 22),
                    tooltip: 'Approve',
                  ),
                // Reject Button (only for pending)
                if (isPending)
                  IconButton(
                    onPressed: () => _updateVideoStatus(video, 'Rejected'),
                    icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 22),
                    tooltip: 'Reject',
                  ),
                // Delete Button
                IconButton(
                  onPressed: () => _deleteVideo(video),
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============ VIDEO PLAYER SCREEN ============
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
        // Network video (from Firebase Storage or URL)
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        // Local file video
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
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white, size: 30),
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
}