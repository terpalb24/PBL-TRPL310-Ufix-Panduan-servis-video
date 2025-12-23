// In your video_model.dart, add deskripsi field:
class Video {
  final int idVideo;
  final String title;
  final String videoPath;
  final String thumbnailPath;
  final String mimeType;
  final DateTime? sentDate;
  final String deskripsi; // Add this

  Video({
    required this.idVideo,
    required this.title,
    required this.videoPath,
    required this.thumbnailPath,
    required this.mimeType,
    this.sentDate,
    required this.deskripsi, // Add this
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      idVideo: json['idVideo'] ?? json['id'] ?? 0,
      title: json['title'] ?? '',
      videoPath: json['videoPath'] ?? '',
      thumbnailPath: json['thumbnailPath'] ?? '',
      mimeType: json['mime_type'] ?? json['mimeType'] ?? 'video/mp4',
      sentDate: json['sentDate'] != null 
          ? DateTime.parse(json['sentDate'].toString()) 
          : null,
      deskripsi: json['deskripsi'] ?? '', // Add this
    );
  }
}