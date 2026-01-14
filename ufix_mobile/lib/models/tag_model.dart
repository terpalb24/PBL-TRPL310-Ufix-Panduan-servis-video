// lib/models/tag.dart
class Tag {
  final int idTag;
  final String tag;
  final int? pembuat;

  Tag({
    required this.idTag,
    required this.tag,
    this.pembuat,
  });

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      idTag: map['idTag'] as int,
      tag: map['tag'] as String,
      pembuat: map['pembuat'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTag': idTag,
      'tag': tag,
      'pembuat': pembuat,
    };
  }

  @override
  String toString() {
    return tag;
  }
}