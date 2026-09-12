import 'package:flutter/material.dart';

class ChangePermissionScreen extends StatefulWidget {
  const ChangePermissionScreen({super.key});

  @override
  State<ChangePermissionScreen> createState() =>
      _ChangePermissionScreenState();
}

class _ChangePermissionScreenState extends State<ChangePermissionScreen> {
  List<Map<String, dynamic>> userRoles = [
    {"name": "Ali", "role": "User"},
    {"name": "Shafay", "role": "Admin"},
    {"name": "Rafay", "role": "User"},
  ];

  void changeRole(int index, String newRole) {
    setState(() {
      userRoles[index]["role"] = newRole;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:  Color(0xFF0F172A),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white,),
          title:  Text("Change Permission",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight:FontWeight.bold,fontFamily: 'font4'),),
          flexibleSpace: Container(
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
          ),
      
      
        ),
        body: ListView.builder(
          itemCount: userRoles.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white10,
              child: ListTile(
                title: Text(userRoles[index]["name"],
                    style:  TextStyle(color: Colors.white)),
                subtitle: Text("Role: ${userRoles[index]["role"]}",
                    style:  TextStyle(color: Colors.white70)),
                trailing: PopupMenuButton(
                  color:  Color(0xFF1E293B),
                  onSelected: (value) => changeRole(index, value),
                  itemBuilder: (context) => [
                     PopupMenuItem(
                      value: "User",
                      child:
                      Text("User", style: TextStyle(color: Colors.white)),
                    ),
                     PopupMenuItem(
                      value: "Admin",
                      child:
                      Text("Admin", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                  child:  Icon(Icons.more_vert, color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
