import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'feedback';

  /// Salva un nuovo documento di feedback su Firestore,
  /// includendo l'ID del documento stesso all'interno dei dati.
  Future<void> inviaFeedback(Map<String, dynamic> feedbackData) async {
    try {
      // 1. Crea un riferimento a un nuovo documento con un ID autogenerato
      final docRef = _firestore.collection(_collectionPath).doc();

      // 2. Aggiungi l'ID del documento ai dati che stiamo per salvare
      feedbackData['id'] = docRef.id;

      // 3. Salva la mappa completa di dati usando .set() sul riferimento
      await docRef.set(feedbackData);

      print('Feedback inviato con ID: ${docRef.id}');
    } catch (e) {
      print('Errore durante l\'invio del feedback: $e');
      rethrow;
    }
  }
}