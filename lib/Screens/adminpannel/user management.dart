import 'package:flutter/material.dart';
import '../../Services/firebase_admin_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final FirebaseAdminService _adminService = FirebaseAdminService();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  /// LOAD USERS FROM FIREBASE
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _adminService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// SEARCH FUNCTION - Using Firebase Search
  void _searchUser(String query) async {
    setState(() {
      _searchQuery = query;
      _isLoading = true;
    });

    try {
      final results = await _adminService.searchUsers(query);
      setState(() {
        _filteredUsers = results;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to local search if Firebase search fails
      final localResults = _users.where((user) =>
      user['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          user['email'].toString().toLowerCase().contains(query.toLowerCase())
      ).toList();
      setState(() {
        _filteredUsers = localResults;
        _isLoading = false;
      });
    }
  }

  /// EDIT USER FUNCTION - Updates in Firebase
  void _editUser(Map<String, dynamic> user, int index) async {
    final TextEditingController nameCtrl =
    TextEditingController(text: user['name']);
    final TextEditingController emailCtrl =
    TextEditingController(text: user['email']);
    String selectedRole = user['role'] ?? 'user';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              title: const Text("Edit User", style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Role",
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User', style: TextStyle(color: Colors.white))),
                      DropdownMenuItem(value: 'admin', child: Text('Admin', style: TextStyle(color: Colors.white))),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'name': nameCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'role': selectedRole,
                    });
                  },
                  child: const Text("Save", style: TextStyle(color: Colors.tealAccent)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _isProcessing = true;
      });

      final success = await _adminService.updateUser(user['id'], {
        'name': result['name'],
        'email': result['email'],
        'role': result['role'],
      });

      setState(() {
        _isProcessing = false;
      });

      if (success) {
        await _loadUsers();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update user'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// DELETE USER FUNCTION - Deletes from Firebase
  void _deleteUser(Map<String, dynamic> user, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${user['name']}?',
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

    final success = await _adminService.deleteUser(user['id']);

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      await _loadUsers();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// MAKE ADMIN / REMOVE ADMIN FUNCTION
  void _toggleAdminRole(Map<String, dynamic> user, int index) async {
    final isAdmin = user['role'] == 'admin';
    final newRole = isAdmin ? 'user' : 'admin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isAdmin ? 'Remove Admin Rights' : 'Make Admin',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isAdmin
              ? 'Are you sure you want to remove admin rights from ${user['name']}?'
              : 'Are you sure you want to make ${user['name']} an admin?',
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
              isAdmin ? 'Remove' : 'Make Admin',
              style: TextStyle(color: isAdmin ? Colors.redAccent : Colors.tealAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isProcessing = true;
    });

    final success = await _adminService.updateAdminRole(user['id'], !isAdmin);

    setState(() {
      _isProcessing = false;
    });

    if (success) {
      await _loadUsers();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newRole == 'admin'
                ? '${user['name']} is now an admin'
                : 'Admin rights removed from ${user['name']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user role'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            "User Management",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
              onPressed: _loadUsers,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    onChanged: _searchUser,
                    decoration: InputDecoration(
                      hintText: 'Search Users...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchUser('');
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
                  const SizedBox(height: 16),

                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 16),

                  // User List
                  Expanded(
                    child: _buildUserList(),
                  ),
                ],
              ),
            ),

            // Loading Overlay
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

  /// BUILD STATS ROW
  Widget _buildStatsRow() {
    final adminCount = _users.where((u) => u['role'] == 'admin').length;
    final regularCount = _users.where((u) => u['role'] != 'admin').length;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Users',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_users.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Admins',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$adminCount',
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Regular',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$regularCount',
                  style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// BUILD USER LIST
  Widget _buildUserList() {
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
              onPressed: _loadUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No users found' : 'No results for "$_searchQuery"',
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        final isAdmin = user['role'] == 'admin';

        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isAdmin ? Colors.purpleAccent : Colors.indigoAccent,
              child: Text(
                user['name'].toString()[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user['name'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isAdmin)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(color: Colors.purpleAccent, fontSize: 10),
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              user['email'],
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Make/Remove Admin Button
                IconButton(
                  onPressed: () => _toggleAdminRole(user, index),
                  icon: Icon(
                    isAdmin ? Icons.admin_panel_settings : Icons.admin_panel_settings_outlined,
                    color: isAdmin ? Colors.purpleAccent : Colors.white54,
                    size: 22,
                  ),
                  tooltip: isAdmin ? 'Remove Admin' : 'Make Admin',
                ),
                // Edit Button
                IconButton(
                  onPressed: () => _editUser(user, index),
                  icon: const Icon(Icons.edit, color: Colors.tealAccent, size: 22),
                  tooltip: 'Edit User',
                ),
                // Delete Button
                IconButton(
                  onPressed: () => _deleteUser(user, index),
                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 22),
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}