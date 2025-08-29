import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/evento.dart';
import '../../../core/models/user.dart';

class EventiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'eventi';

  /// Recupera tutti gli eventi.
  Future<List<Evento>> getAllEventi() async {
    try {
      final querySnapshot = await _firestore.collection(_collectionPath).get();
      return querySnapshot.docs
          .map((doc) => Evento.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      print('Errore nel caricamento eventi: $e');
      return [];
    }
  }

  /// Iscrive un utente a un evento creando un documento nella sottocollezione 'partecipanti'.
  /// Accetta l'intero oggetto User per salvare nome e email.
  Future<void> partecipaEvento(String eventId, User user) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(eventId)
          .collection('partecipanti')
          .doc(user.uid)
          .set({
        'nome': user.displayName,
        'email': user.email,
        'dataIscrizione': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Errore nella partecipazione all\'evento: $e');
      rethrow;
    }
  }

  /// Recupera la lista dei partecipanti per un dato evento (per la schermata admin).
  Future<List<Map<String, dynamic>>> getPartecipanti(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .doc(eventId)
          .collection('partecipanti')
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Errore nel recuperare i partecipanti: $e');
      return [];
    }
  }

  /// Controlla se un utente sta già partecipando a un evento.
  /// Ritorna 'true' se il documento del partecipante esiste, altrimenti 'false'.
  Future<bool> checkPartecipazione(String eventId, String userId) async {
    try {
      final doc = await _firestore
          .collection(_collectionPath)
          .doc(eventId)
          .collection('partecipanti')
          .doc(userId)
          .get();
      return doc.exists; // Se il documento esiste, l'utente partecipa
    } catch (e) {
      print('Errore nel controllo partecipazione: $e');
      return false;
    }
  }

  /// Annulla la partecipazione di un utente da un evento.
  Future<void> annullaPartecipazione(String eventId, String userId) async {
    try {
      await _firestore
          .collection(_collectionPath)
          .doc(eventId)
          .collection('partecipanti')
          .doc(userId)
          .delete(); // Elimina il documento del partecipante
      print('Partecipazione annullata per l-utente $userId all-evento $eventId');
    } catch (e) {
      print('Errore nell\'annullamento partecipazione: $e');
      rethrow;
    }
  }
}
