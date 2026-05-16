class AppConstants {
  static const String baseUrl = 'https://danbooru.donmai.us';
  static const String cdnUrl = 'https://cdn.donmai.us';

  static const int defaultPageLimit = 20;
  static const int maxTagsAnonymous = 2;
  static const int maxTagsMember = 4;
  static const int maxTagsGold = 6;

  static const int thumbnailSize = 180;
  static const int cacheMaxSize = 500 * 1024 * 1024;

  static const Duration cacheDuration = Duration(minutes: 5);
  static const Duration tagCacheDuration = Duration(days: 7);

  static const int maxPerSecond = 8;
  static const Duration rateLimitDelay = Duration(milliseconds: 200);
}

enum Rating {
  general('g'),
  sensitive('s'),
  questionable('q'),
  explicit('e');

  final String value;
  const Rating(this.value);
}

enum MediaType {
  image,
  gif,
  video,
  unknown,
}

MediaType detectMediaType(String? fileExt) {
  if (fileExt == null) return MediaType.unknown;
  switch (fileExt.toLowerCase()) {
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'webp':
      return MediaType.image;
    case 'gif':
      return MediaType.gif;
    case 'mp4':
    case 'webm':
      return MediaType.video;
    default:
      return MediaType.unknown;
  }
}

String buildThumbnailUrl(String? md5Hash) {
  if (md5Hash == null || md5Hash.isEmpty) return '';
  return '${AppConstants.cdnUrl}/${AppConstants.thumbnailSize}x${AppConstants.thumbnailSize}/${md5Hash.substring(0, 2)}/${md5Hash.substring(2, 4)}/$md5Hash.jpg';
}

String buildSampleUrl(String? md5Hash, String? ext) {
  if (md5Hash == null || md5Hash.isEmpty) return '';
  final filename = ext != null ? '${md5Hash}_sample' : md5Hash;
  return '${AppConstants.cdnUrl}/sample/${md5Hash.substring(0, 2)}/${md5Hash.substring(2, 4)}/$filename.jpg';
}

String buildOriginalUrl(String? md5Hash, String? ext) {
  if (md5Hash == null || md5Hash.isEmpty || ext == null) return '';
  return '${AppConstants.cdnUrl}/original/${md5Hash.substring(0, 2)}/${md5Hash.substring(2, 4)}/$md5Hash.$ext';
}