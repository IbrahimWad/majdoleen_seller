import '../models/chat_models.dart';

List<Conversation> dummyConversations = [
  Conversation(
    conversationId: '1',
    name: 'Customer Support',
    lastMessage: 'Thank you for your help!',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    unreadCount: 2,
  ),
  Conversation(
    conversationId: '2',
    name: 'John Doe',
    lastMessage: 'When will my order arrive?',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
    unreadCount: 0,
  ),
  Conversation(
    conversationId: '3',
    name: 'Jane Smith',
    lastMessage: 'Great product!',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1)),
    unreadCount: 1,
  ),
  Conversation(
    conversationId: '4',
    name: 'Alice Johnson',
    lastMessage: 'Can I get a refund?',
    lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 2)),
    unreadCount: 0,
  ),
];

List<Message> dummyMessages = [
  Message(
    messageId: '1',
    conversationId: '1',
    senderId: 'support',
    senderName: 'Customer Support',
    text: 'Hello! How can I help you today?',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
  ),
  Message(
    messageId: '2',
    conversationId: '1',
    senderId: 'user',
    senderName: 'You',
    text: 'I have a question about my order.',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 50)),
  ),
  Message(
    messageId: '3',
    conversationId: '1',
    senderId: 'support',
    senderName: 'Customer Support',
    text: 'Sure, I\'d be happy to assist. What\'s your order number?',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 1, minutes: 45)),
  ),
  Message(
    messageId: '4',
    conversationId: '1',
    senderId: 'user',
    senderName: 'You',
    text: 'It\'s MS-1042.',
    timestamp: DateTime.now().subtract(const Duration(hours: 30)),
  ),
  Message(
    messageId: '5',
    conversationId: '1',
    senderId: 'support',
    senderName: 'Customer Support',
    text: 'Thank you for your help!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
  ),
  Message(
    messageId: '6',
    conversationId: '1',
    senderId: 'user',
    senderName: 'You',
    text: 'Voice message test',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    messageType: MessageType.audio,
    audioUrl: 'dummy_audio.mp3',
    audioDuration: const Duration(seconds: 5),
  ),
];