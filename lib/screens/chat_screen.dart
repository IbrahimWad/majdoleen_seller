import 'package:flutter/material.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_composer.dart';
import '../core/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Conversation _conversation;
  late ChatService _chatService;
  List<Message> _messages = [];
  List<DateGroup> _dateGroups = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversation();
    });
  }

  void _loadConversation() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Conversation) {
      _conversation = args;
      _loadMessages();
      _chatService.markAsRead(_conversation.conversationId);
    }
  }

  void _loadMessages() {
    final messages = _chatService.getMessages(_conversation.conversationId);
    final dateGroups = _chatService.groupMessagesByDate(messages);

    setState(() {
      _messages = messages;
      _dateGroups = dateGroups;
      _isLoading = false;
    });

    // Scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendTextMessage(String text) async {
    final message = await _chatService.sendTextMessage(
      _conversation.conversationId,
      text,
      'user', // Current user ID
      'You', // Current user name
    );

    setState(() {
      _messages.add(message);
      _dateGroups = _chatService.groupMessagesByDate(_messages);
    });

    _scrollToBottom();
  }

  void _sendVoiceMessage(String audioPath, Duration duration, List<double> waveformData) async {
    final message = await _chatService.sendVoiceMessage(
      _conversation.conversationId,
      audioPath,
      duration,
      'user',
      'You',
      waveformData: waveformData,
    );

    setState(() {
      _messages.add(message);
      _dateGroups = _chatService.groupMessagesByDate(_messages);
    });

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: kSurfaceColor,
          foregroundColor: kInkColor,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_conversation.name),
        backgroundColor: kSurfaceColor,
        foregroundColor: kInkColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'block':
                  _showBlockDialog();
                  break;
                case 'report':
                  _showReportDialog();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'block',
                child: Text('Block'),
              ),
              const PopupMenuItem<String>(
                value: 'report',
                child: Text('Report'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: kSurfaceColor,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _dateGroups.length,
                itemBuilder: (context, groupIndex) {
                  final dateGroup = _dateGroups[groupIndex];
                  return Column(
                    children: [
                      DateSeparator(dateText: dateGroup.formattedDate),
                      ...dateGroup.messages.map((message) {
                        final isMe = message.senderId == 'user';
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ),
          MessageComposer(
            onSendText: _sendTextMessage,
            onSendVoice: _sendVoiceMessage,
            currentUserId: 'user',
            currentUserName: 'You',
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Block Contact'),
          content: Text('Are you sure you want to block ${_conversation.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle block logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_conversation.name} has been blocked')),
                );
              },
              child: const Text('Block', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Report Contact'),
          content: Text('Are you sure you want to report ${_conversation.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle report logic here
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
              child: const Text('Report', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}