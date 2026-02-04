import 'package:intl/intl.dart';

enum MessageType { text, audio, image, video, mediaGroup }

enum MessageStatus { sent, delivered, read }

enum MediaType { image, video }

class ChatUser {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  ChatUser copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatUser(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

class MediaAttachment {
  final String path;
  final MediaType type;
  final String? thumbnailPath;
  final Duration? duration;
  final int? width;
  final int? height;

  MediaAttachment({
    required this.path,
    required this.type,
    this.thumbnailPath,
    this.duration,
    this.width,
    this.height,
  });
}

class Message {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final MessageType messageType;
  final MessageStatus status;
  final String? audioUrl;
  final Duration? audioDuration;
  final List<double>? waveformData;

  // For single media (legacy)
  final String? mediaUrl;
  final String? thumbnailUrl;
  final int? mediaWidth;
  final int? mediaHeight;
  final Duration? mediaDuration;

  // For media groups
  final List<MediaAttachment>? mediaItems;

  String get id => messageId;

  Message({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.status = MessageStatus.sent,
    this.audioUrl,
    this.audioDuration,
    this.waveformData,
    this.mediaUrl,
    this.thumbnailUrl,
    this.mediaWidth,
    this.mediaHeight,
    this.mediaDuration,
    this.mediaItems,
  });

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
  }

  Message copyWith({
    String? messageId,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
    MessageType? messageType,
    MessageStatus? status,
    String? audioUrl,
    Duration? audioDuration,
    List<double>? waveformData,
    String? mediaUrl,
    String? thumbnailUrl,
    int? mediaWidth,
    int? mediaHeight,
    Duration? mediaDuration,
    List<MediaAttachment>? mediaItems,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      status: status ?? this.status,
      audioUrl: audioUrl ?? this.audioUrl,
      audioDuration: audioDuration ?? this.audioDuration,
      waveformData: waveformData ?? this.waveformData,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
      mediaDuration: mediaDuration ?? this.mediaDuration,
      mediaItems: mediaItems ?? this.mediaItems,
    );
  }
}

class Conversation {
  final String conversationId;
  final String name;
  final String lastMessage;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final String? avatarUrl;
  final List<String> participants;

  Conversation({
    required this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
    this.avatarUrl,
    this.participants = const [],
  });

  String get formattedLastMessageTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(lastMessageTimestamp.year, lastMessageTimestamp.month, lastMessageTimestamp.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(lastMessageTimestamp);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(lastMessageTimestamp);
    }
  }

  Conversation copyWith({
    String? conversationId,
    String? name,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
    String? avatarUrl,
    List<String>? participants,
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      participants: participants ?? this.participants,
    );
  }
}

class DateGroup {
  final DateTime date;
  final List<Message> messages;

  DateGroup({required this.date, required this.messages});

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, y').format(date);
    }
  }
}
