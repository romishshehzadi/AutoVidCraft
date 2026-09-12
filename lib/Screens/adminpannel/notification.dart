// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../Services/firebase_admin_service.dart';
//
// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({super.key});
//
//   @override
//   State<NotificationsScreen> createState() => _NotificationsScreenState();
// }
//
// class _NotificationsScreenState extends State<NotificationsScreen> {
//   final FirebaseAdminService _adminService = FirebaseAdminService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   List<Map<String, dynamic>> _notifications = [];
//   List<Map<String, dynamic>> _filteredNotifications = [];
//
//   bool _isLoading = true;
//   bool _isProcessing = false;
//   String? _errorMessage;
//   String _selectedFilter = 'All';
//   String _searchQuery = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotifications();
//     _markAllAsRead();
//   }
//
//   // ============ LOAD NOTIFICATIONS FROM FIREBASE ============
//   Future<void> _loadNotifications() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final user = _auth.currentUser;
//       if (user == null) {
//         setState(() {
//           _isLoading = false;
//           _errorMessage = 'User not logged in';
//         });
//         return;
//       }
//
//       final snapshot = await FirebaseFirestore.instance
//           .collection('notifications')
//           .where('userId', isEqualTo: user.uid)
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       setState(() {
//         _notifications = snapshot.docs.map((doc) {
//           final data = doc.data();
//           return {
//             'id': doc.id,
//             'title': data['title'] ?? 'Notification',
//             'message': data['message'] ?? '',
//             'type': data['type'] ?? 'info',
//             'isRead': data['isRead'] ?? false,
//             'createdAt': data['createdAt'] != null
//                 ? (data['createdAt'] as Timestamp).toDate()
//                 : DateTime.now(),
//             'actionUrl': data['actionUrl'] ?? '',
//             'actionText': data['actionText'] ?? '',
//           };
//         }).toList();
//         _filteredNotifications = _notifications;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }
//
//   // ============ MARK NOTIFICATION AS READ ============
//   Future<void> _markAsRead(String notificationId) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(notificationId)
//           .update({
//         'isRead': true,
//         'readAt': FieldValue.serverTimestamp(),
//       });
//
//       setState(() {
//         final index = _notifications.indexWhere((n) => n['id'] == notificationId);
//         if (index != -1) {
//           _notifications[index]['isRead'] = true;
//         }
//         final filteredIndex = _filteredNotifications.indexWhere((n) => n['id'] == notificationId);
//         if (filteredIndex != -1) {
//           _filteredNotifications[filteredIndex]['isRead'] = true;
//         }
//       });
//     } catch (e) {
//       print('Error marking as read: $e');
//     }
//   }
//
//   // ============ MARK ALL AS READ ============
//   Future<void> _markAllAsRead() async {
//     try {
//       final batch = FirebaseFirestore.instance.batch();
//       for (var notification in _notifications) {
//         if (notification['isRead'] == false) {
//           final ref = FirebaseFirestore.instance
//               .collection('notifications')
//               .doc(notification['id']);
//           batch.update(ref, {'isRead': true, 'readAt': FieldValue.serverTimestamp()});
//         }
//       }
//       await batch.commit();
//     } catch (e) {
//       print('Error marking all as read: $e');
//     }
//   }
//
//   // ============ DELETE NOTIFICATION ============
//   Future<void> _deleteNotification(String notificationId) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E293B),
//         title: const Text('Delete Notification', style: TextStyle(color: Colors.white)),
//         content: const Text('Are you sure you want to delete this notification?',
//             style: TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed != true) return;
//
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       await FirebaseFirestore.instance
//           .collection('notifications')
//           .doc(notificationId)
//           .delete();
//
//       setState(() {
//         _notifications.removeWhere((n) => n['id'] == notificationId);
//         _applyFilters();
//         _isProcessing = false;
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Notification deleted'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   // ============ DELETE ALL NOTIFICATIONS ============
//   Future<void> _deleteAllNotifications() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E293B),
//         title: const Text('Delete All Notifications', style: TextStyle(color: Colors.white)),
//         content: const Text('Are you sure you want to delete ALL notifications? This action cannot be undone.',
//             style: TextStyle(color: Colors.white70)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete All', style: TextStyle(color: Colors.redAccent)),
//           ),
//         ],
//       ),
//     );
//
//     if (confirmed != true) return;
//
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       final batch = FirebaseFirestore.instance.batch();
//       for (var notification in _notifications) {
//         batch.delete(FirebaseFirestore.instance.collection('notifications').doc(notification['id']));
//       }
//       await batch.commit();
//
//       setState(() {
//         _notifications = [];
//         _applyFilters();
//         _isProcessing = false;
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('All notifications deleted'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _isProcessing = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }
//
//   // ============ APPLY FILTERS ============
//   void _applyFilters() {
//     List<Map<String, dynamic>> filtered = List.from(_notifications);
//
//     // Apply type filter
//     if (_selectedFilter != 'All') {
//       filtered = filtered.where((n) => n['type'] == _selectedFilter).toList();
//     }
//
//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((n) =>
//       n['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
//           n['message'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
//       ).toList();
//     }
//
//     setState(() {
//       _filteredNotifications = filtered;
//     });
//   }
//
//   void _searchNotifications(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//     _applyFilters();
//   }
//
//   // ============ GET COLOR BASED ON NOTIFICATION TYPE ============
//   Color getColor(String type) {
//     switch (type) {
//       case 'warning':
//         return Colors.redAccent;
//       case 'success':
//         return Colors.greenAccent;
//       case 'error':
//         return Colors.redAccent;
//       case 'info':
//         return Colors.tealAccent;
//       default:
//         return Colors.tealAccent;
//     }
//   }
//
//   IconData getIcon(String type) {
//     switch (type) {
//       case 'warning':
//         return Icons.warning_amber_rounded;
//       case 'success':
//         return Icons.check_circle;
//       case 'error':
//         return Icons.error_outline;
//       case 'info':
//         return Icons.info_outline;
//       default:
//         return Icons.notifications;
//     }
//   }
//
//   int getUnreadCount() {
//     return _notifications.where((n) => n['isRead'] == false).length;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: const Color(0xFF0F172A),
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: const Text(
//             "Notifications",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           flexibleSpace: Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           actions: [
//             // Mark all as read button
//             if (getUnreadCount() > 0)
//               IconButton(
//                 icon: const Icon(Icons.done_all, color: Colors.white),
//                 onPressed: () {
//                   _markAllAsRead();
//                   _loadNotifications();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('All marked as read'), backgroundColor: Colors.green),
//                   );
//                 },
//                 tooltip: 'Mark all as read',
//               ),
//             // Delete all button
//             if (_notifications.isNotEmpty)
//               IconButton(
//                 icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
//                 onPressed: _deleteAllNotifications,
//                 tooltip: 'Delete all',
//               ),
//           ],
//         ),
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 // Search Bar
//                 _buildSearchBar(),
//
//                 // Filter Chips
//                 _buildFilterChips(),
//
//                 // Stats Row
//                 _buildStatsRow(),
//                 const SizedBox(height: 8),
//
//                 // Notifications List
//                 Expanded(
//                   child: _buildNotificationsList(),
//                 ),
//               ],
//             ),
//
//             // Loading Overlay
//             if (_isProcessing)
//               Container(
//                 color: Colors.black54,
//                 child: const Center(
//                   child: CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: TextField(
//         style: const TextStyle(color: Colors.white),
//         onChanged: _searchNotifications,
//         decoration: InputDecoration(
//           hintText: 'Search notifications...',
//           hintStyle: const TextStyle(color: Colors.white54),
//           prefixIcon: const Icon(Icons.search, color: Colors.white54),
//           suffixIcon: _searchQuery.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Icons.clear, color: Colors.white54),
//             onPressed: () {
//               _searchNotifications('');
//               setState(() {
//                 _searchQuery = '';
//               });
//             },
//           )
//               : null,
//           filled: true,
//           fillColor: Colors.white12,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterChips() {
//     final List<String> filters = ['All', 'info', 'success', 'warning', 'error'];
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: filters.map((filter) {
//             return Padding(
//               padding: const EdgeInsets.only(right: 8),
//               child: FilterChip(
//                 label: Text(
//                   filter == 'All' ? 'All' : filter[0].toUpperCase() + filter.substring(1),
//                   style: TextStyle(
//                     color: _selectedFilter == filter ? Colors.black : Colors.white,
//                   ),
//                 ),
//                 selected: _selectedFilter == filter,
//                 onSelected: (selected) {
//                   setState(() {
//                     _selectedFilter = selected ? filter : 'All';
//                   });
//                   _applyFilters();
//                 },
//                 backgroundColor: Colors.white12,
//                 selectedColor: Colors.tealAccent,
//                 checkmarkColor: Colors.black,
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatsRow() {
//     final int unreadCount = getUnreadCount();
//     final int totalCount = _notifications.length;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.white10,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 children: [
//                   const Text('Total', style: TextStyle(color: Colors.white54, fontSize: 10)),
//                   Text('$totalCount', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.tealAccent.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
//               ),
//               child: Column(
//                 children: [
//                   const Text('Unread', style: TextStyle(color: Colors.white54, fontSize: 10)),
//                   Text('$unreadCount', style: const TextStyle(color: Colors.tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationsList() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//         ),
//       );
//     }
//
//     if (_errorMessage != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
//             const SizedBox(height: 16),
//             Text(
//               'Error: $_errorMessage',
//               style: const TextStyle(color: Colors.white),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadNotifications,
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (_filteredNotifications.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.notifications_none, size: 64, color: Colors.white54),
//             const SizedBox(height: 16),
//             Text(
//               _searchQuery.isNotEmpty || _selectedFilter != 'All'
//                   ? 'No notifications match your filters'
//                   : 'No notifications yet',
//               style: const TextStyle(color: Colors.white54, fontSize: 16),
//             ),
//             if (_searchQuery.isNotEmpty || _selectedFilter != 'All') ...[
//               const SizedBox(height: 8),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _searchQuery = '';
//                     _selectedFilter = 'All';
//                   });
//                   _applyFilters();
//                 },
//                 child: const Text('Clear filters'),
//               ),
//             ],
//           ],
//         ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: _filteredNotifications.length,
//       itemBuilder: (context, index) {
//         final notification = _filteredNotifications[index];
//         final String type = notification['type'] ?? 'info';
//         final bool isRead = notification['isRead'] ?? false;
//
//         return Dismissible(
//           key: Key(notification['id']),
//           direction: DismissDirection.endToStart,
//           background: Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               color: Colors.red,
//             ),
//             alignment: Alignment.centerRight,
//             padding: const EdgeInsets.only(right: 20),
//             child: const Icon(Icons.delete, color: Colors.white, size: 30),
//           ),
//           confirmDismiss: (direction) async {
//             return await showDialog<bool>(
//               context: context,
//               builder: (context) => AlertDialog(
//                 backgroundColor: const Color(0xFF1E293B),
//                 title: const Text('Delete', style: TextStyle(color: Colors.white)),
//                 content: const Text('Delete this notification?', style: TextStyle(color: Colors.white70)),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, false),
//                     child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, true),
//                     child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
//                   ),
//                 ],
//               ),
//             );
//           },
//           onDismissed: (direction) {
//             _deleteNotification(notification['id']);
//           },
//           child: Card(
//             color: isRead ? Colors.white10 : Colors.white.withOpacity(0.15),
//             margin: const EdgeInsets.only(bottom: 8),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//               side: !isRead ? BorderSide(color: getColor(type), width: 1) : BorderSide.none,
//             ),
//             child: InkWell(
//               onTap: () {
//                 if (!isRead) {
//                   _markAsRead(notification['id']);
//                 }
//                 _showNotificationDetails(notification);
//               },
//               borderRadius: BorderRadius.circular(12),
//               child: ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: getColor(type).withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(
//                     getIcon(type),
//                     color: getColor(type),
//                     size: 24,
//                   ),
//                 ),
//                 title: Text(
//                   notification['title'] ?? 'Notification',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 subtitle: Text(
//                   notification['message'] ?? '',
//                   style: const TextStyle(color: Colors.white54, fontSize: 12),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 trailing: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       _formatTime(notification['createdAt']),
//                       style: const TextStyle(color: Colors.white38, fontSize: 10),
//                     ),
//                     if (!isRead)
//                       Container(
//                         margin: const EdgeInsets.only(top: 4),
//                         width: 8,
//                         height: 8,
//                         decoration: BoxDecoration(
//                           color: getColor(type),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   void _showNotificationDetails(Map<String, dynamic> notification) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xFF1E293B),
//         title: Row(
//           children: [
//             Icon(getIcon(notification['type']), color: getColor(notification['type']), size: 28),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 notification['title'] ?? 'Notification',
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               notification['message'] ?? '',
//               style: const TextStyle(color: Colors.white70, fontSize: 14),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Received: ${_formatDateTime(notification['createdAt'])}',
//               style: const TextStyle(color: Colors.white38, fontSize: 11),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close', style: TextStyle(color: Colors.white54)),
//           ),
//           if (notification['actionUrl'] != null && notification['actionUrl'].isNotEmpty)
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 // Navigate to action URL
//                 // You can implement navigation based on actionUrl
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6366F1),
//               ),
//               child: Text(notification['actionText'] ?? 'View'),
//             ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(dynamic dateTime) {
//     if (dateTime == null) return '';
//     if (dateTime is DateTime) {
//       final now = DateTime.now();
//       final diff = now.difference(dateTime);
//
//       if (diff.inDays > 7) {
//         return '${dateTime.day}/${dateTime.month}';
//       } else if (diff.inDays > 0) {
//         return '${diff.inDays}d ago';
//       } else if (diff.inHours > 0) {
//         return '${diff.inHours}h ago';
//       } else if (diff.inMinutes > 0) {
//         return '${diff.inMinutes}m ago';
//       } else {
//         return 'Just now';
//       }
//     }
//     return '';
//   }
//
//   String _formatDateTime(dynamic dateTime) {
//     if (dateTime == null) return 'Unknown';
//     if (dateTime is DateTime) {
//       return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//     }
//     return 'Unknown';
//   }
// }