import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/download_service.dart';
import '../../../data/models/post.dart';
import '../../../data/models/tag.dart';
import '../../providers/posts_provider.dart';
import '../../widgets/video_player_widget.dart';
import '../../widgets/tag_chip.dart';

class PostDetailScreen extends ConsumerWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsync = ref.watch(postDetailProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Post #$postId'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
          postAsync.maybeWhen(
            data: (post) => IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _handleDownload(context, post),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: postAsync.when(
        data: (post) => _PostDetailContent(post: post),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(postDetailProvider(postId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, Post post) async {
    final downloadService = DownloadService();
    final url = post.originalUrl;
    final filename = '${post.id}.${post.fileExt}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Downloading...'),
          ],
        ),
      ),
    );

    final result = await downloadService.downloadImage(url, filename);

    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null
              ? 'Saved to Downloads/$filename'
              : 'Download failed. Check permissions.'),
        ),
      );
    }
  }
}

class _PostDetailContent extends StatefulWidget {
  final Post post;

  const _PostDetailContent({required this.post});

  @override
  State<_PostDetailContent> createState() => _PostDetailContentState();
}

class _PostDetailContentState extends State<_PostDetailContent> {
  bool _showTags = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _buildMediaSection(),
        ),
        _buildInfoSection(),
        if (_showTags) _buildTagsSection(),
      ],
    );
  }

  Widget _buildMediaSection() {
    switch (widget.post.mediaType) {
      case MediaType.video:
        return VideoPlayerWidget(videoUrl: widget.post.originalUrl);
      case MediaType.gif:
      case MediaType.image:
        return PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.post.originalUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          backgroundDecoration: const BoxDecoration(color: Colors.black),
        );
      case MediaType.unknown:
        return const Center(child: Text('Unknown media type'));
    }
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('${widget.post.score}'),
              const SizedBox(width: 16),
              if (widget.post.hasParent)
                const Icon(Icons.arrow_upward, size: 18)
              else if (widget.post.hasChildren)
                const Icon(Icons.arrow_downward, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showTags = !_showTags),
                icon: const Icon(Icons.tag),
                label: Text(_showTags ? 'Hide Tags' : 'Show Tags'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.post.artistTags.isNotEmpty) ...[
              const Text('Artists', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.post.artistTags
                    .map((t) => TagChip(tagName: t, category: TagCategory.artist))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.post.copyrightTags.isNotEmpty) ...[
              const Text('Copyright', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.post.copyrightTags
                    .map((t) => TagChip(tagName: t, category: TagCategory.copyright))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.post.characterTags.isNotEmpty) ...[
              const Text('Characters', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.post.characterTags
                    .map((t) => TagChip(tagName: t, category: TagCategory.character))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.post.generalTags.isNotEmpty) ...[
              const Text('General', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.post.generalTags
                    .map((t) => TagChip(tagName: t, category: TagCategory.general))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.post.metaTags.isNotEmpty) ...[
              const Text('Meta', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.post.metaTags
                    .map((t) => TagChip(tagName: t, category: TagCategory.meta))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}