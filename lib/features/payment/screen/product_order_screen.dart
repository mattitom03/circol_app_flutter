import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/product.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

class ProductOrderScreen extends StatefulWidget {
  final Product prodotto;
  const ProductOrderScreen({super.key, required this.prodotto});

  @override
  State<ProductOrderScreen> createState() => _ProductOrderScreenState();
}

class _ProductOrderScreenState extends State<ProductOrderScreen> {
  final _richiesteController = TextEditingController();

  @override
  void dispose() {
    _richiesteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prodotto.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '€ ${widget.prodotto.prezzo.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.green),
            ),
            const SizedBox(height: 16),
            Text('Descrizione:', style: Theme.of(context).textTheme.titleMedium),
            Text(widget.prodotto.descrizione),
            const SizedBox(height: 24),
            TextField(
              controller: _richiesteController,
              decoration: const InputDecoration(
                labelText: 'Richieste aggiuntive (opzionale)',
                hintText: 'Es: Senza zucchero, extra caldo, ecc...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Spacer(), // Usa lo spazio rimanente
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                context.read<AuthViewModel>().creaNuovoOrdine(
                  prodotto: widget.prodotto,
                  richiesteAggiuntive: _richiesteController.text,
                ).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ordine inviato!'), backgroundColor: Colors.green),
                  );
                  // Torna indietro di 2 schermate alla pagina di Pagamento principale
                  Navigator.of(context).popUntil((route) => route.isFirst);
                });
              },
              child: const Text('Ordina Prodotto', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}