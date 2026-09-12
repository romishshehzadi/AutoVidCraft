import 'dart:io';
import 'package:flutter/material.dart';
import '../Screens/VideoGenerate.dart';

class CreateVideoFiltersMobile extends StatefulWidget {
  final Function(String? filter) onNext;
  final VoidCallback onBack;
  final String imageUrl;
  final String? transcribedText;      // Voice se aaya hua text
  final String? voiceLanguage;        // Voice ki language (ur_PK ya en_US)

  // ✅ New parameters to receive data from voice screen
  final Map<String, dynamic>? selectedVoice;
  final Map<String, dynamic>? selectedTemplate;
  final Map<String, dynamic>? selectedCharacter;

  // ✅ ADD PROMPT PARAMETER
  final String? prompt;  // ← PROMPT YAHAN ADD KIYA

  const CreateVideoFiltersMobile({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.imageUrl,
    this.transcribedText,
    this.voiceLanguage,
    this.selectedVoice,
    this.selectedTemplate,
    this.selectedCharacter,
    this.prompt,  // ← PROMPT PARAMETER
  });

  @override
  State<CreateVideoFiltersMobile> createState() =>
      _CreateVideoFiltersMobileState();
}

class _CreateVideoFiltersMobileState extends State<CreateVideoFiltersMobile> {
  String selectedCategory = "faces";
  String? selectedFilter;

  // ✅ Getter to get full filter details
  Map<String, dynamic>? get _selectedFilterDetails {
    if (selectedFilter == null) return null;

    final currentCategory = filterCategories.firstWhere((e) => e["id"] == selectedCategory);
    final filters = currentCategory["filters"] as List;

    try {
      return filters.firstWhere((f) => f["id"] == selectedFilter) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  final filterCategories = [
    {
      "id": "faces",
      "name": "Faces",
      "emoji": "😊",
      "description": "Optimized for portraits and people",
      "filters": [
        {"id": "portrait-enhance", "name": "Portrait Enhance", "description": "Adds depth and cinematic lighting"},
        {"id": "emotion-capture", "name": "Emotion Capture", "description": "Emphasizes facial expressions"},
        {"id": "beauty-glow", "name": "Beauty Glow", "description": "Soft, flattering skin effects"},
      ],
    },
    {
      "id": "objects",
      "name": "Objects",
      "emoji": "📦",
      "description": "Perfect for products and items",
      "filters": [
        {"id": "product-spotlight", "name": "Product Spotlight", "description": "Dynamic focus and rotation"},
        {"id": "360-view", "name": "360° View", "description": "Smooth circular camera movement"},
        {"id": "detail-zoom", "name": "Detail Zoom", "description": "Highlight intricate details"},
      ],
    },
    {
      "id": "environment",
      "name": "Environment",
      "emoji": "🌳",
      "description": "Best for landscapes and scenes",
      "filters": [
        {"id": "panorama-sweep", "name": "Panorama Sweep", "description": "Wide cinematic pan"},
        {"id": "nature-life", "name": "Nature Life", "description": "Add natural movement to elements"},
        {"id": "weather-effects", "name": "Weather Effects", "description": "Dynamic atmospheric changes"},
      ],
    },
  ];

  // ✅ Get final prompt (voice text OR manual prompt)
  String get _finalPrompt {
    // Priority: Manual prompt > Transcribed voice text
    if (widget.prompt != null && widget.prompt!.isNotEmpty) {
      return widget.prompt!;
    }
    if (widget.transcribedText != null && widget.transcribedText!.isNotEmpty) {
      return widget.transcribedText!;
    }
    return ""; // Empty if no prompt available
  }

  // ✅ Updated method to pass all data to generate screen
  void _goToGenerateScreen() {
    // Get filter details if selected
    final filterDetails = _selectedFilterDetails;
    final finalPrompt = _finalPrompt;

    // Debug print to verify all data
    print("=" * 50);
    print("📤 Navigating to Generate Screen with:");
    print("   - Image: ${widget.imageUrl}");
    print("   - PROMPT: $finalPrompt");  // ← PROMPT PRINT KIYA
    print("   - Voice: ${widget.selectedVoice}");
    print("   - Template: ${widget.selectedTemplate}");
    print("   - Character: ${widget.selectedCharacter}");
    print("   - Filter: $filterDetails");
    print("   - Transcribed Text: ${widget.transcribedText}");
    print("   - Manual Prompt: ${widget.prompt}");
    print("   - Voice Language: ${widget.voiceLanguage}");
    print("=" * 50);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVideoGenerateMobile(
          // Image data
          imageUrl: widget.imageUrl,
          imagePath: widget.imageUrl, // For API call if needed

          // ✅ PROMPT data (priority: manual prompt > voice text)
          transcribedText: finalPrompt,  // ← FINAL PROMPT YAHAN PASS HOGA
          voiceLanguage: widget.voiceLanguage,
          selectedVoice: widget.selectedVoice,

          // Template and character data
          selectedTemplate: widget.selectedTemplate,
          selectedCharacter: widget.selectedCharacter,

          // Filter data (null if skipped)
          selectedFilter: filterDetails,

          onComplete: () {
            // Call onNext with filter ID when generation is complete
            widget.onNext(selectedFilter);

            // Pop back to previous screens
            Navigator.pop(context); // Pop generate screen
            Navigator.pop(context); // Pop filter screen
          },
          onCancel: () {
            Navigator.pop(context); // Just pop generate screen
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = filterCategories.firstWhere((e) => e["id"] == selectedCategory);
    final filters = currentCategory["filters"] as List;
    final finalPrompt = _finalPrompt;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            "Choose Your Filter",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'font4'),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                "Select a filter category optimized for your content type",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 20),

              // Preview Card with Prompt Overlay
              Stack(
                children: [
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: widget.imageUrl.startsWith("http")
                          ? Image.network(widget.imageUrl, width: double.infinity, fit: BoxFit.cover)
                          : Image.file(File(widget.imageUrl), width: double.infinity, fit: BoxFit.cover),
                    ),
                  ),

                  // ✅ Show PROMPT (manual or voice) overlay
                  if (finalPrompt.isNotEmpty)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  widget.prompt != null && widget.prompt!.isNotEmpty
                                      ? Icons.edit_note
                                      : Icons.mic,
                                  size: 14,
                                  color: Colors.blue.shade200,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.prompt != null && widget.prompt!.isNotEmpty
                                      ? "Manual Prompt"
                                      : "Voice: ${widget.voiceLanguage == 'ur_PK' ? 'اردو' : 'English'}",
                                  style: TextStyle(
                                    color: Colors.blue.shade200,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              finalPrompt,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: widget.voiceLanguage == 'ur_PK'
                                  ? TextAlign.right
                                  : TextAlign.left,
                              textDirection: widget.voiceLanguage == 'ur_PK'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // ✅ Show selected options from previous screen
              if (widget.selectedTemplate != null || widget.selectedCharacter != null || widget.selectedVoice != null || finalPrompt.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selected Options",
                          style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // ✅ Show PROMPT badge
                            if (finalPrompt.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.prompt != null && widget.prompt!.isNotEmpty
                                          ? Icons.edit_note
                                          : Icons.mic,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.prompt != null && widget.prompt!.isNotEmpty
                                          ? "Manual Prompt"
                                          : "Voice: ${widget.selectedVoice?['duration'] ?? ''}s",
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.selectedVoice != null && widget.prompt == null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.mic, size: 12, color: Colors.blue),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Voice: ${widget.selectedVoice!['duration'] ?? ''}s',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.selectedTemplate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.auto_awesome, size: 12, color: Colors.purple),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.selectedTemplate!['name'] ?? 'Template',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.selectedCharacter != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.selectedCharacter!['emoji'] ?? '👤',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.selectedCharacter!['name'] ?? 'Character',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Category Selection
              const Text("Filter Category", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font6')),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: filterCategories.map((cat) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedCategory = cat["id"].toString();
                            selectedFilter = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedCategory == cat["id"] ? Colors.deepPurpleAccent : Colors.white24,
                              width: 2,
                            ),
                            color: selectedCategory == cat["id"] ? Colors.blue.withOpacity(0.1) : Colors.white10,
                          ),
                          child: Column(
                            children: [
                              Text(cat["emoji"].toString(), style: const TextStyle(fontSize: 24)),
                              const SizedBox(height: 4),
                              Text(cat["name"].toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Filters List
              const Text("Available Filters", style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'font6')),
              const SizedBox(height: 10),
              Column(
                children: filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          selectedFilter = filter["id"];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedFilter == filter["id"] ? Colors.deepPurpleAccent : Colors.white24,
                            width: 2,
                          ),
                          color: selectedFilter == filter["id"] ? Colors.blue.withOpacity(0.1) : Colors.white10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(filter["name"], style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(filter["description"], style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                ],
                              ),
                            ),
                            if (selectedFilter == filter["id"])
                              const Icon(Icons.check_circle, color: Colors.deepPurpleAccent),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _goToGenerateScreen,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Skip", style: TextStyle(color: Colors.white, fontFamily: 'font6')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: ElevatedButton(
                        onPressed: _goToGenerateScreen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text("Continue", style: TextStyle(color: Colors.white, fontFamily: 'font6')),
                      ),
                    ),
                  ),
                ],
              ),

              // ✅ Show selected filter message if any
              if (selectedFilter != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Filter selected: ${_selectedFilterDetails?['name']}",
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}