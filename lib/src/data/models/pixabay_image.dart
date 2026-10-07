import 'package:flutter/foundation.dart';

/// Immutable model of one Pixabay image hit.
///
/// See https://pixabay.com/api/docs/ for the response schema.
@immutable
class PixabayImage {
  const PixabayImage({
    required this.id,
    required this.pageUrl,
    required this.tags,
    required this.previewUrl,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.imageWidth,
    required this.imageHeight,
    required this.views,
    required this.downloads,
    required this.likes,
    required this.comments,
    required this.user,
    required this.userImageUrl,
  });

  final int id;
  final String pageUrl;
  final String tags;
  final String previewUrl;
  final String webformatUrl;
  final String largeImageUrl;
  final int imageWidth;
  final int imageHeight;
  final int views;
  final int downloads;
  final int likes;
  final int comments;
  final String user;
  final String userImageUrl;

  /// Aspect ratio used by the masonry grid; guards against division by zero.
  double get aspectRatio =>
      imageHeight == 0 ? 1 : imageWidth / imageHeight;

  List<String> get tagList => tags
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  /// Pixabay does not ship editorial descriptions, so we derive a readable
  /// one from the photographer and tags (documented in the README).
  String get description {
    final subject = tagList.isEmpty ? 'image' : tagList.join(', ');
    return 'A free-to-use image of $subject, contributed by $user '
        'on Pixabay ($imageWidth × $imageHeight px).';
  }

  factory PixabayImage.fromJson(Map<String, dynamic> json) {
    return PixabayImage(
      id: json['id'] as int,
      pageUrl: json['pageURL'] as String? ?? '',
      tags: json['tags'] as String? ?? '',
      previewUrl: json['previewURL'] as String? ?? '',
      webformatUrl: json['webformatURL'] as String? ?? '',
      largeImageUrl: (json['largeImageURL'] as String?) ??
          (json['webformatURL'] as String? ?? ''),
      imageWidth: json['imageWidth'] as int? ?? 0,
      imageHeight: json['imageHeight'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      user: json['user'] as String? ?? 'Unknown',
      userImageUrl: json['userImageURL'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageURL': pageUrl,
        'tags': tags,
        'previewURL': previewUrl,
        'webformatURL': webformatUrl,
        'largeImageURL': largeImageUrl,
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'views': views,
        'downloads': downloads,
        'likes': likes,
        'comments': comments,
        'user': user,
        'userImageURL': userImageUrl,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PixabayImage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// One page of results plus the total number of accessible hits.
@immutable
class ImagePage {
  const ImagePage({required this.images, required this.totalHits});

  final List<PixabayImage> images;
  final int totalHits;

  factory ImagePage.fromJson(Map<String, dynamic> json) {
    final hits = (json['hits'] as List<dynamic>? ?? [])
        .map((h) => PixabayImage.fromJson(h as Map<String, dynamic>))
        .toList();
    return ImagePage(
      images: hits,
      totalHits: json['totalHits'] as int? ?? hits.length,
    );
  }
}
