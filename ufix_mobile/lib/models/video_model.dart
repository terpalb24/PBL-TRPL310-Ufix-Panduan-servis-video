class Video {
  final int id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int? uploaderId;
  final String? uploaderName;
  final int? duration;
  final int? views;
  final DateTime? createdAt;

  Video({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.uploaderId,
    this.uploaderName,
    this.duration,
    this.views,
    this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? json['idVideo'],
      title: json['title'] ?? json['judul'] ?? 'Untitled',
      description: json['description'],
      videoUrl: json['videoUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnailPath'],
      uploaderId: json['uploaderId'] ?? json['uploader'],
      uploaderName: json['uploaderName'],
      duration: json['duration'],
      views: json['views'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : json['sentDate'] != null
            ? DateTime.parse(json['sentDate'])
            : null,
    );
  }
}