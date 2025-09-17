// lib/screens/Connect/chat_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import './contoller/chat_detail_controller.dart';
import './chat_detail_components.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat chat;

  const ChatDetailScreen({
    Key? key,
    required this.chat,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late ChatDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChatDetailController();
    _controller.initializeChat(widget.chat);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    try {
      _controller.sendMessage(widget.chat.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _handleTyping(String text) {
    _controller.onTyping(text, widget.chat.id);
  }

  void _handleRetry() {
    _controller.loadMessages(widget.chat.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: ChatDetailComponents.buildAppBar(
        chat: widget.chat,
        otherUserTyping: _controller.otherUserTyping,
        onBackPressed: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFFEF1DE),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Tap outside to dismiss keyboard
        },
        child: Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  if (scrollNotification is ScrollStartNotification) {
                    FocusScope.of(context)
                        .unfocus(); // Scroll to dismiss keyboard
                  }
                  return false;
                },
                child: ListenableBuilder(
                  listenable: _controller,
                  builder: (context, child) {
                    return ChatDetailComponents.buildMessagesList(
                      isLoading: _controller.isLoading,
                      errorMessage: _controller.errorMessage,
                      messages: _controller.messages,
                      currentUserId: _controller.currentUserId,
                      chat: widget.chat,
                      scrollController: _controller.scrollController,
                      onRetry: _handleRetry,
                    );
                  },
                ),
              ),
            ),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return ChatDetailComponents.buildMessageInput(
                  messageController: _controller.messageController,
                  isSending: _controller.isSending,
                  onSendMessage: _handleSendMessage,
                  onTyping: _handleTyping,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
