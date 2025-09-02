import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../services/chat_service.dart';
import 'conversation_screen.dart';
import '../viewmodels/new_chat_viewmodel.dart';

class NewChatUserListScreen extends StatelessWidget {
  const NewChatUserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usiamo il ViewModel per sapere chi siamo
    final currentUserId = context.read<AuthViewModel>().currentUser!.uid;

    return ChangeNotifierProvider(
      create: (_) => NewChatViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Scegli un utente')),
        body: Consumer<NewChatViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: viewModel.users.length,
              itemBuilder: (context, index) {
                final user = viewModel.users[index];
                // Non mostrare l'utente corrente nella lista
                if (user.uid == currentUserId) return const SizedBox.shrink();

                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user.displayName),
                  subtitle: Text('@${user.username}'),
                  onTap: () async {
                    final conversationId = await ChatService().startOrGetConversation(currentUserId, user.uid);
                    // Chiudiamo la lista utenti e apriamo la conversazione
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ConversationScreen(conversationId: conversationId, recipientName: user.displayName),
                    ));
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