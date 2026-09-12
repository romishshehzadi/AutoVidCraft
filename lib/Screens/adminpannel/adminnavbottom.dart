
import 'package:auto/Screens/adminpannel/Server%20%20System%20Monitoring%20Screen.dart';
import 'package:auto/Screens/adminpannel/adminsetting/Settings.dart';
import 'package:auto/Screens/adminpannel/admindashboard.dart';
// import 'package:auto/Screens/adminpannel/notification.dart';
import 'package:flutter/material.dart';

import 'Video Management Screen.dart' show VideoManagementScreen;
import 'user management.dart' show UserManagementScreen;



class BottomNavAdmin extends StatefulWidget {
  const BottomNavAdmin({super.key});

  @override
  _BottomNavAdminState createState() => _BottomNavAdminState();
}

class _BottomNavAdminState extends State<BottomNavAdmin> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    AdminDashboardScreen(),
    // NotificationsScreen(),

    ServerMonitoringScreen(),
    SettingsScreen(),
    UserManagementScreen(),
    VideoManagementScreen(),

  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration:  BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6366F1), // Purple start
              Color(0xFF8B5CF6), // Purple end
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ClipRRect(
          borderRadius:  BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTap,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            items:  [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.white), label: "Home"),
              // BottomNavigationBarItem(
              //     icon: Icon(Icons.notification_add_outlined, color: Colors.white),
              //     label: "Notication"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.severe_cold_outlined, color: Colors.white),
                  label: "Server"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: Colors.white),
                  label: "setting"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.white),
                  label: "User"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.video_library, color: Colors.white),
                  label: "Video"),


            ],
          ),
        ),
      ),
    );
  }
}
