import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../data/dummy_data.dart';
import '../models/chat_models.dart';
import '../utils/media_picker_service.dart';

class ChatService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;

  // Get conversations
  List<Conversation> getConversations() {
    return dummyConversations;
  }

  // Get messages for a conversation
  List<Message> getMessages(String conversationId) {
    return dummyMessages
        .where((message) => message.conversationId == conversationId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  // Group messages by date
  List<DateGroup> groupMessagesByDate(List<Message> messages) {
    final groups = <DateTime, List<Message>>{};

    for (final message in messages) {
      final date = DateTime(message.timestamp.year, message.timestamp.month, message.timestamp.day);
      if (groups[date] == null) {
        groups[date] = [];
      }
      groups[date]!.add(message);
    }

    return groups.entries
        .map((entry) => DateGroup(date: entry.key, messages: entry.value))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Send a text message
  Future<Message> sendTextMessage(String conversationId, String text, String senderId, String senderName) async {
    final message = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
    );

    // In a real app, this would be sent to backend
    dummyMessages.add(message);

    // Update conversation
    final conversationIndex = dummyConversations.indexWhere((c) => c.conversationId == conversationId);
    if (conversationIndex != -1) {
      dummyConversations[conversationIndex] = dummyConversations[conversationIndex].copyWith(
        lastMessage: text,
        lastMessageTimestamp: DateTime.now(),
      );
    }

    return message;
  }

  // Start voice recording
  Future<String> startRecording() async {
    if (!await _audioRecorder.hasPermission()) {
      throw Exception('Microphone permission not granted');
    }

    final directory = await getApplicationDocumentsDirectory();
    _currentRecordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

    await _audioRecorder.start(
      const RecordConfig(),
      path: _currentRecordingPath!,
    );

    return _currentRecordingPath!;
  }

  // Stop voice recording
  Future<Duration?> stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      final file = File(path);
      final duration = await _getAudioDuration(file);
      return duration;
    }
    return null;
  }

  // Send voice message
  Future<Message> sendVoiceMessage(String conversationId, String audioPath, Duration duration, String senderId, String senderName, {List<double>? waveformData}) async {
    final message = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: 'Voice message',
      timestamp: DateTime.now(),
      messageType: MessageType.audio,
      audioUrl: audioPath,
      audioDuration: duration,
      waveformData: waveformData,
    );

    dummyMessages.add(message);

    // Update conversation
    final conversationIndex = dummyConversations.indexWhere((c) => c.conversationId == conversationId);
    if (conversationIndex != -1) {
      dummyConversations[conversationIndex] = dummyConversations[conversationIndex].copyWith(
        lastMessage: 'Voice message',
        lastMessageTimestamp: DateTime.now(),
      );
    }

    return message;
  }

  // Send media messages (images/videos) as a single group
  Future<Message> sendMediaGroupMessage(String conversationId, List<MediaItem> mediaItems, String senderId, String senderName) async {
    final mediaAttachments = mediaItems.map((item) => MediaAttachment(
      path: item.path,
      type: item.type == MediaType.image ? MediaType.image : MediaType.video,
      thumbnailPath: item.type == MediaType.video ? item.path : null, // Placeholder
      duration: item.duration,
      width: item.width,
      height: item.height,
    )).toList();

    final message = Message(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: '',
      timestamp: DateTime.now(),
      messageType: MessageType.mediaGroup,
      mediaItems: mediaAttachments,
    );

    dummyMessages.add(message);

    // Update conversation
    final lastMessage = mediaItems.length == 1
        ? (mediaItems.first.type == MediaType.image ? 'Photo' : 'Video')
        : '${mediaItems.length} media files';

    final conversationIndex = dummyConversations.indexWhere((c) => c.conversationId == conversationId);
    if (conversationIndex != -1) {
      dummyConversations[conversationIndex] = dummyConversations[conversationIndex].copyWith(
        lastMessage: lastMessage,
        lastMessageTimestamp: DateTime.now(),
      );
    }

    return message;
  }

  // Mark conversation as read
  void markAsRead(String conversationId) {
    final conversationIndex = dummyConversations.indexWhere((c) => c.conversationId == conversationId);
    if (conversationIndex != -1) {
      dummyConversations[conversationIndex] = dummyConversations[conversationIndex].copyWith(
        unreadCount: 0,
      );
    }
  }

  // Get audio duration (simplified - in real app use a proper audio library)
  Future<Duration> _getAudioDuration(File file) async {
    // This is a placeholder. In a real app, you'd use a library like ffmpeg_kit or similar
    // For now, return a dummy duration
    await Future.delayed(const Duration(milliseconds: 100));
    return const Duration(seconds: 3); // Dummy duration
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}