import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../utils/constants.dart';

class ColabApiService {
  // Colab URL from constants
  late final String baseUrl;

  ColabApiService() {
    baseUrl = AppConstants.colabBaseUrl;
    print('🌐 API Base URL: $baseUrl');
  }

  // ========== 1. HEALTH CHECK ==========
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 10));

      print('✅ Health check: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Health check failed: $e');
      return false;
    }
  }

  // ========== 2. SYNC GENERATION (fast, returns base64) ==========
  Future<Map<String, dynamic>> generateVideo({
    required File imageFile,
    required String prompt,
  }) async {
    try {
      print('🎬 Generating video with prompt: $prompt');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/generate'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      request.fields['prompt'] = prompt;

      final response = await request.send().timeout(const Duration(minutes: 5));
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'video_base64': jsonResponse['video_base64'],
          'caption': jsonResponse['caption'],
          'enhanced_prompt': jsonResponse['enhanced_prompt'],
        };
      } else {
        return {'success': false, 'error': jsonResponse['detail'] ?? 'Generation failed'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== 3. ASYNC GENERATION (with progress tracking) ==========
  Future<Map<String, dynamic>> uploadAndGenerate({
    required File imageFile,
    required String prompt,
    Function(int progress, String message)? onProgress,
  }) async {
    try {
      onProgress?.call(10, 'Uploading image...');

      // Step 1: Upload image and get job_id
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
      request.fields['prompt'] = prompt;

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode != 200) {
        return {'success': false, 'error': jsonResponse['detail'] ?? 'Upload failed'};
      }

      final jobId = jsonResponse['job_id'];
      onProgress?.call(20, 'Video generation started...');

      // Step 2: Poll for status (keep checking until complete)
      String status = 'processing';
      Map<String, dynamic> jobData = {};
      int lastProgress = 20;

      while (status == 'processing') {
        await Future.delayed(const Duration(seconds: 2));

        final statusResponse = await http.get(
          Uri.parse('$baseUrl/status/$jobId'),
        );

        if (statusResponse.statusCode == 200) {
          jobData = json.decode(statusResponse.body);
          status = jobData['status'];

          // Safe progress extraction
          int currentProgress = lastProgress;
          if (jobData['progress'] != null) {
            if (jobData['progress'] is int) {
              currentProgress = jobData['progress'];
            } else if (jobData['progress'] is double) {
              currentProgress = (jobData['progress'] as double).toInt();
            } else if (jobData['progress'] is num) {
              currentProgress = (jobData['progress'] as num).toInt();
            }
          }

          if (currentProgress > lastProgress) {
            lastProgress = currentProgress;
            String message = 'Processing...';
            if (jobData['logs'] != null && jobData['logs'].isNotEmpty) {
              message = jobData['logs'].last['message'] ?? 'Processing...';
            }
            onProgress?.call(currentProgress, message);
          }

          print('📊 Progress: $currentProgress% - Status: $status');
        }
      }

      // Step 3: Download video when complete
      if (status == 'completed') {
        onProgress?.call(90, 'Downloading video...');

        final downloadResponse = await http.get(
          Uri.parse('$baseUrl/download/$jobId'),
        );

        if (downloadResponse.statusCode == 200) {
          final directory = await getTemporaryDirectory();
          final fileName = 'generated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(downloadResponse.bodyBytes);

          onProgress?.call(100, 'Complete!');

          return {
            'success': true,
            'video_file': file,
            'caption': jobData['caption'],
            'enhanced_prompt': jobData['enhanced'],
          };
        }
      }

      return {'success': false, 'error': jobData['error'] ?? 'Generation failed'};

    } catch (e) {
      print('❌ Upload error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Helper: Save base64 video to file
  Future<File> saveVideoFromBase64(String base64String) async {
    final bytes = base64.decode(base64String);
    final directory = await getTemporaryDirectory();
    final fileName = 'generated_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }
}