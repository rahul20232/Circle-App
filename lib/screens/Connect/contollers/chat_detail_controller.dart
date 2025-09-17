// lib/controllers/chat_detail_controller.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/chat_model.dart';
import '../../../services/chat_service.dart';
import '../../../services/auth_service.dart';

class ChatDetailController extends ChangeNotifier {
  // Controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ChatService _chatService = ChatService();

  // State variables
  List<Message> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _isTyping = false;
  bool _otherUserTyping = false;
  String? _errorMessage;
  int? _currentUserId;

  // Subscriptions and timers
  StreamSubscription? _messageSubscription;
  Timer? _typingTimer;

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isTyping => _isTyping;
  bool get otherUserTyping => _otherUserTyping;
  String? get errorMessage => _errorMessage;
  int? get currentUserId => _currentUserId;

  // Initialize chat
  Future<void> initializeChat(Chat chat) async {
    try {
      // Get current user ID
      _currentUserId = await AuthService.getCurrentUserId();
      if (_currentUserId == null) {
        _setError('User not authenticated');
        return;
      }

      // Connect to WebSocket
      await _chatService.connect(_currentUserId!);

      // Load chat messages
      await loadMessages(chat.id);

      // Listen for real-time messages
      _messageSubscription =
          _chatService.messageStream.listen(_handleWebSocketMessage);

      // Mark messages as read
      _chatService.markMessagesAsRead(chat.id);
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Load messages
  Future<void> loadMessages(int chatId) async {
    try {
      _setLoading(true);
      _setError(null);

      final chatDetail = await ChatService.getChatDetail(chatId);

      // Sort messages by sent time to ensure proper chronological order
      final sortedMessages = chatDetail.messages.toList()
        ..sort((a, b) => a.sentAt.compareTo(b.sentAt));

      _messages = sortedMessages;
      _setLoading(false);

      notifyListeners();

      // Schedule scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Insert message in chronological order
  void _insertMessageInOrder(Message newMessage) {
    int insertIndex = _messages.length;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].sentAt.isBefore(newMessage.sentAt)) {
        insertIndex = i + 1;
        break;
      }
    }
    _messages.insert(insertIndex, newMessage);
  }

  // Handle WebSocket messages
  void _handleWebSocketMessage(WebSocketMessage wsMessage) {
    switch (wsMessage.type) {
      case 'message':
        final message = Message.fromJson(wsMessage.data);
        _handleNewMessage(message);
        break;
      case 'typing':
        _handleTypingIndicator(wsMessage.data);
        break;
      case 'read_receipt':
        _handleReadReceipt(wsMessage.data);
        break;
    }
  }

  void _handleNewMessage(Message message) {
    // Check if this is a confirmation of our optimistic message
    final existingIndex = _messages.indexWhere((msg) =>
        msg.senderId == message.senderId &&
        msg.content == message.content &&
        msg.sentAt.difference(message.sentAt).inSeconds.abs() < 10);

    if (existingIndex != -1) {
      // Update the optimistic message with real server data
      _messages[existingIndex] = message;
    } else {
      // This is a new message from another user
      _insertMessageInOrder(message);
    }

    notifyListeners();
    scrollToBottom();

    // Mark as read if not from current user
    if (message.senderId != _currentUserId) {
      _chatService.markMessagesAsRead(message.chatId);
    }
  }

  void _handleTypingIndicator(Map<String, dynamic> data) {
    if (data['user_id'] != _currentUserId) {
      _otherUserTyping = data['is_typing'] ?? false;
      notifyListeners();
    }
  }

  void _handleReadReceipt(Map<String, dynamic> data) {
    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].senderId == _currentUserId) {
        _messages[i] = _messages[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }

  // Send message
  void sendMessage(int chatId) {
    final content = messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    _setSending(true);

    // Create optimistic message
    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: chatId,
      senderId: _currentUserId!,
      content: content,
      messageType: 'text',
      sentAt: DateTime.now(),
      isRead: false,
      senderName: 'You',
    );

    // Add to UI immediately (optimistic update)
    _insertMessageInOrder(optimisticMessage);
    notifyListeners();

    // Clear input and stop typing
    messageController.clear();
    stopTyping(chatId);

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });

    try {
      // Send via WebSocket
      _chatService.sendMessage(chatId, content);
    } catch (e) {
      // If sending fails, remove the optimistic message
      _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
      notifyListeners();
      rethrow; // Re-throw for UI to handle
    } finally {
      _setSending(false);
    }
  }

  // Handle typing
  void onTyping(String text, int chatId) {
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      notifyListeners();
      _chatService.sendTypingIndicator(chatId, true);
    }

    // Reset typing timer
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      stopTyping(chatId);
    });
  }

  void stopTyping(int chatId) {
    if (_isTyping) {
      _isTyping = false;
      notifyListeners();
      _chatService.sendTypingIndicator(chatId, false);
    }
    _typingTimer?.cancel();
  }

  // Scroll to bottom
  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setSending(bool sending) {
    _isSending = sending;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  // Cleanup
  @override
  void dispose() {
    _messageSubscription?.cancel();
    _typingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
