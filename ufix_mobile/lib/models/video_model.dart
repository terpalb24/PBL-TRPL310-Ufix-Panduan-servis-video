class Video {
  final int idVideo;
  final String title;
  final int? durationSec;
  final String videoPath;
  final String thumbnailPath;
  final DateTime? sentDate;
  final int? uploader;
  final String? mimeType;

  Video({
    required this.idVideo,
    required this.title,
    this.durationSec,
    required this.videoPath,
    required this.thumbnailPath,
    this.sentDate,
    this.uploader,
    this.mimeType,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      idVideo: json['idVideo'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      durationSec: json['durationSec'] as int?,
      videoPath: json['videoPath'] as String? ?? '',
      thumbnailPath: json['thumbnailPath'] as String? ?? '',
      sentDate: json['sentDate'] != null 
          ? DateTime.tryParse(json['sentDate']) 
          : null,
      uploader: json['uploader'] as int?,
      mimeType: json['mime_type'] as String? ?? 'video/mp4',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVideo': idVideo,
      'title': title,
      'durationSec': durationSec,
      'videoPath': videoPath,
      'thumbnailPath': thumbnailPath,
      'sentDate': sentDate?.toIso8601String(),
      'uploader': uploader,
      'mime_type': mimeType,
    };
  }

  // Copy with method for easy updates
  Video copyWith({
    int? idVideo,
    String? title,
    int? durationSec,
    String? videoPath,
    String? thumbnailPath,
    DateTime? sentDate,
    int? uploader,
    String? mimeType,
  }) {
    return Video(
      idVideo: idVideo ?? this.idVideo,
      title: title ?? this.title,
      durationSec: durationSec ?? this.durationSec,
      videoPath: videoPath ?? this.videoPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      sentDate: sentDate ?? this.sentDate,
      uploader: uploader ?? this.uploader,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  String toString() {
    return 'Video(idVideo: $idVideo, title: $title, durationSec: $durationSec, videoPath: $videoPath, thumbnailPath: $thumbnailPath, sentDate: $sentDate, uploader: $uploader, mimeType: $mimeType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Video &&
        other.idVideo == idVideo &&
        other.title == title &&
        other.durationSec == durationSec &&
        other.videoPath == videoPath &&
        other.thumbnailPath == thumbnailPath &&
        other.sentDate == sentDate &&
        other.uploader == uploader &&
        other.mimeType == mimeType;
  }

  @override
  int get hashCode {
    return Object.hash(
      idVideo,
      title,
      durationSec,
      videoPath,
      thumbnailPath,
      sentDate,
      uploader,
      mimeType,
    );
  }
}