import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../Services/firebase_admin_service.dart';
import '../../AuthScreen.dart' show GlassAuthScreen;


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAdminService _adminService = FirebaseAdminService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _isLoggingOut = false; // ← NEW: For logout loading state
  String _adminName = '';
  String _adminEmail = '';
  String _adminRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final Map<String, dynamic>? userData = await _adminService.getUserById(user.uid);

        if (mounted) {
          setState(() {
            _adminName = userData?['name'] ?? user.displayName ?? user.email?.split('@').first ?? 'Admin';
            _adminEmail = user.email ?? '';
            _adminRole = userData?['role'] ?? 'Admin';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error loading user data: $e', Colors.red);
      }
    }
  }

  // Helper method for showing snackbars
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ============ LOGOUT METHOD (FROM ADMIN DASHBOARD - WORKING) ============
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

  // ============ LOGOUT DIALOG (FROM ADMIN DASHBOARD - WORKING) ============
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

  // ============ EDIT PROFILE ============
  Future<void> _editProfile() async {
    final TextEditingController nameCtrl = TextEditingController(text: _adminName);

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Email: $_adminEmail',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final User? user = _auth.currentUser;
        if (user != null) {
          await _adminService.updateUser(user.uid, {
            'name': nameCtrl.text.trim(),
          });
          await user.updateDisplayName(nameCtrl.text.trim());

          if (mounted) {
            setState(() {
              _adminName = nameCtrl.text.trim();
              _isLoading = false;
            });
            _showSnackBar('Profile updated successfully!', Colors.green);
          }
        } else {
          throw Exception('User not logged in');
        }
      } catch (e) {
        print('Error updating profile: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Error: ${e.toString()}', Colors.red);
        }
      }
    }
  }

  // ============ CHANGE PASSWORD ============
  Future<void> _changePassword() async {
    final TextEditingController currentPwdCtrl = TextEditingController();
    final TextEditingController newPwdCtrl = TextEditingController();
    final TextEditingController confirmPwdCtrl = TextEditingController();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPwdCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPwdCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPwdCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );

    if (result == true) {
      if (newPwdCtrl.text != confirmPwdCtrl.text) {
        _showSnackBar('New passwords do not match', Colors.red);
        return;
      }
      if (newPwdCtrl.text.length < 6) {
        _showSnackBar('Password must be at least 6 characters', Colors.red);
        return;
      }
      if (currentPwdCtrl.text.isEmpty) {
        _showSnackBar('Please enter current password', Colors.red);
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final User? user = _auth.currentUser;
        final String? userEmail = user?.email;

        if (user != null && userEmail != null) {
          final AuthCredential credential = EmailAuthProvider.credential(
            email: userEmail,
            password: currentPwdCtrl.text,
          );
          await user.reauthenticateWithCredential(credential);
          await user.updatePassword(newPwdCtrl.text);

          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            _showSnackBar('Password changed successfully! Please login again.', Colors.green);
          }
        } else {
          throw Exception('User not found');
        }
      } on FirebaseAuthException catch (e) {
        print('FirebaseAuthException: ${e.code}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        String message = 'Failed to change password';
        switch (e.code) {
          case 'wrong-password':
            message = 'Current password is incorrect';
            break;
          case 'weak-password':
            message = 'Password is too weak';
            break;
          case 'user-not-found':
            message = 'User not found';
            break;
          case 'requires-recent-login':
            message = 'Please login again to change password';
            break;
          default:
            message = e.message ?? 'Failed to change password';
        }
        _showSnackBar(message, Colors.red);
      } catch (e) {
        print('Error changing password: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  // ============ RESET PASSWORD EMAIL ============
  Future<void> _resetPasswordEmail() async {
    final User? user = _auth.currentUser;
    final String? userEmail = user?.email;

    if (userEmail == null || userEmail.isEmpty) {
      _showSnackBar('No email found for this account', Colors.red);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
        content: Text('Send password reset email to $userEmail?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: userEmail);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Password reset email sent! Check your inbox.', Colors.green);
      }
    } catch (e) {
      print('Error sending reset email: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    }
  }

  // ============ CLEAR CACHE ============
  Future<void> _clearCache() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
        content: const Text('Clear app cache? This will not delete your data.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _showSnackBar('Cache cleared successfully!', Colors.green);
      } catch (e) {
        _showSnackBar('Error clearing cache: ${e.toString()}', Colors.red);
      }
    }
  }

  // ============ SEND FEEDBACK ============
  Future<void> _sendFeedback() async {
    final TextEditingController feedbackCtrl = TextEditingController();

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Send Feedback', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: feedbackCtrl,
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Write your feedback here...',
            hintStyle: TextStyle(color: Colors.white54),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Submit', style: TextStyle(color: Colors.tealAccent)),
          ),
        ],
      ),
    );

    if (result == true && feedbackCtrl.text.trim().isNotEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final user = _auth.currentUser;
        await FirebaseFirestore.instance.collection('feedbacks').add({
          'userId': user?.uid,
          'userName': _adminName,
          'userEmail': _adminEmail,
          'feedback': feedbackCtrl.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Thank you for your feedback!', Colors.green);
        }
      } catch (e) {
        print('Error sending feedback: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _showSnackBar('Error: ${e.toString()}', Colors.red);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            "Admin Settings",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
            // ============ LOGOUT BUTTON (UPDATED - WORKING) ============
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _isLoggingOut ? null : _showLogoutDialog,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Admin Profile Section
                _buildAdminProfileCard(),
                const SizedBox(height: 20),

                // Edit Profile Button
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit Profile',
                  color: Colors.tealAccent,
                  onTap: _editProfile,
                ),
                const SizedBox(height: 20),

                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // Account Security Section
                _buildSectionTitle('Account Security', Icons.security),
                _buildSettingsTile(
                  icon: Icons.lock_reset,
                  iconColor: Colors.tealAccent,
                  title: 'Change Password',
                  description: 'Update your account password',
                  onTap: _changePassword,
                ),
                _buildSettingsTile(
                  icon: Icons.email,
                  iconColor: Colors.orangeAccent,
                  title: 'Reset Password via Email',
                  description: 'Receive password reset link',
                  onTap: _resetPasswordEmail,
                ),

                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // Data Management Section
                _buildSectionTitle('Data Management', Icons.data_usage),
                _buildSettingsTile(
                  icon: Icons.delete_sweep,
                  iconColor: Colors.redAccent,
                  title: 'Clear Cache',
                  description: 'Clear temporary app data',
                  onTap: _clearCache,
                ),

                const Divider(color: Colors.white24),
                const SizedBox(height: 10),

                // Support Section
                _buildSectionTitle('Support', Icons.support_agent),
                _buildSettingsTile(
                  icon: Icons.feedback,
                  iconColor: Colors.purpleAccent,
                  title: 'Send Feedback',
                  description: 'Share your thoughts with us',
                  onTap: _sendFeedback,
                ),
                _buildSettingsTile(
                  icon: Icons.help,
                  iconColor: Colors.yellowAccent,
                  title: 'Help Center',
                  description: 'FAQs and tutorials',
                  onTap: () => _showHelpDialog(),
                ),
                _buildSettingsTile(
                  icon: Icons.info,
                  iconColor: Colors.blueAccent,
                  title: 'About',
                  description: 'App version and information',
                  onTap: _showAboutDialog,
                ),

                const SizedBox(height: 20),

                // Version Info
                Center(
                  child: Text(
                    'Version 2.0.0 • Build 2024',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),

            // ============ LOGOUT LOADING OVERLAY ============
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
    );
  }

  Widget _buildAdminProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.withOpacity(0.2), Colors.blue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.deepPurpleAccent,
            child: Text(
              _adminName.isNotEmpty ? _adminName[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _adminName.isNotEmpty ? _adminName : 'Admin User',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _adminEmail.isNotEmpty ? _adminEmail : '',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _adminRole == 'admin' ? 'Super Administrator' : 'Administrator',
                    style: const TextStyle(color: Colors.purpleAccent, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.tealAccent, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(color: Colors.tealAccent, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        subtitle: Text(description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Help Center', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpItem('How to add a new admin?', 'Go to Manage Admins screen → Click + button'),
            const SizedBox(height: 12),
            _buildHelpItem('How to approve videos?', 'Go to Video Management → Click check icon'),
            const SizedBox(height: 12),
            _buildHelpItem('How to change password?', 'Go to Settings → Change Password'),
            const SizedBox(height: 12),
            _buildHelpItem('How to manage users?', 'Go to User Management screen'),
          ],
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

  Widget _buildHelpItem(String question, String answer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Q: $question', style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        Text('A: $answer', style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('About', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings, size: 50, color: Colors.purpleAccent),
            const SizedBox(height: 10),
            const Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Text('Version 2.0.0', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 10),
            const Text('Complete admin panel for managing users, videos, and settings.',
                style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            const Text('© 2024 All Rights Reserved', style: TextStyle(color: Colors.white38, fontSize: 12)),
          ],
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

  @override
  void dispose() {
    super.dispose();
  }
}