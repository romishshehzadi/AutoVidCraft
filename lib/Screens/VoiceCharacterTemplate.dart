// lib/screens/voice_character_template.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:auto/Screens/VideoGenerate.dart';
import 'package:auto/Screens/filter.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class VoiceCharacterTemplate extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onBack;
  final Function(Map<String, dynamic> selection)? onContinue;

  const VoiceCharacterTemplate({
    super.key,
    required this.imagePath,
    this.onBack,
    this.onContinue,
  });

  @override
  State<VoiceCharacterTemplate> createState() => _VoiceCharacterTemplateState();
}

class _VoiceCharacterTemplateState extends State<VoiceCharacterTemplate> {
  Map<String, dynamic>? selectedVoice;
  Map<String, dynamic>? selectedTemplate;
  Map<String, dynamic>? selectedCharacter;

  bool loadingImageError = false;

  @override
  void initState() {
    super.initState();
    if (widget.imagePath.isEmpty) loadingImageError = true;
  }

  void _openVoiceModal() async {
    final res = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _VoiceRecorderSheet(),
    );
    if (res != null) setState(() => selectedVoice = res);
  }

  void _openTemplateModal() async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _TemplateDialog(),
    );
    if (res != null) setState(() => selectedTemplate = res);
  }

  void _openCharacterModal() async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _CharacterDialog(),
    );
    if (res != null) setState(() => selectedCharacter = res);
  }

  void _handleContinue() {
    final result = {
      'voice': selectedVoice,
      'template': selectedTemplate,
      'character': selectedCharacter,
    };
    if (widget.onContinue != null) widget.onContinue!(result);
    Navigator.of(context).pop(result);
  }

  // ✅ Updated navigation method with all data
  void _navigateToFilterScreen() {
    // Check if at least one option is selected
    if (selectedVoice == null && selectedTemplate == null && selectedCharacter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one option (Voice, Template, or Character)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Debug print to verify data
    print("📤 Navigating to Filter Screen with:");
    print("   - Voice: $selectedVoice");
    print("   - Template: $selectedTemplate");
    print("   - Character: $selectedCharacter");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVideoFiltersMobile(
          imageUrl: widget.imagePath,
          transcribedText: selectedVoice?['text'],
          voiceLanguage: selectedVoice?['language'],
          // ✅ Passing all selected data
          selectedVoice: selectedVoice,
          selectedTemplate: selectedTemplate,
          selectedCharacter: selectedCharacter,
          onNext: (filter) {
            print("✅ Selected filter: $filter");
            Navigator.pop(context);
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF0B1020),
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
          title: const Text(
            "Preview & Options",
            style: TextStyle(color: Colors.white, fontFamily: 'font6'),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Card
                _glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Your Image",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            ),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _buildImage(widget.imagePath),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Display transcribed text if available
                      if (selectedVoice != null && selectedVoice!['text'] != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.translate, size: 16, color: Colors.blue.shade200),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Transcribed Text (${selectedVoice!['language'] == 'ur_PK' ? 'اردو' : 'English'})",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                selectedVoice!['text'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                textAlign: selectedVoice!['language'] == 'ur_PK'
                                    ? TextAlign.right
                                    : TextAlign.left,
                                textDirection: selectedVoice!['language'] == 'ur_PK'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (selectedVoice != null)
                            _selectedBadge(
                              icon: Icons.mic,
                              label: "Voice • ${selectedVoice!['duration']}s • ${selectedVoice!['language'] == 'ur_PK' ? 'اردو' : 'EN'}",
                            ),
                          if (selectedTemplate != null)
                            _selectedBadge(
                              icon: Icons.auto_awesome,
                              label: selectedTemplate!['name'],
                            ),
                          if (selectedCharacter != null)
                            _selectedBadge(
                              icon: Icons.person,
                              label: selectedCharacter!['name'],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Options Grid
                Row(
                  children: [
                    Expanded(
                      child: _optionActionCard(
                        icon: Icons.mic,
                        title: "Voice",
                        subtitle: selectedVoice == null
                            ? "Add voice"
                            : (selectedVoice!['text'] != null && selectedVoice!['text'].toString().length > 20)
                            ? "${selectedVoice!['text'].toString().substring(0, 20)}..."
                            : (selectedVoice!['text'] ?? "Voice recorded"),
                        onTap: _openVoiceModal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _optionActionCard(
                        icon: Icons.auto_awesome,
                        title: "Template",
                        subtitle: selectedTemplate == null
                            ? "Pick style"
                            : selectedTemplate!['name'],
                        onTap: _openTemplateModal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _optionActionCard(
                        icon: Icons.person,
                        title: "Character",
                        subtitle: selectedCharacter == null
                            ? "Choose avatar"
                            : selectedCharacter!['name'],
                        onTap: _openCharacterModal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Templates horizontal
                const Text(
                  "Templates",
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'font6'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sampleTemplates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final t = _sampleTemplates[index];
                      final active = selectedTemplate != null && selectedTemplate!['id'] == t['id'];
                      return GestureDetector(
                        onTap: () => setState(() => selectedTemplate = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 160,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: active
                                ? const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            )
                                : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.03),
                                Colors.white.withOpacity(0.01),
                              ],
                            ),
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['name'],
                                style: TextStyle(
                                  color: active ? Colors.white : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Text(
                                  t['desc'],
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white.withOpacity(0.95)
                                        : Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  active
                                      ? Icons.check_circle
                                      : Icons.play_circle_fill_outlined,
                                  color: active ? Colors.white : Colors.white60,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Characters horizontal
                const Text(
                  "Characters",
                  style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      fontFamily: 'font6'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 96,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sampleCharacters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final c = _sampleCharacters[index];
                      final active = selectedCharacter != null && selectedCharacter!['name'] == c['name'];
                      return GestureDetector(
                        onTap: () => setState(() => selectedCharacter = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: 92,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: active
                                ? const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF8B5CF6),
                              ],
                            )
                                : LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.03),
                                Colors.white.withOpacity(0.01),
                              ],
                            ),
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                c['emoji'],
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c['name'],
                                style: TextStyle(
                                  color: active ? Colors.white : Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),

                // ✅ Updated Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Back",
                          style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                        ),
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          // ✅ Using updated navigation method
                          onPressed: _navigateToFilterScreen,
                          child: const Text(
                            "Continue",
                            style: TextStyle(color: Colors.white, fontFamily: 'font6'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ✅ Show message if nothing selected
                if (selectedVoice == null && selectedTemplate == null && selectedCharacter == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      "Please select Voice, Template, or Character to continue",
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.03),
            Colors.white.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: child,
    );
  }

  Widget _optionActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Color(0xFF5EE7DF), Color(0xFFB49CFF)],
                ),
              ),
              child: Icon(icon, color: Colors.black87, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _selectedBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade200),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------------------- Sample Data -----------------
final List<Map<String, dynamic>> _sampleTemplates = [
  {'id': '1','name': 'Energetic Vlog','desc': 'Upbeat and lively tone, perfect for vlogs and social content.'},
  {'id': '2','name': 'Dramatic Movie','desc': 'Deep, cinematic voice with emotional emphasis.'},
  {'id': '3','name': 'Calm Narration','desc': 'Smooth and relaxing tone, ideal for storytelling.'},
  {'id': '4','name': 'Funny Cartoon','desc': 'High-pitched and playful, great for animated clips.'},
  {'id': '5','name': 'AI Robot','desc': 'Mechanical and robotic voice effect, futuristic vibe.'},
  {'id': '6','name': 'Fantasy Epic','desc': 'Majestic and heroic tone, for fantasy adventures.'},
  {'id': '7','name': 'Whisper ASMR','desc': 'Soft, whispering tone for relaxing or ASMR content.'},
  {'id': '8','name': 'Social Media Trend','desc': 'Catchy and viral style, fits current social media trends.'},
  {'id': '9','name': 'Excited Gamer','desc': 'Energetic gamer vibe with excitement and hype.'},
  {'id': '10','name': 'Mysterious Storyteller','desc': 'Slow, suspenseful, perfect for mystery or thriller narration.'},
];

final List<Map<String, dynamic>> _sampleCharacters = [
  {'name': 'TikTok Star', 'emoji': '🧑‍🎤'},
  {'name': 'Gamer', 'emoji': '🕹️'},
  {'name': 'Vlogger', 'emoji': '🎥'},
  {'name': 'Influencer', 'emoji': '💄'},
  {'name': 'Young ', 'emoji': '🧑‍🔬'},
  {'name': 'Doggo', 'emoji': '🐶'},
  {'name': 'Kitty', 'emoji': '🐱'},
  {'name': 'Panda', 'emoji': '🐼'},
  {'name': 'Fox', 'emoji': '🦊'},
  {'name': 'Hamster', 'emoji': '🐹'},
  {'name': 'Parrot', 'emoji': '🦜'},
  {'name': 'Owl', 'emoji': '🦉'},
  {'name': 'Penguin', 'emoji': '🐧'},
  {'name': 'Swan', 'emoji': '🦢'},
  {'name': 'Eagle', 'emoji': '🦅'},
  {'name': 'SpongeBob', 'emoji': '🍍'},
  {'name': 'Mickey', 'emoji': '🐭'},
  {'name': 'Doraemon', 'emoji': '🤖'},
  {'name': 'Minion', 'emoji': '🟡'},
  {'name': 'Pikachu', 'emoji': '⚡'},
  {'name': 'Robot', 'emoji': '🤖'},
  {'name': 'Alien', 'emoji': '👽'},
  {'name': 'Wizard', 'emoji': '🧙‍♂️'},
  {'name': 'Dragon', 'emoji': '🐉'},
  {'name': 'Unicorn', 'emoji': '🦄'},
];

// ---------------------- Voice Recorder Bottom Sheet with Speech to Text -----------------
class _VoiceRecorderSheet extends StatefulWidget {
  const _VoiceRecorderSheet({super.key});

  @override
  State<_VoiceRecorderSheet> createState() => _VoiceRecorderSheetState();
}

class _VoiceRecorderSheetState extends State<_VoiceRecorderSheet>
    with SingleTickerProviderStateMixin {
  bool recording = false;
  bool recorded = false;
  bool isListening = false;
  int seconds = 0;
  Timer? _timer;
  List<double> waveHeights = List.generate(20, (_) => 4.0);
  final Random random = Random();

  // Speech to text
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;
  String _transcribedText = '';
  String _detectedLanguage = 'en_US';
  String _displayLanguage = 'English';
  double _confidence = 0.0;

  late AnimationController _waveController;

  // List of supported locales
  final List<stt.LocaleName> _locales = [];
  String _currentLocaleId = 'en_US';

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..repeat(reverse: true);

    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onError: (error) => _onSpeechError(error),
      onStatus: (status) => _onSpeechStatus(status),
    );

    if (_speechEnabled) {
      final locales = await _speech.locales();
      setState(() {
        _locales.clear();
        _locales.addAll(locales);

        final hasUrdu = locales.any((locale) => locale.localeId.contains('ur'));
        final hasEnglish = locales.any((locale) => locale.localeId.contains('en'));

        if (hasUrdu) {
          _currentLocaleId = 'ur_PK';
          _detectedLanguage = 'ur_PK';
          _displayLanguage = 'اردو';
        } else if (hasEnglish) {
          _currentLocaleId = 'en_US';
          _detectedLanguage = 'en_US';
          _displayLanguage = 'English';
        }
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    print('Speech error: $error');
    setState(() {
      isListening = false;
    });
  }

  void _onSpeechStatus(String? status) {
    print('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      setState(() {
        isListening = false;
      });
      if (recording) {
        _stopRecording();
      }
    }
  }

  void _startListening() async {
    if (!_speechEnabled) {
      print('Speech not available');
      return;
    }

    setState(() {
      isListening = true;
      _transcribedText = '';
      _confidence = 0.0;
    });

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcribedText = result.recognizedWords;
          _confidence = result.confidence;

          final hasUrduChars = result.recognizedWords.runes.any((rune) =>
          rune >= 0x0600 && rune <= 0x06FF);

          if (hasUrduChars) {
            _detectedLanguage = 'ur_PK';
            _displayLanguage = 'اردو';
          } else {
            _detectedLanguage = 'en_US';
            _displayLanguage = 'English';
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: _currentLocaleId,
      cancelOnError: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      isListening = false;
    });
  }

  void _startRecording() {
    setState(() {
      recording = true;
    });

    _startListening();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        seconds++;
        waveHeights = List.generate(20, (_) => random.nextDouble() * 20 + 4);
      });
    });
  }

  void _stopRecording({bool send = false}) {
    _timer?.cancel();
    _stopListening();

    setState(() {
      recording = false;
      if (!send) recorded = true;
    });

    if (send && _transcribedText.isNotEmpty) {
      Navigator.of(context).pop({
        'file': 'voice.mp3',
        'duration': seconds,
        'text': _transcribedText,
        'language': _detectedLanguage,
        'displayLanguage': _displayLanguage,
        'confidence': _confidence,
      });
    }
  }

  void _resetRecording() {
    setState(() {
      _transcribedText = '';
      seconds = 0;
      recorded = false;
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _timer?.cancel();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 14),

              // Language indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.translate, size: 18, color: Colors.blue.shade300),
                        const SizedBox(width: 8),
                        Text(
                          _displayLanguage,
                          style: TextStyle(
                            color: Colors.blue.shade300,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status text
              Text(
                recording
                    ? "Recording... $seconds s"
                    : recorded
                    ? "Recorded: $seconds s"
                    : "Hold the mic to start recording\n($_displayLanguage)",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 24),

              // Mic button
              GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: () => _stopRecording(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: recording
                          ? [Colors.red, Colors.orange]
                          : [const Color(0xFF5EE7DF), const Color(0xFFB49CFF)],
                    ),
                  ),
                  child: Icon(
                      recording ? Icons.stop : Icons.mic,
                      color: Colors.black87,
                      size: 40),
                ),
              ),

              const SizedBox(height: 24),

              // Wave animation while recording
              if (recording)
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: waveHeights
                        .map((h) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 5,
                        height: h,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),

              const SizedBox(height: 20),

              // Transcribed text display
              if (_transcribedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.translate, size: 14, color: Colors.blue.shade300),
                                const SizedBox(width: 6),
                                Text(
                                  _displayLanguage,
                                  style: TextStyle(
                                    color: Colors.blue.shade300,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (_confidence > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "${(_confidence * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _transcribedText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          textAlign: _detectedLanguage == 'ur_PK'
                              ? TextAlign.right
                              : TextAlign.left,
                          textDirection: _detectedLanguage == 'ur_PK'
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _stopListening();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Cancel", style: TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(width: 12),

                  if (recorded && _transcribedText.isNotEmpty)
                    TextButton(
                      onPressed: _resetRecording,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Reset", style: TextStyle(fontSize: 16)),
                    ),

                  const SizedBox(width: 12),

                  ElevatedButton(
                    onPressed: (recorded || _transcribedText.isNotEmpty)
                        ? () => _stopRecording(send: true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Send", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: const Color(0xFF0A0E1A),
      title: const Text(
        "Choose Template",
        style: TextStyle(color: Colors.white, fontFamily: 'font6'),
      ),
      children: _sampleTemplates
          .map(
            (t) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(t),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t['name'],
                style: const TextStyle(color: Colors.white),
              ),
              Icon(Icons.check, color: Colors.white24),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}

// ---------------------- Character Dialog -----------------
class _CharacterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: const Color(0xFF0A0E1A),
      title: const Text(
        "Choose Character",
        style: TextStyle(color: Colors.white, fontFamily: 'font6'),
      ),
      children: _sampleCharacters
          .map(
            (c) => SimpleDialogOption(
          onPressed: () => Navigator.of(context).pop(c),
          child: Row(
            children: [
              Text(c['emoji'], style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text(
                c['name'],
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}