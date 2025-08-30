import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/models/chat_conversation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ottiene la lista delle conversazioni di un utente in tempo reale
  Stream<List<ChatConversation>> getConversationsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatConversation.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Ottiene i messaggi di una conversazione in tempo reale
  Stream<List<ChatMessage>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
        .toList());
  }

  // Invia un messaggio e aggiorna la conversazione principale
  Future<void> sendMessage(String conversationId, ChatMessage message) async {
    final batch = _firestore.batch();

    // 1. Aggiunge il nuovo messaggio alla sottocollezione
    final messageRef = _firestore
        .collection('chats')
        .doc(conversationId)
        .collection('messages')
        .doc();
    batch.set(messageRef, message.toMap());

    // 2. Aggiorna il documento della conversazione principale
    final conversationRef = _firestore.collection('chats').doc(conversationId);
    batch.update(conversationRef, {
      'lastMessageText': message.text,
      'lastMessageTimestamp': message.timestamp,
    });

    await batch.commit();
  }

  // Avvia una nuova conversazione (o ne trova una esistente)
  Future<String> startOrGetConversation(String currentUserId, String otherUserId) async {
    final participants = [currentUserId, otherUserId]..sort(); // Ordina gli ID per una ricerca consistente

    final querySnapshot = await _firestore
        .collection('chats')
        .where('participants', isEqualTo: participants)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Se la conversazione esiste già, ritorna il suo ID
      return querySnapshot.docs.first.id;
    } else {
      // Altrimenti, crea una nuova conversazione
      final newConversation = await _firestore.collection('chats').add({
        'participants': participants,
        'lastMessageText': 'Conversazione avviata',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
      return newConversation.id;
    }
  }
}