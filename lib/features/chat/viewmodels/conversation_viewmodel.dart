import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/models/chat_message.dart';
import '../services/chat_service.dart';

class ConversationViewModel extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final String conversationId;
  final String currentUserId;

  late StreamSubscription<List<ChatMessage>> _messagesSubscription;
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ConversationViewModel({required this.conversationId, required this.currentUserId}) {
    _messagesSubscription = _chatService.getMessagesStream(conversationId).listen((messages) {
      _messages = messages;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: '',
      senderId: currentUserId,
      text: text,
      timestamp: DateTime.now(),
    );
    await _chatService.sendMessage(conversationId, newMessage);
  }

  @override
  void dispose() {
    _messagesSubscription.cancel();
    super.dispose();
  }
}