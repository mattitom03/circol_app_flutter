import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Recupera tutti i prodotti disponibili (versione semplificata)
  Future<List<Product>> getAllProducts() async {
    try {
      print('Caricamento prodotti da Firestore...');
      // Rimuovo orderBy e where che richiedono indici composti
      final querySnapshot = await _firestore
          .collection('products')
          .get(); // Query semplice senza filtri o ordinamenti

      final products = querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .where((product) => product.ordinabile) // Filtro in memoria
          .toList();

      // Ordino in memoria per nome
      products.sort((a, b) => a.nome.compareTo(b.nome));

      print('Caricati ${products.length} prodotti');
      return products;
    } catch (e) {
      print('Errore nel caricamento prodotti: $e');
      return [];
    }
  }

  /// Recupera prodotti per categoria
  Future<List<Product>> getProductsByCategory(String categoria) async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('categoria', isEqualTo: categoria)
          .where('ordinabile', isEqualTo: true)
          .orderBy('nome')
          .get();

      return querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
          .toList();
    } catch (e) {
      print('Errore nel caricamento prodotti per categoria: $e');
      return [];
    }
  }

  /// Aggiunge un nuovo prodotto (solo admin)
  Future<bool> addProduct(Product product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
      print('Prodotto aggiunto: ${product.nome}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiunta prodotto: $e');
      return false;
    }
  }

  /// Aggiorna un prodotto esistente
  Future<bool> updateProduct(Product product) async {
    try {
      await _firestore
          .collection('products')
          .doc(product.id)
          .update(product.toMap());
      print('Prodotto aggiornato: ${product.nome}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiornamento prodotto: $e');
      return false;
    }
  }

  /// Aggiorna la quantità di un prodotto
  Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'numeroPezzi': newQuantity,
        'dataAggiornamento': DateTime.now().millisecondsSinceEpoch,
      });
      print('Quantità aggiornata per prodotto: $productId');
      return true;
    } catch (e) {
      print('Errore nell\'aggiornamento quantità: $e');
      return false;
    }
  }

  /// Stream per prodotti in tempo reale
  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .where('ordinabile', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }
}
