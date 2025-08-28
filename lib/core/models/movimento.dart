import 'package:cloud_firestore/cloud_firestore.dart';

class Movimento {
  final String id;
  final double importo;
  final String descrizione;
  final DateTime data;
  final String tipo;
  final String userId;

  const Movimento({
    required this.id,
    required this.importo,
    required this.descrizione,
    required this.data,
    required this.tipo,
    required this.userId,
  });

  factory Movimento.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Movimento(
      id: documentId ?? map['id'] ?? '',
      importo: (map['importo'] ?? 0.0).toDouble(),
      descrizione: map['descrizione'] ?? '',
      data: _convertData(map['data']) ?? DateTime.now(),
      tipo: map['tipo'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  /// Converte il Movimento in una Map per il salvataggio su Firestore
  Map<String, dynamic> toMap() {
    return {
      'importo': importo,
      'descrizione': descrizione,
      'data': Timestamp.fromDate(data), // Usiamo Timestamp per coerenza con Firestore
      'tipo': tipo,
      'userId': userId,
    };
  }
}

/// FUNZIONE HELPER PER CONVERTIRE QUALSIASI TIPO DI DATA
DateTime? _convertData(dynamic dateData) {
  if (dateData == null) return null;
  if (dateData is Timestamp) return dateData.toDate();
  if (dateData is int) return DateTime.fromMillisecondsSinceEpoch(dateData);
  if (dateData is double) return DateTime.fromMillisecondsSinceEpoch(dateData.toInt());
  if (dateData is String) return DateTime.tryParse(dateData);
  return null;
}