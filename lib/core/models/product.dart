import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String nome;
  final String descrizione;
  final double prezzo;
  final String categoria;
  final int numeroPezzi;
  final bool ordinabile;
  final String? immagine;
  final DateTime dataCreazione;
  final DateTime? dataAggiornamento;
  final Map<String, dynamic>? metadata;

  const Product({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.prezzo,
    required this.categoria,
    required this.numeroPezzi,
    this.ordinabile = true,
    this.immagine,
    required this.dataCreazione,
    this.dataAggiornamento,
    this.metadata,
  });

  /// Controlla se il prodotto è disponibile
  bool get isAvailable => ordinabile && numeroPezzi > 0;

  /// Controlla se il prodotto è esaurito
  bool get isEsaurito => numeroPezzi <= 0;

  /// Controlla se è un prodotto nuovo (creato negli ultimi 7 giorni)
  bool get isNuovo {
    final now = DateTime.now();
    final differenza = now.difference(dataCreazione);
    return differenza.inDays <= 7;
  }

  /// Getter per compatibilità con i fragment esistenti
  String? get imageUrl => immagine;
  double get importo => prezzo;

  /// Crea un Product da una Map (da Firestore)
  factory Product.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Product(
      id: documentId ?? map['id'] ?? '',
      nome: map['nome'] ?? '',
      descrizione: map['descrizione'] ?? '',
      prezzo: (map['importo'] ?? 0.0).toDouble(),
      categoria: map['categoria'] ?? '',
      numeroPezzi: map['numeroPezzi'] ?? 0,
      ordinabile: map['ordinabile'] ?? true,
      immagine: map['immagine'],
      dataCreazione: _timestampToDateTime(map['dataCreazione']) ?? DateTime.now(),
      dataAggiornamento: map['dataAggiornamento'] != null
          ? _timestampToDateTime(map['dataAggiornamento'])
          : null,
      metadata: map['metadata'],
    );
  }

  /// Converte il Product in una Map per Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'prezzo': prezzo,
      'categoria': categoria,
      'numeroPezzi': numeroPezzi,
      'ordinabile': ordinabile,
      'immagine': immagine,
      'dataCreazione': Timestamp.fromDate(dataCreazione),
      'dataAggiornamento': dataAggiornamento != null
          ? Timestamp.fromDate(dataAggiornamento!)
          : null,
      'metadata': metadata,
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
    String? categoria,
    int? numeroPezzi,
    bool? ordinabile,
    String? immagine,
    DateTime? dataCreazione,
    DateTime? dataAggiornamento,
    Map<String, dynamic>? metadata,
  }) {
    return Product(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      prezzo: prezzo ?? this.prezzo,
      categoria: categoria ?? this.categoria,
      numeroPezzi: numeroPezzi ?? this.numeroPezzi,
      ordinabile: ordinabile ?? this.ordinabile,
      immagine: immagine ?? this.immagine,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      dataAggiornamento: dataAggiornamento ?? this.dataAggiornamento,
      metadata: metadata ?? this.metadata,
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
