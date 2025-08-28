import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../auth/viewmodels/auth_viewmodel.dart';

class HomeFragment extends StatelessWidget {
  const HomeFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Accediamo al ViewModel per prendere i dati dell'utente
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final movimenti = authViewModel.movimenti; // Prendiamo la lista completa dei movimenti

    // 2. Prepariamo i formattatori per data e valuta
    final currencyFormatter = NumberFormat.currency(locale: 'it_IT', symbol: '€');
    final dateFormatter = DateFormat('dd MMMM yyyy', 'it_IT');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il Tuo Saldo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funzionalità non ancora implementata.'),
                  duration: Duration(seconds: 2), // Il messaggio scompare dopo 2 secondi
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => authViewModel.refreshAllData(),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Sezione Saldo ---
            Text(
              'Saldo:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              // Formattiamo il saldo come valuta
              currencyFormatter.format(user?.saldo ?? 0.0),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // --- Sezione Ultimi Movimenti ---
            Text(
              'Ultimi Movimenti',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),

            // Se non ci sono movimenti, mostra un messaggio
            if (movimenti.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Nessun movimento registrato.')),
              )
            else
            // Altrimenti, costruisci la lista
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movimenti.length,
                itemBuilder: (context, index) {
                  final movimento = movimenti[index];
                  final isNegative = movimento.importo < 0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(
                        isNegative ? Icons.shopping_cart : Icons.add_card,
                        color: isNegative ? Colors.red.shade300 : Colors.green.shade400,
                      ),
                      title: Text(movimento.descrizione),
                      subtitle: Text(dateFormatter.format(movimento.data)),
                      trailing: Text(
                        // Mostra il segno +/- e formatta la valuta
                        '${isNegative ? '' : '+ '}${currencyFormatter.format(movimento.importo)}',
                        style: TextStyle(
                          color: isNegative ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}