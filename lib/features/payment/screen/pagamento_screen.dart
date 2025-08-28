import 'package:flutter/material.dart';
import 'product_list_ordering_screen.dart'; // Creeremo dopo
import 'qr_code_screen.dart'; // Creeremo dopo

class PagamentoScreen extends StatelessWidget {
  const PagamentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const QrCodeScreen()),
                );
              },
              child: const Text('QR Code'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProductListForOrderingScreen()),
                );
              },
              child: const Text('Ordina'),
            ),
          ],
        ),
      ),
    );
  }
}