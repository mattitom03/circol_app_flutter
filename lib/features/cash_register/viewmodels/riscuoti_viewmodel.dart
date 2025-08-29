import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/models/product.dart';
import '../../../core/models/movimento.dart';
import '../../movements/services/movimenti_service.dart';
import '../../products/services/product_service.dart';

class RiscuotiViewModel extends ChangeNotifier {
  User? _selectedUser;

  User? get selectedUser => _selectedUser;

  final List<Product> _scannedProducts = [];

  List<Product> get scannedProducts => _scannedProducts;

  double get total {
    double currentTotal = 0.0;
    for (var product in _scannedProducts) {
      currentTotal += product.prezzo;
    }
    return currentTotal;
  }

  void setUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }

  void addProduct(Product product) {
    _scannedProducts.add(product);
    notifyListeners();
  }

  /// Pulisce lo stato del carrello per una nuova transazione.
  void clearCart() {
    _selectedUser = null;
    _scannedProducts.clear();
    notifyListeners();
  }

  /// Finalizza la transazione
  Future<void> finalizeTransaction() async {
    if (_selectedUser == null || _scannedProducts.isEmpty) {
      throw Exception('Seleziona un utente e almeno un prodotto.');
    }

    final descrizioneMovimento = _scannedProducts.map((p) => p.nome).join(', ');
    final nuovoMovimento = Movimento(
      id: '',
      importo: -total,
      descrizione: 'Acquisto: $descrizioneMovimento',
      data: DateTime.now(),
      tipo: 'pagamento',
      userId: _selectedUser!.uid,
    );

    final Map<Product, int> itemsSold = {};
    for (var product in _scannedProducts) {
      itemsSold.update(product, (value) => value + 1, ifAbsent: () => 1);
    }

    final movimentiService = MovimentiService();
    final productService = ProductService();

    // Ora passiamo entrambi i parametri richiesti dal service: l'ID dell'utente e il movimento.
    await movimentiService.addMovimento(_selectedUser!.uid, nuovoMovimento);
    await productService.updateMultipleProductsStock(itemsSold);

    print('Transazione finalizzata con successo!');

    clearCart(); // Pulisce il carrello
  }
}