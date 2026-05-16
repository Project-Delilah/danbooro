import '../../core/constants/app_constants.dart';

class Post {
  final int id;
  final String tags;
  final String rating;
  final String flags;
  final int score;
  final int uploaderId;
  final String? fileUrl;
  final String? largeFileUrl;
  final String? previewFileUrl;
  final String fileExt;
  final int imageWidth;
  final int imageHeight;
  final bool hasChildren;
  final bool hasParent;
  final int? parentId;
  final String? source;
  final DateTime createdAt;
  final String? md5;

  final List<String> artistTags;
  final List<String> characterTags;
  final List<String> copyrightTags;
  final List<String> generalTags;
  final List<String> metaTags;

  Post({
    required this.id,
    required this.tags,
    required this.rating,
    required this.flags,
    required this.score,
    required this.uploaderId,
    this.fileUrl,
    this.largeFileUrl,
    this.previewFileUrl,
    required this.fileExt,
    required this.imageWidth,
    required this.imageHeight,
    this.hasChildren = false,
    this.hasParent = false,
    this.parentId,
    this.source,
    required this.createdAt,
    this.md5,
    this.artistTags = const [],
    this.characterTags = const [],
    this.copyrightTags = const [],
    this.generalTags = const [],
    this.metaTags = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final allTags = (json['tag_string'] as String?)?.split(' ') ?? [];
    final artistTags = <String>[];
    final characterTags = <String>[];
    final copyrightTags = <String>[];
    final generalTags = <String>[];
    final metaTags = <String>[];

    for (final tag in allTags) {
      if (tag.isEmpty) continue;
      final tagData = json['tag_string_$tag'] as String? ?? '';
      if (tagData.contains('artist')) {
        artistTags.add(tag);
      } else if (tagData.contains('character')) {
        characterTags.add(tag);
      } else if (tagData.contains('copyright')) {
        copyrightTags.add(tag);
      } else if (tagData.contains('meta')) {
        metaTags.add(tag);
      } else {
        generalTags.add(tag);
      }
    }

    final md5Hash = json['md5'] as String?;
    final fileExt = (json['file_ext'] as String?) ?? '';

    return Post(
      id: json['id'] as int,
      tags: json['tag_string'] as String? ?? '',
      rating: json['rating'] as String? ?? 's',
      flags: json['flags'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      uploaderId: json['uploader_id'] as int? ?? 0,
      fileUrl: json['file_url'] as String?,
      largeFileUrl: json['large_file_url'] as String?,
      previewFileUrl: json['preview_file_url'] as String?,
      fileExt: fileExt,
      imageWidth: json['image_width'] as int? ?? 0,
      imageHeight: json['image_height'] as int? ?? 0,
      hasChildren: json['has_children'] as bool? ?? false,
      hasParent: json['has_parent'] as bool? ?? false,
      parentId: json['parent_id'] as int?,
      source: json['source'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      md5: md5Hash,
      artistTags: artistTags,
      characterTags: characterTags,
      copyrightTags: copyrightTags,
      generalTags: generalTags,
      metaTags: metaTags,
    );
  }

  Rating get ratingEnum {
    switch (rating) {
      case 'g':
        return Rating.general;
      case 's':
        return Rating.sensitive;
      case 'q':
        return Rating.questionable;
      case 'e':
        return Rating.explicit;
      default:
        return Rating.sensitive;
    }
  }

  MediaType get mediaType => detectMediaType(fileExt);

  String get thumbnailUrl {
    if (previewFileUrl != null && previewFileUrl!.isNotEmpty) {
      return previewFileUrl!;
    }
    return buildThumbnailUrl(md5);
  }

  String get sampleUrl {
    if (largeFileUrl != null && largeFileUrl!.isNotEmpty) {
      return largeFileUrl!;
    }
    return buildSampleUrl(md5, fileExt);
  }

  String get originalUrl {
    if (fileUrl != null && fileUrl!.isNotEmpty) {
      return fileUrl!;
    }
    return buildOriginalUrl(md5, fileExt);
  }

  double get aspectRatio {
    if (imageWidth == 0 || imageHeight == 0) return 1.0;
    return imageWidth / imageHeight;
  }

  bool get isPending => flags == 'pending';
  bool get isDeleted => flags == 'deleted';

  List<String> get allTags => [
        ...artistTags,
        ...copyrightTags,
        ...characterTags,
        ...generalTags,
        ...metaTags,
      ];
}