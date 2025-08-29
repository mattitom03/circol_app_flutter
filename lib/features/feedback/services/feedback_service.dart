import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'feedback';

  /// Recupera tutti i feedback dal database, ordinati per data.
  Future<List<Map<String, dynamic>>> getTuttiFeedback() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('timestamp', descending: true)
          .get();

      // Ritorna la lista di feedback, aggiungendo l'ID a ogni mappa
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // L'ID ci servirà per aggiornare lo stato
        return data;
      }).toList();
    } catch (e) {
      print('Errore nel caricamento dei feedback: $e');
      return [];
    }
  }

  /// Imposta lo stato 'letto' di un feedback a true.
  Future<void> segnaComeLetto(String feedbackId) async {
    try {
      await _firestore.collection(_collectionPath).doc(feedbackId).update({
        'letto': true,
      });
    } catch (e) {
      print('Errore nell\'aggiornare lo stato del feedback: $e');
      rethrow;
    }
  }

  /// Invia un nuovo documento di feedback (questo lo avevamo già).
  Future<void> inviaFeedback(Map<String, dynamic> feedbackData) async {
    try {
      await _firestore.collection(_collectionPath).add(feedbackData);
    } catch (e) {
      print('Errore durante l\'invio del feedback: $e');
      rethrow;
    }
  }
}