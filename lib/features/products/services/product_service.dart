import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/product.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'prodotti'; // Nome della tua collezione prodotti

  /// Recupera tutti i prodotti disponibili (versione semplificata)
  Future<List<Product>> getAllProducts() async {
    try {
      print('Caricamento prodotti da Firestore...');
      final querySnapshot = await _firestore
          .collection(_collectionPath)
          .get(); // Query semplice senza filtri o ordinamenti

      final products = querySnapshot.docs
          .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
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
          .collection(_collectionPath)
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

  /// Aggiunge un nuovo prodotto usando il suo ID personalizzato.
  Future<bool> addProduct(Product product) async {
    try {
      // Usiamo .doc(product.id).set(...)
      // Questo crea un documento con l'ID esatto che specifichi tu.
      await _firestore.collection(_collectionPath).doc(product.id).set(product.toMap());
      print('Prodotto aggiunto con ID: ${product.id}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiunta prodotto: $e');
      return false;
    }
  }

  /// Aggiorna un prodotto esistente
  Future<bool> updateProduct(Product product) async {
    try {
      // L'ID del prodotto è già il nome
      await _firestore
          .collection(_collectionPath)
          .doc(product.id)
          .update(product.toMap());
      print('Prodotto aggiornato: ${product.nome}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiornamento prodotto: $e');
      rethrow;
    }
  }

  /// Aggiorna la quantità di un prodotto
  Future<bool> updateQuantity(String productId, int newQuantity) async {
    try {
      await _firestore.collection(_collectionPath).doc(productId).update({
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
        .collection(_collectionPath)
        .where('ordinabile', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data(), documentId: doc.id))
            .toList());
  }

  /// Carica un'immagine su Firebase Storage e ritorna il suo URL di download.
  Future<String> uploadProductImage(File imageFile, String productId) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('prodotti_imageUrl')
          .child('$productId.jpg');

      await ref.putFile(imageFile);

      final downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } on FirebaseException catch (e) {
      print("Errore durante l'upload dell'immagine: $e");
      throw Exception("Errore nel caricamento dell'immagine.");
    }
  }

  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(productId).get();
      if (doc.exists) {
        return Product.fromMap(doc.data()!, documentId: doc.id);
      }
      return null;
    } catch (e) {
      print('Errore nel recuperare prodotto by ID: $e');
      return null;
    }
  }

  /// Aggiorna la quantità di più prodotti in un'unica operazione sicura (batch).
  Future<void> updateMultipleProductsStock(Map<Product, int> itemsSold) async {
    final batch = _firestore.batch();

    itemsSold.forEach((product, quantitySold) {
      final docRef = _firestore.collection(_collectionPath).doc(product.id);
      final newStock = product.numeroPezzi - quantitySold;

      // Assicurati che lo stock non vada in negativo
      batch.update(docRef, {'numeroPezzi': (newStock < 0) ? 0 : newStock});
    });

    await batch.commit();
  }

  /// Elimina un prodotto dal database.
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection(_collectionPath).doc(productId).delete();
      print('Prodotto $productId eliminato con successo.');
    } catch (e) {
      print('Errore durante l\'eliminazione del prodotto: $e');
      rethrow;
    }
  }
}
