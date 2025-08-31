import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nome;
  final String descrizione;
  final double prezzo;
  final int numeroPezzi;
  final bool ordinabile;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    required this.numeroPezzi,
    this.ordinabile = true,
    this.imageUrl,
  });

  /// Controlla se il prodotto è disponibile
  bool get isAvailable => ordinabile && numeroPezzi > 0;

  /// Controlla se il prodotto è esaurito
  bool get isEsaurito => numeroPezzi <= 0;

  /// Getter per compatibilità con i fragment esistenti
  String? get immagine => imageUrl;
  double get importo => prezzo;

  /// Crea un Product da una Map (da Firestore)
  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Product(
      id: documentId ?? map['id'] ?? '',
      nome: map['nome'] ?? '',
      descrizione: map['descrizione'] ?? '',
      prezzo: (map['importo'] ?? 0.0).toDouble(),
      numeroPezzi: map['numeroPezzi'] ?? 0,
      ordinabile: map['ordinabile'] ?? true,
      imageUrl: map['imageUrl'],
    );
  }

  /// Converte il Product in una Map per Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'importo': prezzo,
      'numeroPezzi': numeroPezzi,
      'ordinabile': ordinabile,
      'imageUrl': imageUrl,
    };
  }

  /// Helper per convertire Timestamp in DateTime
  static DateTime? _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (timestamp is String) return DateTime.parse(timestamp);
    } catch (e) {
      print('Errore conversione timestamp: $e');
    }
    return null;
  }

  /// Crea una copia del prodotto con alcuni campi modificati
  Product copyWith({
    String? id,
    String? nome,
    String? descrizione,
    double? prezzo,
    int? numeroPezzi,
    bool? ordinabile,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      prezzo: prezzo ?? this.prezzo,
      numeroPezzi: numeroPezzi ?? this.numeroPezzi,
      ordinabile: ordinabile ?? this.ordinabile,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Product(id: $id, nome: $nome, prezzo: €${prezzo.toStringAsFixed(2)}, disponibili: $numeroPezzi)';
  }
}
