class VideoJob {
  final String jobId;
  String status;
  int progress;
  List<LogEntry> logs;
  String? caption;
  String? enhancedPrompt;
  String? error;

  VideoJob({
    required this.jobId,
    this.status = 'processing',
    this.progress = 0,
    this.logs = const [],
    this.caption,
    this.enhancedPrompt,
    this.error,
  });

  factory VideoJob.fromJson(Map<String, dynamic> json) {
    // Safe progress extraction (fix for num/int error)
    int progressValue = 0;
    if (json['progress'] != null) {
      if (json['progress'] is int) {
        progressValue = json['progress'];
      } else if (json['progress'] is double) {
        progressValue = (json['progress'] as double).toInt();
      } else if (json['progress'] is num) {
        progressValue = (json['progress'] as num).toInt();
      }
    }

    return VideoJob(
      jobId: json['job_id'] ?? '',
      status: json['status'] ?? 'processing',
      progress: progressValue,
      logs: (json['logs'] as List?)
          ?.map((log) => LogEntry.fromJson(log))
          .toList() ??
          [],
      caption: json['caption'],
      enhancedPrompt: json['enhanced'],
      error: json['error'],
    );
  }

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';
}

class LogEntry {
  final String message;
  final int progress;
  final String timestamp;

  LogEntry({
    required this.message,
    required this.progress,
    required this.timestamp,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    int progressValue = 0;
    if (json['progress'] != null) {
      if (json['progress'] is int) {
        progressValue = json['progress'];
      } else if (json['progress'] is double) {
        progressValue = (json['progress'] as double).toInt();
      } else if (json['progress'] is num) {
        progressValue = (json['progress'] as num).toInt();
      }
    }

    return LogEntry(
      message: json['message'] ?? '',
      progress: progressValue,
      timestamp: json['timestamp'] ?? '',
    );
  }
}