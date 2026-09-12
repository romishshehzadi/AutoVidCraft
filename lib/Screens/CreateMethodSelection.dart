import 'package:auto/Screens/imageUpload.dart' show CreateVideoUploadMobile;
import 'package:auto/Screens/Dashboard.dart' show DashboardScreen;
import 'package:auto/Screens/TextPrompt.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'VoiceCharacterTemplate.dart';
import 'bottom navigation.dart' show BottomNavScreen;

// -------------------- Create Mode Selection --------------------
class CreateModeSelection extends StatelessWidget {
  const CreateModeSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:  Color(0xFF0F172A),
        appBar: AppBar(
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
          title:
          Text(
            "Choose Creation Type",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'font5'
            ),
      
          ),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Select how you want to create your AI-powered video",
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontFamily: 'font6',
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
      
                ),
                 SizedBox(height: 24),
      
                Expanded(
                  child: ListView(
                    physics:  BouncingScrollPhysics(),
                    children: [
                      _buildInteractiveCard(
                          context,
                          title: "Image+multiple inputs",
                          description:
                          "Quick video generation from your image using AI with optional style filters",
                          icon: Icons.image,
                          gradient: LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          features: [
                            "Fast generation",
                            "Auto AI processing",
                            "Optional filters",
                          ],
                          buttonText: "Create",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateVideoUploadMobile(
                                  onNext: (imagePath) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VoiceCharacterTemplate(imagePath: imagePath),
                                      ),
                                    );
                                  },
                                  onBack: () => Navigator.pop(context),
                                ),
                              ),
                            );
                          }
                      ),
      
                      SizedBox(height: 20),
      
                      //  UPDATED CARD — IMAGE + PROMPT
                      _buildInteractiveCard(
                        context,
                        title: "Image + Prompt",
                        description:
                        "Advanced video creation with custom text prompts and detailed control",
                        icon: Icons.auto_awesome,
                        gradient:  LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFFF59E0B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        features:  [
                          "Custom AI prompts",
                          "Full creative control",
                          "Advanced filters",
                        ],
                        buttonText: "Create",
                        recommended: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateVideoUploadMobile(
                                onNext: (imagePath) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateVideoPromptMobile(
                                        imageFile: File(imagePath),
                                        onBack: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                onBack: () => Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
      
                SizedBox(height: 16),
                // Gradient Back to Dashboard Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF6366F1), // Purple start
                        Color(0xFF8B5CF6), // Purple end
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomNavScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding:EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:  Text(
                      "Back to Dashboard",
                      style: TextStyle(color: Colors.white,fontFamily: 'font6'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required LinearGradient gradient,
        required List<String> features,
        required String buttonText,
        required VoidCallback onTap,
        bool recommended = false,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration:  Duration(milliseconds: 150),
        child: Container(
          padding:  EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ---------- Circular Icon with Gradient ----------
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: gradient,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset:  Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 36),
                  ),
                   SizedBox(height: 16),
                  Text(
                    title,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                   SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(color: Colors.grey[200], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                   SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features
                        .map(
                          (f) => Padding(
                        padding:  EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                           Icon(Icons.check_circle,
                                size: 12, color: Colors.orangeAccent),
                             SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                f,
                                style: TextStyle(
                                    color: Colors.grey[200], fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .toList(),
                  ),
                   SizedBox(height: 16),

                  // ---------- Create Button with Gradient ----------
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      padding:  EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient:  LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (recommended)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Recommended",
                      style: TextStyle(color: Colors.white, fontSize: 10,fontFamily: 'font4'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
