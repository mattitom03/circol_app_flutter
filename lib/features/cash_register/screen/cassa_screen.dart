import 'package:flutter/material.dart';
import 'ricarica_screen.dart'; // Creeremo questo dopo
import 'riscuoti_screen.dart'; // Creeremo questo dopo

class CassaScreen extends StatelessWidget {
  const CassaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cassa'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_card),
              label: const Text('Ricarica Saldo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RicaricaScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Riscuoti Pagamento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RiscuotiScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}