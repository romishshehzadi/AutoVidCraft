import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'CreateMethodSelection.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class DashboardScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onCreateVideo;

  const DashboardScreen({super.key, required this.onCreateVideo, this.userName = "User"});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> stats = [
    {
      "label": "Videos Created",
      "value": "9",
      "icon": LucideIcons.video,
      "gradient": [Color(0xFF8772FF), Color(0xFF7C5FFF)]
    },
    {
      "label": "Shared",
      "value": "5",
      "icon": LucideIcons.share2,
      "gradient": [Color(0xFF4ADE80), Color(0xFF00F260)]
    },
    {
      "label": "In Progress",
      "value": "0",
      "icon": LucideIcons.clock,
      "gradient": [Color(0xFFFFB020), Color(0xFFFFCC33)]
    },
  ];

  final List<Map<String, dynamic>> recentProjects = [
    {
      "title": "Beautiful Nature",
      "videoPath": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "duration": "0:15",
      "date": "2 days ago",
      "status": "completed",
      "thumbnail": "https://images.unsplash.com/photo-1501854140801-50d01698950b?w=400&h-300&fit=crop"
    },
    {
      "title": "City Timelapse",
      "videoPath": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "duration": "0:15",
      "date": "5 days ago",
      "status": "completed",
      "thumbnail": "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=400&h=300&fit=crop"
    },
    {
      "title": "Mountain View",
      "videoPath": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      "duration": "0:15",
      "date": "1 week ago",
      "status": "completed",
      "thumbnail": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop"
    },
    {
      "title": "Ocean Waves",
      "videoPath": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      "duration": "0:15",
      "date": "1 week ago",
      "status": "completed",
      "thumbnail": "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400&h=300&fit=crop"
    },
    {
      "title": "Forest Walk",
      "videoPath": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
      "duration": "0:15",
      "date": "2 weeks ago",
      "status": "completed",
      "thumbnail": "https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=400&h=300&fit=crop"
    },
    {
      "title": "Sunset View",
      "videoPath": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
      "duration": "0:16",
      "date": "2 weeks ago",
      "status": "processing",
      "thumbnail": "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop"
    },
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openVideoPlayer(BuildContext context, String videoPath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(
          videoPath: videoPath,
          videoTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F172A),
                Color(0xFF0F172A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome back, ${widget.userName}! ",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'font4',
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Transform your images into stunning AI-powered videos",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontFamily: 'font5',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateModeSelection(),
                              ),
                            );
                          },
                          icon: Icon(Icons.add, color: Colors.white),
                          label: Text(
                            "Create New Video",
                            style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Stats Cards
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: stats.length,
                      separatorBuilder: (_, __) => SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        return GlassmorphicContainer(
                          width: 180,
                          height: 120,
                          borderRadius: 20,
                          blur: 25,
                          alignment: Alignment.center,
                          border: 0,
                          linearGradient: LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF1E293B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFFF1F5F9),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stat["label"].toString(),
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      stat["value"].toString(),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: (stat["gradient"] as List<Color>?) ??
                                              [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                        ),
                                      ),
                                      child: Icon(
                                        stat["icon"] as IconData? ?? Icons.video_library,
                                        color: Colors.white,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),

                  // Recent Projects (Videos)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Related Videos",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'font4',
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // View all functionality
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(
                            color: Color(0xFF6366F1),
                            fontFamily: 'font6',
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recentProjects.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) {
                      final project = recentProjects[index];
                      final title = project["title"]?.toString() ?? "Untitled Video";
                      final videoPath = project["videoPath"]?.toString() ?? "";
                      final duration = project["duration"]?.toString() ?? "0:00";
                      final date = project["date"]?.toString() ?? "";
                      final status = project["status"]?.toString() ?? "completed";
                      final thumbnail = project["thumbnail"]?.toString() ?? "";

                      return GestureDetector(
                        onTap: () {
                          if (videoPath.isNotEmpty) {
                            _openVideoPlayer(context, videoPath, title);
                          }
                        },
                        child: GlassmorphicContainer(
                          borderRadius: 20,
                          blur: 25,
                          width: double.infinity,
                          height: double.infinity,
                          border: 0,
                          linearGradient: LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF1E293B),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderGradient: LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF1E293B),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  // Video Thumbnail with image
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                    child: thumbnail.isNotEmpty
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                        thumbnail,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF6366F1),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.play_circle_filled,
                                                  color: Colors.white.withOpacity(0.8),
                                                  size: 48,
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  "Click to play",
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                        : Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_circle_filled,
                                            color: Colors.white.withOpacity(0.8),
                                            size: 48,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Click to play",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Play button overlay
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF6366F1).withOpacity(0.8),
                                          ),
                                          child: Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        duration,
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  if (status == "processing")
                                    Positioned(
                                      left: 8,
                                      top: 8,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFB020).withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          "Processing",
                                          style: TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      date,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // Quick Action Card
                  GlassmorphicContainer(
                    width: double.infinity,
                    height: 170,
                    borderRadius: 20,
                    blur: 25,
                    alignment: Alignment.center,
                    border: 0,
                    linearGradient: LinearGradient(
                      colors: [
                        Color(0xFF1E293B),
                        Color(0xFF1E293B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white38,
                        Colors.white38,
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ready to create something amazing?",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'font4',
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Create stunning AI videos in minutes",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontFamily: 'font5',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CreateModeSelection(),
                                  ),
                                );
                              },
                              icon: Icon(Icons.add, color: Colors.white),
                              label: Text(
                                "Start Creating",
                                style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                              ),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.transparent,
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Video Player Screen - Optimized for Network Videos
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String videoTitle;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.videoTitle,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  bool _hasError = false;
  double _bufferedPercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _bufferedPercentage = 0.0;
      });

      // Clean up existing controllers
      if (_chewieController != null) {
        _chewieController!.dispose();
        _chewieController = null;
      }

      if (_videoPlayerController != null) {
        _videoPlayerController!.dispose();
        _videoPlayerController = null;
      }

      // Create network video controller
      final videoController = VideoPlayerController.network(widget.videoPath);

      // Listen to buffering updates
      videoController.addListener(() {
        if (mounted) {
          setState(() {
            _bufferedPercentage = videoController.value.buffered.isEmpty
                ? 0.0
                : videoController.value.buffered.last.end.inSeconds.toDouble() /
                videoController.value.duration.inSeconds.toDouble();
          });
        }
      });

      await videoController.initialize();

      // Create chewie controller
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Color(0xFF6366F1),
          handleColor: Color(0xFF8B5CF6),
          backgroundColor: Colors.grey[700]!,
          bufferedColor: Colors.grey[500]!,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 2,
                ),
                SizedBox(height: 10),
                Text(
                  'Loading video...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        autoInitialize: true,
      );

      setState(() {
        _videoPlayerController = videoController;
        _chewieController = chewieController;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing video: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.videoTitle,
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_bufferedPercentage < 1.0 && !_isLoading && !_hasError)
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  'Buffering: ${(_bufferedPercentage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF6366F1),
              strokeWidth: 2,
            ),
            SizedBox(height: 20),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              'This may take a few moments',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        )
            : _hasError
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Could not load video',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your internet connection',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initializeVideoPlayer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text('Retry'),
            ),
          ],
        )
            : _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
            ? Column(
          children: [
            Expanded(
              child: Chewie(controller: _chewieController!),
            ),
            if (_bufferedPercentage < 1.0)
              LinearProgressIndicator(
                value: _bufferedPercentage,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 20),
            Text(
              'Preparing video player...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}