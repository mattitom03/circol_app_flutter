import 'package:cloud_firestore/cloud_firestore.dart';


/// Modello per rappresentare un movimento finanziario dell'utente
class Movimento {
  final String id;
  final double importo;
  final String descrizione;
  final DateTime data;
  final String tipo;
  final String userId;
  // "ricarica", "pagamento", "riscossione", etc.

  const Movimento({
    required this.id,
    required this.importo,
    required this.descrizione,
    required this.data,
    required this.tipo,
    required this.userId,

  });

  /// Crea un Movimento da un Map
  factory Movimento.fromMap(Map<String, dynamic> map) {
    return Movimento(
      id: map['id'] ?? '',
      importo: (map['importo'] ?? 0.0).toDouble(),
      descrizione: map['descrizione'] ?? '',
      data: (map['data'] as Timestamp? ?? Timestamp.now()).toDate(),
      tipo: map['tipo'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  /// Converte il Movimento in un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'importo': importo,
      'descrizione': descrizione,
      'data': data.millisecondsSinceEpoch,
      'tipo': tipo,
      'userId': userId,
    };
  }

  @override
  String toString() {
    return 'Movimento(id: $id, importo: $importo, descrizione: $descrizione, tipo: $tipo)';
  }
}
