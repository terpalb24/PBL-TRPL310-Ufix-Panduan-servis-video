// lib/models/history_video_model.dart
import 'video_model.dart'; 

class HistoryVideo {
  final int idVideo;
  final String title;
  final String? thumbnailPath;
  final String videoPath;
  final String? mimeType;
  final DateTime watchedAt;
  final DateTime? sentDate;
  final String deskripsi;

  HistoryVideo({
    required this.idVideo,
    required this.title,
    this.thumbnailPath,
    required this.videoPath,
    this.mimeType,
    required this.watchedAt,
    this.sentDate,
    required this.deskripsi
  });

  factory HistoryVideo.fromJson(Map<String, dynamic> json) {
    return HistoryVideo(
      idVideo: json['idVideo'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      thumbnailPath: json['thumbnailPath'] as String?,
      videoPath: json['videoPath'] ?? '',
      mimeType: json['mime_type'] as String? ?? json['mimeType'] as String?,
      watchedAt: json['watchedAt'] != null 
          ? DateTime.parse(json['watchedAt'].toString()) 
          : DateTime.now(),
      sentDate: json['sentDate'] != null 
          ? DateTime.parse(json['sentDate'].toString()) 
          : null,
      deskripsi: json['deskripsi'] ?? ""
    );
  }

  // Convert HistoryVideo to Video with defaults
  Video toVideo() {
    return Video(
      idVideo: idVideo,
      title: title,
      videoPath: videoPath,
      thumbnailPath: thumbnailPath ?? '', // Default to empty string
      mimeType: mimeType ?? 'video/mp4', // Default mime type
      sentDate: sentDate,
      deskripsi: deskripsi
    );
  }

  String getThumbnailUrl() {
    if (thumbnailPath == null || thumbnailPath!.isEmpty) {
      return '';
    }
    return 'http://10.0.2.2:3000/$thumbnailPath';
  }

  String formatWatchedDate() {
    final now = DateTime.now();
    final difference = now.difference(watchedAt);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${watchedAt.day}/${watchedAt.month}/${watchedAt.year}';
  }
}