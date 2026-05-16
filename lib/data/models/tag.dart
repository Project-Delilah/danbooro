enum TagCategory {
  general(0),
  artist(1),
  copyright(2),
  character(3),
  meta(4);

  final int value;
  const TagCategory(this.value);

  static TagCategory fromValue(int value) {
    return TagCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TagCategory.general,
    );
  }
}

class Tag {
  final int id;
  final String name;
  final int category;
  final int postCount;

  Tag({
    required this.id,
    required this.name,
    required this.category,
    required this.postCount,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      category: json['category'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
    );
  }

  TagCategory get tagCategory => TagCategory.fromValue(category);

  bool get isArtist => category == 1;
  bool get isCopyright => category == 2;
  bool get isCharacter => category == 3;
  bool get isMeta => category == 4;
  bool get isGeneral => category == 0;
}