import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: caricare e mostrare lista ordini.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Ordini'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Qui verranno visualizzati gli ordini.',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}