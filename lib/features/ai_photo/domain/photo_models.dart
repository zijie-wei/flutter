class PhotoStyle {
  final String id;
  final String name;
  final String thumbnail;
  final String? description;

  PhotoStyle({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.description,
  });

  factory PhotoStyle.fromJson(Map<String, dynamic> json) {
    return PhotoStyle(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'thumbnail': thumbnail,
      'description': description,
    };
  }
}

class GeneratedPhoto {
  final String id;
  final String url;
  final String status;
  final DateTime createdAt;

  GeneratedPhoto({
    required this.id,
    required this.url,
    required this.status,
    required this.createdAt,
  });

  factory GeneratedPhoto.fromJson(Map<String, dynamic> json) {
    return GeneratedPhoto(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PhotoPreferences {
  final String styleId;
  final int count;
  final String? quality;
  final String? size;

  PhotoPreferences({
    required this.styleId,
    required this.count,
    this.quality,
    this.size,
  });

  factory PhotoPreferences.fromJson(Map<String, dynamic> json) {
    return PhotoPreferences(
      styleId: json['style_id'] ?? '',
      count: json['count'] ?? 3,
      quality: json['quality'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'style_id': styleId,
      'count': count,
      'quality': quality,
      'size': size,
    };
  }

  PhotoPreferences copyWith({
    String? styleId,
    int? count,
    String? quality,
    String? size,
  }) {
    return PhotoPreferences(
      styleId: styleId ?? this.styleId,
      count: count ?? this.count,
      quality: quality ?? this.quality,
      size: size ?? this.size,
    );
  }
}
