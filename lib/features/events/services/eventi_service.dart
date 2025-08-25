import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/evento.dart';

class EventiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Recupera tutti gli eventi
  Future<List<Evento>> getAllEventi() async {
    try {
      print('Caricamento eventi da Firestore...');
      final querySnapshot = await _firestore
          .collection('eventi')
          .get(); // Rimuovo orderBy che richiede indice

      final eventi = querySnapshot.docs
          .map((doc) => Evento.fromMap(doc.data(), documentId: doc.id))
          .toList();

      print('Caricati ${eventi.length} eventi');
      return eventi;
    } catch (e) {
      print('Errore nel caricamento eventi: $e');
      return [];
    }
  }

  /// Recupera eventi a cui partecipa un utente (versione semplificata)
  Future<List<Evento>> getEventiPerUtente(String userId) async {
    try {
      print('Caricamento eventi per utente: $userId');
      // Per ora carico tutti gli eventi e filtro in memoria
      final tuttiEventi = await getAllEventi();
      final eventiUtente = tuttiEventi.where((evento) =>
          evento.partecipanti.contains(userId)).toList();

      print('Caricati ${eventiUtente.length} eventi per l\'utente');
      return eventiUtente;
    } catch (e) {
      print('Errore nel caricamento eventi per utente: $e');
      return [];
    }
  }

  /// Aggiunge un nuovo evento
  Future<bool> addEvento(Evento evento) async {
    try {
      await _firestore.collection('eventi').add(evento.toMap());
      print('Evento aggiunto: ${evento.nome}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiunta evento: $e');
      return false;
    }
  }

  /// Aggiorna un evento
  Future<bool> updateEvento(Evento evento) async {
    try {
      await _firestore
          .collection('eventi')
          .doc(evento.id)
          .update(evento.toMap());
      print('Evento aggiornato: ${evento.nome}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiornamento evento: $e');
      return false;
    }
  }

  /// Partecipa a un evento
  Future<bool> partecipaEvento(String eventoId, String userId) async {
    try {
      await _firestore.collection('eventi').doc(eventoId).update({
        'partecipanti': FieldValue.arrayUnion([userId])
      });
      print('Utente $userId aggiunto all\'evento $eventoId');
      return true;
    } catch (e) {
      print('Errore nella partecipazione all\'evento: $e');
      return false;
    }
  }

  /// Rimuove partecipazione a un evento
  Future<bool> rimuoviPartecipazione(String eventoId, String userId) async {
    try {
      await _firestore.collection('eventi').doc(eventoId).update({
        'partecipanti': FieldValue.arrayRemove([userId])
      });
      print('Utente $userId rimosso dall\'evento $eventoId');
      return true;
    } catch (e) {
      print('Errore nella rimozione partecipazione: $e');
      return false;
    }
  }

  /// Stream per eventi in tempo reale
  Stream<List<Evento>> getEventiStream() {
    return _firestore
        .collection('eventi')
        .orderBy('dataCreazione', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Evento.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }
}
