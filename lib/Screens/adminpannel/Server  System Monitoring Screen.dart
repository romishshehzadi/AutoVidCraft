import 'package:flutter/material.dart';

class ServerMonitoringScreen extends StatelessWidget {
  const ServerMonitoringScreen({super.key});

  final servers = const [
    {'name': 'API Server', 'cpu': 45, 'ram': 68, 'disk': 50},
    {'name': 'Database', 'cpu': 30, 'ram': 50, 'disk': 40},
    {'name': 'Storage', 'cpu': 70, 'ram': 80, 'disk': 90},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:  Color(0xFF0F172A),
        appBar: AppBar(
          automaticallyImplyLeading: false, // ← Back icon remove
          title: Text(
            "Server System admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'font4'
            ),
          ),
      
          flexibleSpace: Container(
            decoration: BoxDecoration(
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
          padding: EdgeInsets.all(16),
          itemCount: servers.length,
          itemBuilder: (context, index) {
            final server = servers[index];
            return Card(
              color: Colors.white10,
              margin:  EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding:  EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(server['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                     SizedBox(height: 8),
                    Text('CPU Usage', style:  TextStyle(color: Colors.white70)),
                    LinearProgressIndicator(
                      // value: server['cpu']! / 100,
                      color: Colors.tealAccent,
                      backgroundColor: Colors.white12,
                    ),
                    SizedBox(height: 6),
                    Text('RAM Usage', style:  TextStyle(color: Colors.white70)),
                    LinearProgressIndicator(
                      // value: server['ram']! / 100,
                      color: Colors.purpleAccent,
                      backgroundColor: Colors.white12,
                    ),
                     SizedBox(height: 6),
                    Text('Disk Usage', style:  TextStyle(color: Colors.white70)),
                    LinearProgressIndicator(
                      // value: server['disk']! / 100,
                      color: Colors.orangeAccent,
                      backgroundColor: Colors.white12,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
