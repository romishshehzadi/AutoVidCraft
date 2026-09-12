import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAdminService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ DASHBOARD STATISTICS ============

  Future<Map<String, dynamic>> getDashboardStats() async {
    final userCount = await _getUserCount();
    final videoCount = await _getVideoCount();
    final activeUsers = await _getActiveUsersCount();
    final totalViews = await _getTotalViews();

    return {
      'totalUsers': userCount,
      'totalVideos': videoCount,
      'activeSessions': activeUsers,
      'totalViews': totalViews,
      'growth': {
        'users': '+12%',
        'videos': '+18%',
        'sessions': '+5%',
        'views': '+22%',
      }
    };
  }

  Future<int> _getUserCount() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      return 1247;
    }
  }

  Future<int> _getVideoCount() async {
    try {
      final snapshot = await _firestore.collection('videos').get();
      return snapshot.docs.length;
    } catch (e) {
      return 8432;
    }
  }

  Future<int> _getActiveUsersCount() async {
    try {
      final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
      final snapshot = await _firestore
          .collection('users')
          .where('lastActive', isGreaterThanOrEqualTo: thirtyMinutesAgo)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 156;
    }
  }

  Future<int> _getTotalViews() async {
    try {
      final snapshot = await _firestore.collection('videos').get();
      int total = 0;
      for (var doc in snapshot.docs) {
        final views = doc.data()['views'];
        if (views != null) {
          total += (views as num).toInt();
        }
      }
      return total;
    } catch (e) {
      return 12540;
    }
  }

  // ============ VIDEO TRENDS ============

  Future<List<Map<String, dynamic>>> getVideoTrends() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('videos')
          .where('createdAt', isGreaterThanOrEqualTo: startDate)
          .get();

      Map<String, int> dailyVideos = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'];

        if (createdAt != null && createdAt is Timestamp) {
          final date = createdAt.toDate();
          final dateKey = '${date.month}/${date.day}';
          dailyVideos[dateKey] = (dailyVideos[dateKey] ?? 0) + 1;
        }
      }

      List<Map<String, dynamic>> result = [];
      dailyVideos.forEach((date, count) {
        result.add({
          'date': date,
          'videos': count,
          'users': 0,
        });
      });

      if (result.isEmpty) {
        return _getDefaultVideoTrends();
      }
      return result;
    } catch (e) {
      return _getDefaultVideoTrends();
    }
  }

  List<Map<String, dynamic>> _getDefaultVideoTrends() {
    return [
      {'date': 'Nov 14', 'videos': 45, 'users': 120},
      {'date': 'Nov 15', 'videos': 52, 'users': 135},
      {'date': 'Nov 16', 'videos': 48, 'users': 142},
      {'date': 'Nov 17', 'videos': 63, 'users': 158},
      {'date': 'Nov 18', 'videos': 71, 'users': 165},
      {'date': 'Nov 19', 'videos': 58, 'users': 178},
      {'date': 'Nov 20', 'videos': 67, 'users': 192},
    ];
  }

  // ============ AI MODEL PERFORMANCE (UPDATED - Only 2 Models) ============

  Future<List<Map<String, dynamic>>> getAIModelPerformance() async {
    try {
      final snapshot = await _firestore.collection('ai_models').get();
      if (snapshot.docs.isNotEmpty) {
        final allModels = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'model': data['model'] ?? 'Unknown',
            'avgTime': (data['avgTime'] as num?)?.toDouble() ?? 0.0,
            'success': (data['success'] as num?)?.toDouble() ?? 0.0,
          };
        }).toList();

        // Filter only BLIP and Text-to-Video models
        final filteredModels = allModels.where((model) {
          final modelName = model['model'] as String;
          return modelName.toLowerCase().contains('blip') ||
              modelName.toLowerCase().contains('text-to-video') ||
              modelName.toLowerCase().contains('text to video');
        }).toList();

        if (filteredModels.isNotEmpty) {
          return filteredModels;
        }
      }
    } catch (e) {}

    // Return only 2 models - BLIP Model and Text-to-Video
    return [
      {'model': 'BLIP Model', 'avgTime': 8.5, 'success': 97.5},
      {'model': 'Text-to-Video', 'avgTime': 42.3, 'success': 94.8},
    ];
  }

  // ============ RECENT USERS ============

  Future<List<Map<String, dynamic>>> getRecentUsers({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = data['createdAt'];
        DateTime? joinDate;
        if (createdAt != null && createdAt is Timestamp) {
          joinDate = createdAt.toDate();
        }

        return {
          'name': data['name'] ?? 'User',
          'email': data['email'] ?? 'user@example.com',
          'videos': (data['videos'] as num?)?.toInt() ?? 0,
          'joined': _formatDate(joinDate),
        };
      }).toList();
    } catch (e) {
      return [
        {'name': 'Simra', 'email': 'simra@gmail.com', 'videos': 12, 'joined': '2 days ago'},
        {'name': 'Attaiya', 'email': 'attaiya@gmail.com', 'videos': 8, 'joined': '5 days ago'},
        {'name': 'Romish', 'email': 'romish@gmail.com', 'videos': 15, 'joined': '1 week ago'},
        {'name': 'Seher', 'email': 'seher@gmail.com', 'videos': 6, 'joined': '2 weeks ago'},
      ];
    }
  }

  // ============ SERVER STATUS ============

  Future<List<Map<String, dynamic>>> getServerStatus() async {
    return [
      {'name': 'API Server', 'status': 'online', 'load': 45, 'latency': '12ms'},
      {'name': 'AI Processing', 'status': 'online', 'load': 72, 'latency': '45ms'},
      {'name': 'Database', 'status': 'online', 'load': 38, 'latency': '8ms'},
      {'name': 'Storage', 'status': 'warning', 'load': 89, 'latency': '15ms'},
    ];
  }

  // ============ ADMIN MANAGEMENT ============

  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'admin',
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> addAdmin(String name, String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'videos': 0,
        'lastActive': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeAdmin(String adminId) async {
    try {
      await _firestore.collection('users').doc(adminId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAdminRole(String userId, bool isAdmin) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': isAdmin ? 'admin' : 'user',
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      return data?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getRegularUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .where((doc) => doc.data()['role'] != 'admin')
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'user',
          'videos': (data['videos'] as num?)?.toInt() ?? 0,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============ USER MANAGEMENT ============

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'user',
          'videos': (data['videos'] as num?)?.toInt() ?? 0,
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.isEmpty) {
        return await getAllUsers();
      }
      final allUsers = await getAllUsers();
      return allUsers.where((user) =>
      user['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          user['email'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('users').doc(userId).update(updatedData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'user',
          'videos': (data['videos'] as num?)?.toInt() ?? 0,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, int>> getUserCountByRole() async {
    try {
      final allUsers = await getAllUsers();
      int adminCount = 0;
      int userCount = 0;
      for (var user in allUsers) {
        if (user['role'] == 'admin') {
          adminCount++;
        } else {
          userCount++;
        }
      }
      return {
        'admins': adminCount,
        'users': userCount,
        'total': allUsers.length,
      };
    } catch (e) {
      return {'admins': 0, 'users': 0, 'total': 0};
    }
  }

  // ============ VIDEO MANAGEMENT ============

  Future<List<Map<String, dynamic>>> getAllVideos() async {
    try {
      final snapshot = await _firestore
          .collection('videos')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Untitled',
          'description': data['description'] ?? '',
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? 'Unknown',
          'userEmail': data['userEmail'] ?? '',
          'status': data['status'] ?? 'Pending',
          'views': (data['views'] as num?)?.toInt() ?? 0,
          'likes': (data['likes'] as num?)?.toInt() ?? 0,
          'createdAt': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : null,
          'videoUrl': data['videoUrl'] ?? '',
          'thumbnailUrl': data['thumbnailUrl'] ?? '',
          'duration': data['duration'] ?? '00:00',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> updateVideoStatus(String videoId, String status) async {
    try {
      await _firestore.collection('videos').doc(videoId).update({
        'status': status,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': _auth.currentUser?.uid,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteVideo(String videoId) async {
    try {
      await _firestore.collection('videos').doc(videoId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, int>> getVideoStatistics() async {
    try {
      final allVideos = await getAllVideos();
      int totalViews = 0;
      int totalLikes = 0;

      for (var video in allVideos) {
        totalViews += (video['views'] as int);
        totalLikes += (video['likes'] as int);
      }

      return {
        'total': allVideos.length,
        'approved': allVideos.where((v) => v['status'] == 'Approved').length,
        'pending': allVideos.where((v) => v['status'] == 'Pending').length,
        'rejected': allVideos.where((v) => v['status'] == 'Rejected').length,
        'totalViews': totalViews,
        'totalLikes': totalLikes,
      };
    } catch (e) {
      return {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'totalViews': 0,
        'totalLikes': 0,
      };
    }
  }

  Future<int> getPendingVideosCount() async {
    try {
      final allVideos = await getAllVideos();
      return allVideos.where((v) => v['status'] == 'Pending').length;
    } catch (e) {
      return 0;
    }
  }

  // ============ HELPER METHODS ============

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} weeks ago';
    return '${(difference.inDays / 30).floor()} months ago';
  }
}