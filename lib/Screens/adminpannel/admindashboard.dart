import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../Services/firebase_admin_service.dart';
import '../AuthScreen.dart'; // ← IMPORT ADD KARO

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseAdminService _adminService = FirebaseAdminService();

  bool _isLoading = true;
  bool _isLoggingOut = false;
  String? _errorMessage;

  // Data variables
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _videoTrends = [];
  List<Map<String, dynamic>> _aiModels = [];
  List<Map<String, dynamic>> _recentUsers = [];
  List<Map<String, dynamic>> _serverStatus = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await _adminService.getDashboardStats();
      final videoTrends = await _adminService.getVideoTrends();
      final aiModels = await _adminService.getAIModelPerformance();
      final recentUsers = await _adminService.getRecentUsers();
      final serverStatus = await _adminService.getServerStatus();

      setState(() {
        _stats = stats;
        _videoTrends = videoTrends;
        // Filter only BLIP and Text-to-Video models
        _aiModels = aiModels.where((model) {
          final modelName = model['model'] as String;
          return modelName == 'BLIP' ||
              modelName == 'Text-to-Video' ||
              modelName == 'BLIP Model' ||
              modelName == 'Text to Video';
        }).toList();

        // If no data from Firebase, use default
        if (_aiModels.isEmpty) {
          _aiModels = [
            {'model': 'BLIP Model', 'avgTime': 8.5, 'success': 97.5},
            {'model': 'Text-to-Video', 'avgTime': 42.3, 'success': 94.8},
          ];
        }

        _recentUsers = recentUsers;
        _serverStatus = serverStatus;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadAllData();
  }

  // ============ LOGOUT METHOD (UPDATED - WORKING) ============
  Future<void> _logoutUser() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Sign out from Firebase Auth
      await FirebaseAuth.instance.signOut();

      // Small delay to ensure sign out completes
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to Auth screen - Direct widget navigation (no route name needed)
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

  // ============ LOGOUT DIALOG (UPDATED - WORKING) ============
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to logout?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                // Call logout function
                await _logoutUser();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Center(
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
                  onPressed: _refreshData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatsGrid(),
                      const SizedBox(height: 16),
                      _buildVideoTrendsChart(),
                      const SizedBox(height: 16),
                      _buildAIModelTable(),
                      const SizedBox(height: 16),
                      _buildRecentUsersList(),
                      const SizedBox(height: 16),
                      _buildServerStatus(),
                    ],
                  ),
                ),
              ),
              // Loading overlay when logging out
              if (_isLoggingOut)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Logging out...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ APP BAR ============

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF641FE6), Color(0xFF7A3BFD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Admin Dashboard",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'font4',
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _refreshData,
        ),
        IconButton(
          icon: const Icon(Icons.exit_to_app, color: Colors.white),
          onPressed: () {
            _showLogoutDialog();
          },
        ),
      ],
    );
  }

  // ============ STATS GRID ============

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatsCard(
          "Total Users",
          _stats['totalUsers']?.toString() ?? '0',
          _stats['growth']?['users'] ?? '+0%',
          Icons.people,
          Colors.purpleAccent,
        ),
        _buildStatsCard(
          "Videos Generated",
          _stats['totalVideos']?.toString() ?? '0',
          _stats['growth']?['videos'] ?? '+0%',
          Icons.videocam,
          Colors.blueAccent,
        ),
        _buildStatsCard(
          "Active Sessions",
          _stats['activeSessions']?.toString() ?? '0',
          _stats['growth']?['sessions'] ?? '+0%',
          Icons.play_arrow,
          Colors.tealAccent,
        ),
        _buildStatsCard(
          "Total Views",
          _stats['totalViews']?.toString() ?? '0',
          _stats['growth']?['views'] ?? '+0%',
          Icons.visibility,
          Colors.pinkAccent,
        ),
      ],
    );
  }

  Widget _buildStatsCard(String label, String value, String change, IconData icon, Color iconColor) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withOpacity(0.2),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: Colors.greenAccent),
              const SizedBox(width: 4),
              Text(
                change,
                style: const TextStyle(color: Colors.greenAccent, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  "vs last week",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ VIDEO TRENDS CHART ============

  Widget _buildVideoTrendsChart() {
    if (_videoTrends.isEmpty) {
      return _glassCard(
        child: const Center(
          child: Text("No video data available", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Video Generation Trends",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < _videoTrends.length) {
                          return Text(
                            _videoTrends[index]['date'] as String,
                            style: const TextStyle(color: Colors.white70, fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      _videoTrends.length,
                          (index) => FlSpot(
                        index.toDouble(),
                        (_videoTrends[index]['videos'] as num).toDouble(),
                      ),
                    ),
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.3),
                          const Color(0xFF8B5CF6).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ AI MODEL TABLE ============

  Widget _buildAIModelTable() {
    if (_aiModels.isEmpty) {
      return _glassCard(
        child: const Center(
          child: Text("No AI model data available", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "AI Model Performance",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: SizedBox(width: 150, child: Text('Model', style: TextStyle(color: Colors.white70)))),
                  DataColumn(label: SizedBox(width: 80, child: Text('Avg Time', style: TextStyle(color: Colors.white70)))),
                  DataColumn(label: SizedBox(width: 150, child: Text('Success Rate', style: TextStyle(color: Colors.white70)))),
                ],
                rows: _aiModels.map((model) {
                  return DataRow(cells: [
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Row(
                          children: [
                            Icon(
                              model['model'] == 'BLIP Model' ? Icons.image : Icons.video_library,
                              color: Colors.tealAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                model['model'] as String,
                                style: const TextStyle(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 80,
                        child: Text(
                          "${model['avgTime']}s",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (model['success'] as num).toDouble() / 100,
                                    backgroundColor: Colors.white24,
                                    valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "${model['success']}%",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getPerformanceStatus(model['success'] as num),
                              style: TextStyle(
                                color: _getPerformanceColor(model['success'] as num),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceStatus(num successRate) {
    if (successRate >= 98) return 'Excellent';
    if (successRate >= 95) return 'Good';
    if (successRate >= 90) return 'Average';
    return 'Needs Improvement';
  }

  Color _getPerformanceColor(num successRate) {
    if (successRate >= 98) return Colors.greenAccent;
    if (successRate >= 95) return Colors.tealAccent;
    if (successRate >= 90) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  // ============ RECENT USERS LIST ============

  Widget _buildRecentUsersList() {
    if (_recentUsers.isEmpty) {
      return _glassCard(
        child: const Center(
          child: Text("No users found", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Users",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentUsers.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final user = _recentUsers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.deepPurpleAccent,
                      radius: 20,
                      child: Text(
                        user['name'].toString()[0],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user['email'] as String,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${user['videos']} videos",
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          user['joined'] as String,
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============ SERVER STATUS ============

  Widget _buildServerStatus() {
    if (_serverStatus.isEmpty) {
      return _glassCard(
        child: const Center(
          child: Text("No server data available", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Server Status",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ..._serverStatus.map((server) {
            bool isOnline = server['status'] == 'online';
            bool highLoad = (server['load'] as int) > 80;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          server['name'] as String,
                          style: const TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        server['latency'] as String,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (server['load'] as int) / 100,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation(
                            highLoad ? Colors.redAccent : Colors.tealAccent,
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${server['load']}%",
                        style: TextStyle(
                          color: highLoad ? Colors.redAccent : Colors.tealAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ============ GLASS CARD WIDGET ============

  Widget _glassCard({required Widget child, double radius = 16}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: child,
        ),
      ),
    );
  }
}