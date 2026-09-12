import 'package:auto/Screens/CreateMethodSelection.dart';
import 'package:auto/Screens/History.dart';
import 'package:auto/Screens/adminpannel/admindashboard.dart';
import 'package:auto/Screens/profile.dart';
import 'package:flutter/material.dart';

import 'Dashboard.dart' show DashboardScreen;

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    DashboardScreen(
      onCreateVideo: () {
        print("Create Video Clicked");
      },
    ),
    CreateModeSelection(),
    HistoryScreen(),
    ProfileScreen(),

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
                  icon: Icon(Icons.home, color: Colors.white,), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.video_library, color: Colors.white),
                  label: "Create"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history, color: Colors.white),
                  label: "History"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.white,),
                  label: "Profile"),

             
            ],
          ),
        ),
      ),
    );
  }
}
