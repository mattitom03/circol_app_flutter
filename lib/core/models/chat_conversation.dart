import 'package:cloud_firestore/cloud_firestore.dart';

class ChatConversation {
  final String id;
  final List<String> participants;
  final String lastMessageText;
  final DateTime lastMessageTimestamp;

  ChatConversation({
    required this.id,
    required this.participants,
    required this.lastMessageText,
    required this.lastMessageTimestamp,
  });

  factory ChatConversation.fromMap(Map<String, dynamic> map, String id) {
    return ChatConversation(
      id: id,
      participants: List<String>.from(map['participants'] ?? []),
      lastMessageText: map['lastMessageText'] ?? '',
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }
}