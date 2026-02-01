import 'package:intl/intl.dart';

enum MessageType { text, audio }

enum MessageStatus { sent, delivered, read }

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
  final List<double>? waveformData; // Store waveform samples for consistent display

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

  Conversation({
    required this.conversationId,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.unreadCount = 0,
    this.avatarUrl,
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
  }) {
    return Conversation(
      conversationId: conversationId ?? this.conversationId,
      name: name ?? this.name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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