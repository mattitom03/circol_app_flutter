import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/conversation_viewmodel.dart';
import '../../../core/models/chat_message.dart';

class ConversationScreen extends StatelessWidget {
  final String conversationId;
  final String recipientName;
  const ConversationScreen({super.key, required this.conversationId, required this.recipientName});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthViewModel>().currentUser!.uid;

    return ChangeNotifierProvider(
      create: (_) => ConversationViewModel(
        conversationId: conversationId,
        currentUserId: currentUserId,
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Conversazione')),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ConversationViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    reverse: true, // Mostra i messaggi dal basso verso l'alto
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      final isMe = message.senderId == currentUserId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInputField(),
          ],
        ),
      ),
    );
  }
}

// Widget per l'input di testo
class _buildMessageInputField extends StatefulWidget {
  @override
  __buildMessageInputFieldState createState() => __buildMessageInputFieldState();
}

class __buildMessageInputFieldState extends State<_buildMessageInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    context.read<ConversationViewModel>().sendMessage(_controller.text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Scrivi un messaggio...'),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}

// Widget per la "bolla" del messaggio
Widget _buildMessageBubble(ChatMessage message, bool isMe) {
  return Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message.text,
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
      ),
    ),
  );
}