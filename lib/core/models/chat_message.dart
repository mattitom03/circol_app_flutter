import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}