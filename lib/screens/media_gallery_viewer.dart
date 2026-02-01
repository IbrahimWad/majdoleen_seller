import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/chat_models.dart';

class MediaGalleryViewer extends StatefulWidget {
  final List<MediaAttachment> mediaItems;
  final int initialIndex;

  const MediaGalleryViewer({
    Key? key,
    required this.mediaItems,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MediaGalleryViewer> createState() => _MediaGalleryViewerState();
}

class _MediaGalleryViewerState extends State<MediaGalleryViewer> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  bool _isVideoPlaying = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeCurrentMedia();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeCurrentMedia() {
    final currentItem = widget.mediaItems[_currentIndex];
    if (currentItem.type == MediaType.video) {
      _initializeVideoController(currentItem.path);
    } else {
      _videoController?.dispose();
      _videoController = null;
      _isVideoPlaying = false;
    }
  }

  void _initializeVideoController(String videoPath) async {
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(File(videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  void _toggleVideoPlayback() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      setState(() {
        if (_isVideoPlaying) {
          _videoController!.pause();
        } else {
          _videoController!.play();
        }
        _isVideoPlaying = !_isVideoPlaying;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _initializeCurrentMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.mediaItems.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.mediaItems.length,
        itemBuilder: (context, index) {
          final mediaItem = widget.mediaItems[index];
          return _buildMediaItem(mediaItem, index);
        },
      ),
    );
  }

  Widget _buildMediaItem(MediaAttachment mediaItem, int index) {
    if (mediaItem.type == MediaType.image) {
      return InteractiveViewer(
        child: Center(
          child: Image.file(
            File(mediaItem.path),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.error,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Video
      if (_videoController != null && _videoController!.value.isInitialized) {
        return GestureDetector(
          onTap: _toggleVideoPlayback,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              if (!_isVideoPlaying)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
            ],
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
    }
  }
}