import 'package:flutter/material.dart';

class RicaricaScreen extends StatelessWidget {
  const RicaricaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ricarica Saldo Utente'),
      ),
      body: const Center(
        child: Text('Qui implementeremo lo scanner per la ricarica.'),
      ),
    );
  }
}