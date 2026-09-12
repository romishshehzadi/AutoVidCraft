import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool emailNotif = true;
  bool pushNotif = false;
  bool smsNotif = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFF0F172A),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title:  Text("Notification Settings" ,style: TextStyle(color: Colors.white,fontSize: 20,fontWeight:FontWeight.bold,fontFamily: 'font4')),
      
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
        body: ListView(
          children: [
            SwitchListTile(
              title:
               Text("Email Notifications", style: TextStyle(color: Colors.white)),
              value: emailNotif,
              onChanged: (v) => setState(() => emailNotif = v),
              activeColor: Colors.indigoAccent,
            ),
            SwitchListTile(
              title:  Text("Push Notifications",
                  style: TextStyle(color: Colors.white)),
              value: pushNotif,
              onChanged: (v) => setState(() => pushNotif = v),
              activeColor: Colors.indigoAccent,
            ),
            SwitchListTile(
              title: Text("SMS Notifications",
                  style: TextStyle(color: Colors.white)),
              value: smsNotif,
              onChanged: (v) => setState(() => smsNotif = v),
              activeColor: Colors.indigoAccent,
            ),
          ],
        ),
      ),
    );
  }
}
