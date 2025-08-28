import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'product_order_screen.dart'; // Creeremo subito dopo

class ProductListForOrderingScreen extends StatelessWidget {
  const ProductListForOrderingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    // Usiamo il getter che avevamo creato per i soli prodotti ordinabili
    final prodotti = authViewModel.prodottiOrdinabili;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scegli un Prodotto'),
      ),
      body: ListView.builder(
        itemCount: prodotti.length,
        itemBuilder: (context, index) {
          final prodotto = prodotti[index];
          return ListTile(
            title: Text(prodotto.nome),
            subtitle: Text(prodotto.descrizione),
            trailing: Text('€ ${prodotto.prezzo.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductOrderScreen(prodotto: prodotto),
                ),
              );
            },
          );
        },
      ),
    );
  }
}