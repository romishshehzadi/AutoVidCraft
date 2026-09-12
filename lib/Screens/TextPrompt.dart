import 'dart:io';
import 'package:auto/Screens/filter.dart' show CreateVideoFiltersMobile;
import 'package:flutter/material.dart';
import 'package:auto/services/video_prompt_service.dart';

class CreateVideoPromptMobile extends StatefulWidget {
  final VoidCallback onBack;
  final File imageFile;

  const CreateVideoPromptMobile({
    super.key,
    required this.onBack,
    required this.imageFile,
  });

  @override
  State<CreateVideoPromptMobile> createState() => _CreateVideoPromptMobileState();
}

class _CreateVideoPromptMobileState extends State<CreateVideoPromptMobile> {
  String prompt = '';
  final int maxChars = 500;
  late final TextEditingController _controller;

  final List<String> promptSuggestions = [
    "Add dramatic cinematic motion with slow zoom",
    "Create a dreamy, ethereal atmosphere with particle effects",
    "Generate smooth camera pan across the scene",
    "Add realistic wind and movement to natural elements",
    "Create time-lapse style acceleration effect",
    "Add ambient lighting changes from day to night",
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handleSuggestionClick(String suggestion) {
    setState(() {
      prompt = suggestion;
      _controller.text = suggestion;
    });
  }

  // ✅ UPDATED: Pass prompt to filter screen with ALL required parameters
  void handleContinue() async {
    if (prompt.trim().isNotEmpty) {
      try {
        // Save to Firebase
        await VideoPromptService.saveVideoPrompt(
          textPrompt: prompt.trim(),
          imageUrl: widget.imageFile.path,
        );

        print("✅ Saved to Firebase successfully!");
        print("📝 Prompt: ${prompt.trim()}");

        // ✅ Navigate to filter screen WITH ALL required parameters
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateVideoFiltersMobile(
              imageUrl: widget.imageFile.path,
              prompt: prompt.trim(), // ← PROMPT PASSED HERE
              onBack: () => Navigator.pop(context),
              onNext: (filter) {  // ← REQUIRED onNext PARAMETER - FIXED!
                print("✅ Filter selected: $filter");
                // Optional: Do something with selected filter
              },
              // Optional parameters (can be null for manual prompt flow)
              transcribedText: null,
              voiceLanguage: null,
              selectedVoice: null,
              selectedTemplate: null,
              selectedCharacter: null,
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save prompt: $e")),
        );
      }
    }
  }

  Widget _buildImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.white12,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.broken_image, size: 36, color: Colors.white38),
                SizedBox(height: 8),
                Text("Image not found", style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        },
      );
    } else {
      final file = File(path);
      if (!file.existsSync()) {
        return Container(
          color: Colors.white12,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.broken_image, size: 36, color: Colors.white38),
              SizedBox(height: 8),
              Text("Image not found", style: TextStyle(color: Colors.white54)),
            ],
          ),
        );
      }
      return Image.file(file, fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          "Describe Your Vision",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontFamily: 'font4',
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                "Tell our AI how you want your video to look and feel",
                style: TextStyle(color: Colors.white60, fontSize: 14, fontFamily: 'font4'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 200,
                  child: _buildImage(widget.imageFile.path),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLength: maxChars,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Describe motion, effects, and atmosphere...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white10,
                ),
                onChanged: (value) => setState(() => prompt = value),
              ),
              const SizedBox(height: 12),
              Column(
                children: promptSuggestions.map((s) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: OutlinedButton(
                      onPressed: () => handleSuggestionClick(s),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onBack,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: prompt.trim().isEmpty ? null : handleContinue,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: prompt.trim().isEmpty
                              ? null
                              : const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          color: prompt.trim().isEmpty ? Colors.grey : null,
                        ),
                        child: const Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}