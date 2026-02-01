import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../models/chat_models.dart';

class MediaItem {
  final String path;
  final MediaType type;
  final int? width;
  final int? height;
  final Duration? duration;

  MediaItem({
    required this.path,
    required this.type,
    this.width,
    this.height,
    this.duration,
  });

  Future<String?> generateThumbnail() async {
    if (type == MediaType.video) {
      // For videos, we'll use the first frame as thumbnail
      // In a real implementation, you might want to use a proper thumbnail generation library
      return path; // Placeholder - return video path itself
    }
    return path; // For images, return the image path
  }
}

class MediaPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<List<MediaItem>> pickMultipleMedia(BuildContext context) async {
    final List<MediaItem> selectedMedia = [];

    // First, pick images
    try {
      final imageFiles = await _picker.pickMultiImage();
      for (final image in imageFiles) {
        final file = File(image.path);
        final size = await _getImageSize(file);
        selectedMedia.add(MediaItem(
          path: image.path,
          type: MediaType.image,
          width: size?.width.toInt(),
          height: size?.height.toInt(),
        ));
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }

    // Then, ask if they want to add videos
    final addVideos = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Videos?'),
        content: const Text('Do you want to add videos to your selection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (addVideos == true) {
      try {
        final videoFile = await _picker.pickVideo(source: ImageSource.gallery);
        if (videoFile != null) {
          final file = File(videoFile.path);
          final duration = await _getVideoDuration(file);
          selectedMedia.add(MediaItem(
            path: videoFile.path,
            type: MediaType.video,
            duration: duration,
          ));
        }
      } catch (e) {
        debugPrint('Error picking video: $e');
      }
    }

    return selectedMedia;
  }

  Future<ui.Size?> _getImageSize(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return ui.Size(frameInfo.image.width.toDouble(), frameInfo.image.height.toDouble());
    } catch (e) {
      return null;
    }
  }

  Future<Duration?> _getVideoDuration(File file) async {
    try {
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final duration = controller.value.duration;
      await controller.dispose();
      return duration;
    } catch (e) {
      return null;
    }
  }
}