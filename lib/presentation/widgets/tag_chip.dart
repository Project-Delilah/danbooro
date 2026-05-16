import 'package:flutter/material.dart';
import '../../data/models/tag.dart';

class TagChip extends StatelessWidget {
  final String tagName;
  final TagCategory? category;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TagChip({
    super.key,
    required this.tagName,
    this.category,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tagName,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _getColor() {
    if (category != null) {
      switch (category!) {
        case TagCategory.artist:
          return Colors.red;
        case TagCategory.copyright:
          return Colors.purple;
        case TagCategory.character:
          return Colors.green;
        case TagCategory.meta:
          return Colors.teal;
        case TagCategory.general:
          return Colors.blue;
      }
    }

    if (tagName.startsWith('artist:')) return Colors.red;
    if (tagName.contains('copyright') || tagName.contains('_(series)')) return Colors.purple;
    if (tagName.contains('character') || tagName.contains('_(character)')) return Colors.green;
    if (tagName.startsWith('meta:')) return Colors.teal;
    return Colors.blue;
  }
}