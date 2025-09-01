import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/movimento.dart';

class MovimentiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Recupera gli ultimi movimenti dalla sottocollezione di un utente specifico.
  Future<List<Movimento>> getMovimentiUtente(String userId) async {
    try {
      if (userId.isEmpty) return [];

      print('Caricamento movimenti per utente: $userId dalla sua sottocollezione');

      final querySnapshot = await _firestore
          .collection('utenti')
          .doc(userId)
          .collection('movimenti')
          .orderBy('data', descending: true)
          .limit(20)
          .get();

      print('Caricati ${querySnapshot.docs.length} movimenti per l\'utente.');

      return querySnapshot.docs
          .map((doc) => Movimento.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      print('Errore nel caricamento dei movimenti per l\'utente: $e');
      return [];
    }
  }

  /// Aggiunge un nuovo movimento nella sottocollezione dell'utente.
  Future<void> addMovimento(String userId, Movimento movimento) async {
    try {
      await _firestore
          .collection('utenti')
          .doc(userId)
          .collection('movimenti')
          .add(movimento.toMap());
      print('Movimento aggiunto per l\'utente $userId');
    } catch (e) {
      print('Errore nell\'aggiunta movimento: $e');
      rethrow;
    }
  }
}