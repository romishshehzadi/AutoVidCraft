import 'package:flutter/material.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  List<String> admins = ["Shafay", "Admin User"];

  final TextEditingController adminCtrl = TextEditingController();

  void addAdmin() {
    if (adminCtrl.text.isEmpty) return;
    setState(() {
      admins.add(adminCtrl.text);
    });
    adminCtrl.clear();
    Navigator.pop(context);
  }

  void removeAdmin(int index) {
    setState(() {
      admins.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white,),
          title: Text("Management admin",style: TextStyle(color: Colors.white,fontSize: 20,fontWeight:FontWeight.bold,fontFamily: 'font4'),),
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.tealAccent,
          child:  Icon(Icons.add, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  backgroundColor:  Color(0xFF1E293B),
                  title:  Text("Add Admin",
                      style: TextStyle(color: Colors.white)),
                  content: TextField(
                    controller: adminCtrl,
                    style:  TextStyle(color: Colors.white),
                    decoration:  InputDecoration(
                        hintText: "Admin Name",
                        hintStyle: TextStyle(color: Colors.white54)),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child:  Text("Cancel",
                            style: TextStyle(color: Colors.redAccent))),
                    TextButton(
                        onPressed: addAdmin,
                        child:  Text("Add",
                            style: TextStyle(color: Colors.tealAccent))),
                  ],
                );
              },
            );
          },
        ),
        body: ListView.builder(
          itemCount: admins.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white10,
              child: ListTile(
                title: Text(
                  admins[index],
                  style:  TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon:  Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => removeAdmin(index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
