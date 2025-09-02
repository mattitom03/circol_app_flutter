import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../services/chat_service.dart';
import '../../../core/models/chat_conversation.dart';
import 'new_chat_user_list_screen.dart';
import 'conversation_screen.dart';
import 'package:intl/intl.dart';
import '../viewmodels/chat_viewmodel.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_comment_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NewChatUserListScreen()),
                );
              },
            )
          ],
        ),
        body: Consumer<ChatViewModel>( // Il Consumer ora guarda il ChatViewModel
          builder: (context, chatViewModel, child) {
            final currentUserId = context.read<AuthViewModel>().currentUser?.uid;

            if (currentUserId == null || chatViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<List<ChatConversation>>(
              stream: ChatService().getConversationsStream(currentUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nessuna conversazione.'));
                }
                final conversations = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];

                    final otherUserId = conv.participants.firstWhere((id) => id != currentUserId, orElse: () => '');
                    // Usa metodo del ChatViewModel per trovare il nome
                    final otherUser = chatViewModel.getUserById(otherUserId);
                    final chatTitle = otherUser?.displayName ?? 'Utente';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(chatTitle.isNotEmpty ? chatTitle[0] : '?')),
                        title: Text(chatTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(conv.lastMessageText, overflow: TextOverflow.ellipsis),
                        trailing: Text(DateFormat('HH:mm').format(conv.lastMessageTimestamp)),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ConversationScreen(
                              conversationId: conv.id,
                              recipientName: chatTitle,
                            ),
                          ));
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}