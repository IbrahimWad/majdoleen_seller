import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../utils/media_picker_service.dart';
import '../models/chat_models.dart';

class MediaPreviewScreen extends StatefulWidget {
  final List<MediaItem> selectedMedia;
  final Function(List<MediaItem>) onSend;
  final VoidCallback onCancel;

  const MediaPreviewScreen({
    super.key,
    required this.selectedMedia,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late List<MediaItem> _mediaItems;
  int _currentIndex = 0;
  final TextEditingController _captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mediaItems = List.from(widget.selectedMedia);
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaItems.removeAt(index);
      if (_currentIndex >= _mediaItems.length) {
        _currentIndex = _mediaItems.length - 1;
      }
      if (_mediaItems.isEmpty) {
        Navigator.of(context).pop();
      }
    });
  }

  void _sendMedia() {
    if (_mediaItems.isNotEmpty) {
      widget.onSend(_mediaItems);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${_mediaItems.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _sendMedia,
            child: Text(
              'Send',
              style: TextStyle(
                color: kBrandColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main preview area
          Expanded(
            child: PageView.builder(
              itemCount: _mediaItems.length,
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final media = _mediaItems[index];
                return _buildMediaPreview(media);
              },
            ),
          ),

          // Thumbnail strip
          Container(
            height: 80,
            color: Colors.black,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mediaItems.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                return _buildThumbnail(index);
              },
            ),
          ),

          // Caption input (optional, can be enabled later)
          // Container(
          //   color: Colors.grey[900],
          //   padding: const EdgeInsets.all(16),
          //   child: TextField(
          //     controller: _captionController,
          //     style: const TextStyle(color: Colors.white),
          //     decoration: const InputDecoration(
          //       hintText: 'Add a caption...',
          //       hintStyle: TextStyle(color: Colors.grey),
          //       border: InputBorder.none,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaItem media) {
    if (media.type == MediaType.image) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.file(
          File(media.path),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      // Video preview (show thumbnail or first frame)
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File(media.path), // This will show the video thumbnail/first frame
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 30,
            ),
          ),
          if (media.duration != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(media.duration!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      );
    }
  }

  Widget _buildThumbnail(int index) {
    final media = _mediaItems[index];
    final isSelected = index == _currentIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? kBrandColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(media.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (media.type == MediaType.video)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.videocam,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Positioned(
              top: 2,
              left: 2,
              child: GestureDetector(
                onTap: () => _removeMedia(index),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}