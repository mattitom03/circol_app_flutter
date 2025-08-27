import 'package:flutter/material.dart';

class RiscuotiScreen extends StatelessWidget {
  const RiscuotiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riscuoti Pagamento'),
      ),
      body: const Center(
        child: Text('Qui implementeremo la cassa per la vendita.'),
      ),
    );
  }
}