import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String nome;
  final String descrizione;
  final DateTime dataInizio;
  final DateTime? dataFine;
  final String luogo;
  final List<String> partecipanti;
  final String organizzatore;
  final int maxPartecipanti;
  final bool isPublico;
  final DateTime dataCreazione;
  final String? immagine;
  final Map<String, dynamic>? metadata;
  final double? quota; // Aggiunto per compatibilità con i fragment

  const Evento({
    required this.id,
    required this.nome,
    required this.descrizione,
    required this.dataInizio,
    this.dataFine,
    required this.luogo,
    required this.partecipanti,
    required this.organizzatore,
    this.maxPartecipanti = 0,
    this.isPublico = true,
    required this.dataCreazione,
    this.immagine,
    this.metadata,
    this.quota,
  });

  /// Controlla se l'evento è nel futuro
  bool get isFuturo => dataInizio.isAfter(DateTime.now());

  /// Controlla se l'evento è attivo (in corso)
  bool get isAttivo {
    final now = DateTime.now();
    if (dataFine != null) {
      return now.isAfter(dataInizio) && now.isBefore(dataFine!);
    }
    return now.isAfter(dataInizio) && now.isBefore(dataInizio.add(const Duration(hours: 24)));
  }

  /// Controlla se l'evento è terminato
  bool get isTerminato {
    final now = DateTime.now();
    if (dataFine != null) {
      return now.isAfter(dataFine!);
    }
    return now.isAfter(dataInizio.add(const Duration(hours: 24)));
  }

  /// Controlla se ci sono ancora posti disponibili
  bool get haPostiDisponibili {
    if (maxPartecipanti <= 0) return true;
    return partecipanti.length < maxPartecipanti;
  }

  /// Numero di posti rimanenti
  int get postiRimanenti {
    if (maxPartecipanti <= 0) return -1;
    return maxPartecipanti - partecipanti.length;
  }

  /// Getter per compatibilità con i fragment esistenti
  String get data => '${dataInizio.day}/${dataInizio.month}/${dataInizio.year}';
  String get ora => '${dataInizio.hour.toString().padLeft(2, '0')}:${dataInizio.minute.toString().padLeft(2, '0')}';

  /// Crea un Evento da una Map (da Firestore)
  factory Evento.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return Evento(
      id: documentId ?? map['id'] ?? '',
      nome: map['nome'] ?? '',
      descrizione: map['descrizione'] ?? '',
      dataInizio: _timestampToDateTime(map['dataInizio']),
      dataFine: map['dataFine'] != null ? _timestampToDateTime(map['dataFine']) : null,
      luogo: map['luogo'] ?? '',
      partecipanti: List<String>.from(map['partecipanti'] ?? []),
      organizzatore: map['organizzatore'] ?? '',
      maxPartecipanti: map['maxPartecipanti'] ?? 0,
      isPublico: map['isPublico'] ?? true,
      dataCreazione: _timestampToDateTime(map['dataCreazione']),
      immagine: map['immagine'],
      metadata: map['metadata'],
    );
  }

  /// Converte l'Evento in una Map per Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descrizione': descrizione,
      'dataInizio': Timestamp.fromDate(dataInizio),
      'dataFine': dataFine != null ? Timestamp.fromDate(dataFine!) : null,
      'luogo': luogo,
      'partecipanti': partecipanti,
      'organizzatore': organizzatore,
      'maxPartecipanti': maxPartecipanti,
      'isPublico': isPublico,
      'dataCreazione': Timestamp.fromDate(dataCreazione),
      'immagine': immagine,
      'metadata': metadata,
    };
  }

  /// Helper per convertire Timestamp in DateTime
  static DateTime _timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    try {
      if (timestamp is Timestamp) return timestamp.toDate();
      if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (timestamp is String) return DateTime.parse(timestamp);
    } catch (e) {
      print('Errore conversione timestamp: $e');
    }
    return DateTime.now();
  }

  /// Crea una copia dell'evento con alcuni campi modificati
  Evento copyWith({
    String? id,
    String? nome,
    String? descrizione,
    DateTime? dataInizio,
    DateTime? dataFine,
    String? luogo,
    List<String>? partecipanti,
    String? organizzatore,
    int? maxPartecipanti,
    bool? isPublico,
    DateTime? dataCreazione,
    String? immagine,
    Map<String, dynamic>? metadata,
  }) {
    return Evento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descrizione: descrizione ?? this.descrizione,
      dataInizio: dataInizio ?? this.dataInizio,
      dataFine: dataFine ?? this.dataFine,
      luogo: luogo ?? this.luogo,
      partecipanti: partecipanti ?? this.partecipanti,
      organizzatore: organizzatore ?? this.organizzatore,
      maxPartecipanti: maxPartecipanti ?? this.maxPartecipanti,
      isPublico: isPublico ?? this.isPublico,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      immagine: immagine ?? this.immagine,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Evento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Evento(id: $id, nome: $nome, dataInizio: $dataInizio, partecipanti: ${partecipanti.length})';
  }
}
