import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/date_separator.dart';
import '../widgets/message_composer.dart';
import '../core/app_colors.dart';
import '../utils/media_picker_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late Conversation _conversation;
  late ChatService _chatService;
  List<Message> _messages = [];
  List<DateGroup> _dateGroups = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  final String _currentUserId = 'user';
  String? _otherUserId;
  Stream<ChatUser>? _otherUserStream;
  ChatUser? _otherUserFallback;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService();
    WidgetsBinding.instance.addObserver(this);
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
      _setupOtherUser();
      _chatService.setUserOnlineStatus(_currentUserId, true);
    }
  }

  void _setupOtherUser() {
    if (_conversation.participants.isNotEmpty) {
      _otherUserId = _conversation.participants.firstWhere(
        (id) => id != _currentUserId,
        orElse: () => '',
      );
    }

    if (_otherUserId != null && _otherUserId!.isNotEmpty) {
      _otherUserStream = _chatService.watchUser(_otherUserId!);
      _otherUserFallback = _chatService.getUser(_otherUserId!);
    }

    _otherUserFallback ??= ChatUser(
      userId: _otherUserId?.isNotEmpty == true ? _otherUserId! : 'unknown',
      displayName: _conversation.name,
      photoUrl: _conversation.avatarUrl,
    );
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
      _currentUserId, // Current user ID
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
      _currentUserId,
      'You',
      waveformData: waveformData,
    );

    setState(() {
      _messages.add(message);
      _dateGroups = _chatService.groupMessagesByDate(_messages);
    });

    _scrollToBottom();
  }

  void _sendMediaMessages(List<MediaItem> mediaItems) async {
    final message = await _chatService.sendMediaGroupMessage(
      _conversation.conversationId,
      mediaItems,
      _currentUserId,
      'You',
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
        titleSpacing: 0,
        title: _buildAppBarTitle(),
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
                        final isMe = message.senderId == _currentUserId;
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
            onSendMedia: _sendMediaMessages,
            currentUserId: _currentUserId,
            currentUserName: 'You',
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chatService.setUserOnlineStatus(_currentUserId, true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _chatService.setUserOnlineStatus(_currentUserId, false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  Widget _buildAppBarTitle() {
    final fallbackUser = _otherUserFallback;
    if (_otherUserStream == null || fallbackUser == null) {
      return Text(_conversation.name);
    }

    return StreamBuilder<ChatUser>(
      stream: _otherUserStream,
      builder: (context, snapshot) {
        final user = snapshot.data ?? fallbackUser;
        final statusText = _presenceText(user);
        return Row(
          children: [
            GestureDetector(
              onTap: _openContactProfile,
              child: _buildAvatar(
                displayName: user.displayName,
                photoUrl: user.photoUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    statusText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar({required String displayName, String? photoUrl}) {
    final initial = displayName.trim().isNotEmpty ? displayName.trim()[0].toUpperCase() : '?';
    if (photoUrl == null || photoUrl.trim().isEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: kBrandColor.withOpacity(0.1),
        child: Text(
          initial,
          style: TextStyle(
            color: kBrandColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: kBrandColor.withOpacity(0.1),
      child: ClipOval(
        child: Image.network(
          photoUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              color: kBrandColor.withOpacity(0.1),
              child: Text(
                initial,
                style: TextStyle(
                  color: kBrandColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _presenceText(ChatUser user) {
    if (user.isOnline) {
      return 'online';
    }
    final lastSeen = user.lastSeen;
    if (lastSeen == null) {
      return 'offline';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final seenDate = DateTime(lastSeen.year, lastSeen.month, lastSeen.day);
    final timeText = DateFormat('HH:mm').format(lastSeen);

    if (seenDate == today) {
      return 'last seen today at $timeText';
    }
    if (seenDate == yesterday) {
      return 'last seen yesterday at $timeText';
    }
    return 'last seen ${DateFormat('dd/MM/yyyy HH:mm').format(lastSeen)}';
  }

  void _openContactProfile() {
    // No contact profile route in this project yet.
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
