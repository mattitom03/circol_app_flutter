import 'user_role.dart';
import 'movimento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


/// Modello dati per rappresentare un utente dell'applicazione
class User {
  final String uid;
  final String username;
  final String nome;
  final String email;
  final String displayName;
  final UserRole ruolo;
  final double saldo;
  final List<Movimento> movimenti;
  final String? photoUrl;
  final bool hasTessera;
  final String? numeroTessera;
  final DateTime? dataScadenzaTessera;
  final bool richiestaRinnovoInCorso;

  const User({
    this.uid = '',
    this.username = '',
    this.nome = '',
    this.email = '',
    this.displayName = '',
    this.ruolo = UserRole.user,
    this.saldo = 0.0,
    this.movimenti = const [],
    this.photoUrl,
    this.hasTessera = false,
    this.numeroTessera,
    this.dataScadenzaTessera,
    this.richiestaRinnovoInCorso = false,
  });

  /// Crea un User da un Map (es. da Firebase/JSON)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      ruolo: UserRole.fromString(map['ruolo']),
      saldo: (map['saldo'] ?? 0.0).toDouble(),
      movimenti: (map['movimenti'] as List<dynamic>?)
          ?.map((m) => Movimento.fromMap(m))
          .toList() ?? [],
      photoUrl: map['photoUrl'],
      hasTessera: map['hasTessera'] ?? false,
      numeroTessera: map['numeroTessera'],
      dataScadenzaTessera: (map['dataScadenzaTessera'] as Timestamp?)?.toDate(),
      richiestaRinnovoInCorso: map['richiestaRinnovoInCorso'] ?? false,
    );
  }

  /// Converte il User in un Map per il salvataggio
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'nome': nome,
      'email': email,
      'displayName': displayName,
      'ruolo': ruolo.toDisplayString(),
      'saldo': saldo,
      'movimenti': movimenti.map((m) => m.toMap()).toList(),
      'photoUrl': photoUrl,
      'hasTessera': hasTessera,
      'numeroTessera': numeroTessera,
      'dataScadenzaTessera': dataScadenzaTessera?.millisecondsSinceEpoch,
      'richiestaRinnovoInCorso': richiestaRinnovoInCorso,
    };
  }

  /// Crea una copia del User con i campi modificati
  User copyWith({
    String? uid,
    String? username,
    String? nome,
    String? email,
    String? displayName,
    UserRole? ruolo,
    double? saldo,
    List<Movimento>? movimenti,
    String? photoUrl,
    bool? hasTessera,
    String? numeroTessera,
    DateTime? dataScadenzaTessera,
    bool? richiestaRinnovoInCorso,
  }) {
    return User(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      ruolo: ruolo ?? this.ruolo,
      saldo: saldo ?? this.saldo,
      movimenti: movimenti ?? this.movimenti,
      photoUrl: photoUrl ?? this.photoUrl,
      hasTessera: hasTessera ?? this.hasTessera,
      numeroTessera: numeroTessera ?? this.numeroTessera,
      dataScadenzaTessera: dataScadenzaTessera ?? this.dataScadenzaTessera,
      richiestaRinnovoInCorso: richiestaRinnovoInCorso ?? this.richiestaRinnovoInCorso,
    );
  }

  @override
  String toString() {
    return 'User(uid: $uid, username: $username, nome: $nome, email: $email, ruolo: $ruolo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
