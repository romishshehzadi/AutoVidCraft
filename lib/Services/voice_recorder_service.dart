// import 'package:record/record.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//
// class VoiceRecorderService {
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   bool _isRecording = false;
//   String? _currentRecordingPath;
//
//   // Check permission
//   Future<bool> checkPermission() async {
//     try {
//       return await _audioRecorder.hasPermission();
//     } catch (e) {
//       print('❌ Permission error: $e');
//       return false;
//     }
//   }
//
//   // Start recording
//   Future<String?> startRecording() async {
//     try {
//       final hasPermission = await checkPermission();
//       if (!hasPermission) return null;
//
//       final Directory tempDir = await getTemporaryDirectory();
//       final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       _currentRecordingPath = '${tempDir.path}/recording_$timestamp.m4a';
//
//       await _audioRecorder.start(
//         const RecordConfig(encoder: AudioEncoder.aacLc),
//         path: _currentRecordingPath!,
//       );
//
//       _isRecording = true;
//       return _currentRecordingPath;
//     } catch (e) {
//       print('❌ Start error: $e');
//       return null;
//     }
//   }
//
//   // Stop recording
//   Future<String?> stopRecording() async {
//     try {
//       if (!_isRecording) return null;
//
//       final String? path = await _audioRecorder.stop();
//       _isRecording = false;
//       return path;
//     } catch (e) {
//       print('❌ Stop error: $e');
//       return null;
//     }
//   }
//
//   // Cancel recording
//   Future<void> cancelRecording() async {
//     if (_isRecording) {
//       await _audioRecorder.stop();
//       _isRecording = false;
//     }
//
//     if (_currentRecordingPath != null) {
//       try {
//         final File file = File(_currentRecordingPath!);
//         if (await file.exists()) await file.delete();
//       } catch (e) {
//         print('❌ Delete error: $e');
//       }
//     }
//   }
//
//   void dispose() {
//     _audioRecorder.dispose();
//   }
// }