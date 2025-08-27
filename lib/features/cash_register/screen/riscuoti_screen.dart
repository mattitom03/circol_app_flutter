import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/riscuoti_viewmodel.dart';
import 'scanner_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../products/services/product_service.dart';
import '../../../core/models/user.dart';
import '../../../core/models/product.dart';

class RiscuotiScreen extends StatelessWidget {
  const RiscuotiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RiscuotiViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riscuoti Pagamento'),
          actions: [
            Consumer<RiscuotiViewModel>(
              builder: (context, viewModel, child) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Svuota Carrello',
                  onPressed: viewModel.clearCart,
                );
              },
            ),
          ],
        ),
        body: Consumer<RiscuotiViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Sezione Utente ---
                  const Text('Utente:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  if (viewModel.selectedUser != null)
                    Text(
                      viewModel.selectedUser!.nome,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    )
                  else
                    const Text(
                      'Nessun utente selezionato',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    // 🔥 LOGICA IMPLEMENTATA QUI 🔥
                    onPressed: () => _scanUser(context),
                    child: const Text('Scansiona Utente'),
                  ),
                  const SizedBox(height: 40),

                  // --- Sezione Prodotti ---
                  const Text('Prodotti:', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade700),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: viewModel.scannedProducts.isEmpty
                          ? const Center(child: Text('Nessun prodotto scansionato.'))
                          : ListView.builder(
                        itemCount: viewModel.scannedProducts.length,
                        itemBuilder: (context, index) {
                          final product = viewModel.scannedProducts[index];
                          return ListTile(
                            title: Text(product.nome),
                            trailing: Text('€ ${product.prezzo.toStringAsFixed(2)}'),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _scanProduct(context),
                    child: const Text('Scansiona Prodotto'),
                  ),
                  const SizedBox(height: 40),

                  // --- Sezione Totale e Fine ---
                  Text(
                    'Totale: € ${viewModel.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      viewModel.finalizeTransaction().then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transazione completata con successo!')),
                        );
                      }).catchError((e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                        );
                      });
                    },
                    child: const Text('Fine', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- FUNZIONI HELPER CON LA LOGICA DI SCANSIONE ---

Future<void> _scanUser(BuildContext context) async {
  final viewModel = context.read<RiscuotiViewModel>();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final scannedUid = await navigator.push<String>(
    MaterialPageRoute(builder: (context) => const ScannerScreen()),
  );

  if (!context.mounted) return;

  if (scannedUid != null) {
    final user = await AuthService().getUserById(scannedUid);
    if (user != null) {
      viewModel.setUser(user);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Utente non trovato!'), backgroundColor: Colors.red),
      );
    }
  }
}

Future<void> _scanProduct(BuildContext context) async {
  final viewModel = context.read<RiscuotiViewModel>();
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final scannedProductId = await navigator.push<String>(
    MaterialPageRoute(builder: (context) => const ScannerScreen()),
  );

  if (!context.mounted) return;

  if (scannedProductId != null) {
    final product = await ProductService().getProductById(scannedProductId);
    if (product != null) {
      viewModel.addProduct(product);
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('Prodotto non trovato!'), backgroundColor: Colors.red),
      );
    }
  }
}