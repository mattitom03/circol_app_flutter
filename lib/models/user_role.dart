/// Rappresenta i possibili ruoli utente nell'applicazione.
enum UserRole {
  /// Utente standard con permessi limitati.
  user,

  /// Utente amministratore con permessi elevati.
  admin,

  /// Ruolo sconosciuto o non ancora determinato.
  /// Utile come stato iniziale o per gestire casi imprevisti.
  unknown;

  /// Converte una stringa nel corrispondente UserRole.
  /// [roleString] La stringa del ruolo (es. "ADMIN", "USER")
  /// Ritorna il UserRole corrispondente, o unknown se non riconosciuto
  static UserRole fromString(String? roleString) {
    switch (roleString?.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'USER':
        return UserRole.user;
      default:
        return UserRole.unknown;
    }
  }

  /// Converte l'enum in stringa
  String toDisplayString() {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.user:
        return 'USER';
      case UserRole.unknown:
        return 'UNKNOWN';
    }
  }
}
