import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/movimento.dart';

class MovimentiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Recupera tutti i movimenti di un utente (versione semplificata)
  Future<List<Movimento>> getMovimentiUtente(String userId) async {
    try {
      print('Caricamento movimenti per utente: $userId');
      // Uso una query semplice senza orderBy per evitare indici
      final querySnapshot = await _firestore
          .collection('movimenti')
          .where('userId', isEqualTo: userId)
          .get(); // Rimuovo orderBy

      final movimenti = querySnapshot.docs
          .map((doc) => Movimento.fromMap(doc.data()))
          .toList();

      // Ordino in memoria per data
      movimenti.sort((a, b) => b.data.compareTo(a.data));

      print('Caricati ${movimenti.length} movimenti');
      return movimenti;
    } catch (e) {
      print('Errore nel caricamento movimenti: $e');
      return [];
    }
  }

  /// Aggiunge un nuovo movimento
  Future<bool> addMovimento(Movimento movimento, String userId) async {
    try {
      final movimentoData = movimento.toMap();
      movimentoData['userId'] = userId; // Aggiungi l'ID utente

      await _firestore.collection('movimenti').add(movimentoData);
      print('Movimento aggiunto: ${movimento.descrizione}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiunta movimento: $e');
      return false;
    }
  }

  /// Recupera gli ultimi movimenti di un utente
  Future<List<Movimento>> getUltimiMovimenti(String userId, {int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection('movimenti')
          .where('userId', isEqualTo: userId)
          .orderBy('data', descending: true)
          .limit(limit)
          .get();

      final movimenti = querySnapshot.docs
          .map((doc) => Movimento.fromMap(doc.data()))
          .toList();

      return movimenti;
    } catch (e) {
      print('Errore nel caricamento ultimi movimenti: $e');
      return [];
    }
  }

  /// Calcola il saldo totale dai movimenti
  Future<double> calcolaSaldo(String userId) async {
    try {
      final movimenti = await getMovimentiUtente(userId);
      double saldo = 0.0;

      for (final movimento in movimenti) {
        saldo += movimento.importo;
      }

      return saldo;
    } catch (e) {
      print('Errore nel calcolo saldo: $e');
      return 0.0;
    }
  }

  /// Stream per movimenti in tempo reale
  Stream<List<Movimento>> getMovimentiStream(String userId) {
    return _firestore
        .collection('movimenti')
        .where('userId', isEqualTo: userId)
        .orderBy('data', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Movimento.fromMap(doc.data()))
            .toList());
  }
  /// Aggiunge un nuovo movimento di ricarica.
  Future<void> addMovimentoRicarica(String userId, double importo) async {
    try {
      await _firestore.collection('movimenti').add({
        'userId': userId,
        'importo': importo,
        'descrizione': 'Ricarica Saldo',
        'tipo': 'ricarica',
        'data': FieldValue.serverTimestamp(), // Data e ora attuali
      });
    } catch (e) {
      print('Errore nell\'aggiunta del movimento di ricarica: $e');
      rethrow;
    }
  }

}
