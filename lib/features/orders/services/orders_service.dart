import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'ordinazioni';

  /// Elimina un ordine dal database.
  Future<void> eliminaOrdine(String orderId) async {
    try {
      await _firestore.collection(_collectionPath).doc(orderId).delete();
      print('Ordine $orderId eliminato con successo.');
    } catch (e) {
      print('Errore durante l\'eliminazione dell\'ordine: $e');
      rethrow;
    }
  }
}