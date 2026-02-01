import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/app_colors.dart';
import '../../models/chat_models.dart';
import '../screens/image_viewer_screen.dart';
import '../screens/video_player_screen.dart';
import '../screens/media_gallery_viewer.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;
  bool _isDragging = false; // Track if user is currently dragging
  double _dragProgress = 0.0; // Current drag position (0.0 to 1.0)

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.positionStream.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.durationStream.listen((duration) {
      setState(() {
        _totalDuration = duration ?? Duration.zero;
      });
    });

    _audioPlayer.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
        _isLoading = state.processingState == ProcessingState.loading ||
                     state.processingState == ProcessingState.buffering;

        // Reset play state when playback completes
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _currentPosition = Duration.zero;
        }
      });
    });
  }

  Future<void> _playPauseAudio() async {
    if (widget.message.audioUrl == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        setState(() => _isLoading = true);
        await _audioPlayer.setFilePath(widget.message.audioUrl!);
        await _audioPlayer.play();
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error playing audio: $e');
    }
  }

  Future<void> _seekAudio(double value) async {
    final position = Duration(milliseconds: (value * _totalDuration.inMilliseconds).toInt());
    await _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: widget.isMe ? kBrandColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: widget.isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.message.messageType == MessageType.audio)
              _buildAudioContent()
            else if (widget.message.messageType == MessageType.mediaGroup)
              _buildMediaGroupContent()
            else if (widget.message.messageType == MessageType.image)
              _buildImageContent()
            else if (widget.message.messageType == MessageType.video)
              _buildVideoContent()
            else
              _buildTextContent(),
            const SizedBox(height: 4),
            Text(
              widget.message.formattedTime,
              style: theme.textTheme.bodySmall?.copyWith(
                color: widget.isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    return Text(
      widget.message.text,
      style: TextStyle(
        color: widget.isMe ? Colors.white : kInkColor,
        fontSize: 16,
      ),
    );
  }

  Widget _buildImageContent() {
    if (widget.message.mediaUrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageViewerScreen(
              imagePath: widget.message.mediaUrl!,
              heroTag: 'message_image_${widget.message.id}',
            ),
          ),
        );
      },
      child: Hero(
        tag: 'message_image_${widget.message.id}',
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
            maxHeight: 200,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.message.mediaUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.error),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (widget.message.mediaUrl == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoPath: widget.message.mediaUrl!,
              heroTag: 'message_video_${widget.message.id}',
            ),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'message_video_${widget.message.id}',
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black,
                    ),
                    child: widget.message.thumbnailUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(widget.message.thumbnailUrl!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.video_file, size: 50),
                                );
                              },
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.video_file, size: 50),
                          ),
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
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
              ],
            ),
            if (widget.message.mediaDuration != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _formatDuration(widget.message.mediaDuration!),
                  style: TextStyle(
                    color: widget.isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGroupContent() {
    if (widget.message.mediaItems == null || widget.message.mediaItems!.isEmpty) {
      return const SizedBox.shrink();
    }

    final mediaItems = widget.message.mediaItems!;
    final itemCount = mediaItems.length;
    final crossAxisCount = itemCount == 1 ? 1 : itemCount <= 4 ? 2 : 3;

    return GestureDetector(
      onTap: () {
        // Open full-screen gallery viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaGalleryViewer(
              mediaItems: mediaItems,
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemCount: itemCount > 6 ? 6 : itemCount, // Show max 6 items
          itemBuilder: (context, index) {
            if (index == 5 && itemCount > 6) {
              // Show overlay with remaining count
              return Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '+${itemCount - 5}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }

            final mediaItem = mediaItems[index];
            return Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: mediaItem.type == MediaType.image
                      ? Image.file(
                          File(mediaItem.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 30),
                            );
                          },
                        )
                      : (mediaItem.thumbnailPath != null
                          ? Image.file(
                              File(mediaItem.thumbnailPath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.video_file, size: 30),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.video_file, size: 30),
                            )),
                ),
                if (mediaItem.type == MediaType.video)
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAudioContent() {
    final duration = widget.message.audioDuration ?? _totalDuration;
    // Use drag progress if currently dragging, otherwise use current position
    final progress = _isDragging
        ? _dragProgress
        : (duration.inMilliseconds > 0 ? _currentPosition.inMilliseconds / duration.inMilliseconds : 0.0);

    return Container(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Play/Pause button
              IconButton(
                onPressed: _playPauseAudio,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isMe ? Colors.white : kBrandColor,
                          ),
                        ),
                      )
                    : Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: widget.isMe ? Colors.white : kBrandColor,
                      ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              // Waveform visualization with progress integrated
              Expanded(
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _isDragging = true;
                      // Calculate initial drag position
                      final box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final localPosition = box.globalToLocal(details.globalPosition);
                        _dragProgress = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                      }
                    });
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isDragging) {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final localPosition = box.globalToLocal(details.globalPosition);
                        setState(() {
                          _dragProgress = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                        });
                      }
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isDragging) {
                      // Seek to the dragged position
                      _seekAudio(_dragProgress);
                      setState(() {
                        _isDragging = false;
                      });
                    }
                  },
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final localPosition = box.globalToLocal(details.globalPosition);
                      final progress = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
                      _seekAudio(progress);
                    }
                  },
                  child: Container(
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        20,
                        (index) {
                          // Use stored waveform data if available, otherwise use default
                          final waveformData = widget.message.waveformData;
                          final defaultHeight = 8 + (index % 3) * 4.0;
                          final amplitude = waveformData != null && index < waveformData.length
                              ? waveformData[index]
                              : (defaultHeight / 30.0); // Normalize to 0-1 range

                          // Calculate if this bar should be "played" based on progress
                          final barProgress = (index + 1) / 20.0;
                          final isPlayed = barProgress <= progress;

                          return Container(
                            width: 2,
                            height: 8 + (amplitude * 22), // Scale amplitude to 8-30 height range
                            decoration: BoxDecoration(
                              color: isPlayed
                                  ? (widget.isMe ? Colors.white : kBrandColor)
                                  : (widget.isMe ? Colors.white.withOpacity(0.3) : Colors.grey[400]),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Duration
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  color: widget.isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          // Current position (moved below waveform)
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 4),
            child: Text(
              _formatDuration(_isDragging
                  ? Duration(milliseconds: (_dragProgress * duration.inMilliseconds).toInt())
                  : _currentPosition),
              style: TextStyle(
                color: widget.isMe ? Colors.white.withOpacity(0.5) : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}