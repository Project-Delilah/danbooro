class Pool {
  final int id;
  final String name;
  final String? description;
  final int postCount;
  final bool isSeries;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<int> postIds;

  Pool({
    required this.id,
    required this.name,
    this.description,
    required this.postCount,
    this.isSeries = false,
    required this.createdAt,
    required this.updatedAt,
    this.postIds = const [],
  });

  factory Pool.fromJson(Map<String, dynamic> json) {
    return Pool(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      postCount: json['post_count'] as int? ?? 0,
      isSeries: (json['is_series'] as bool?) ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      postIds: (json['post_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}