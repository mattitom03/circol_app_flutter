import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../auth/services/auth_service.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final ordini = authViewModel.orderHistory;
    final isLoading = authViewModel.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Ordini'),
      ),
      body: RefreshIndicator(
        onRefresh: () => authViewModel.refreshAllData(),
        child: Builder(
          builder: (context) {
            if (isLoading && ordini.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ordini.isEmpty) {
              return const Center(
                child: Text('Nessun ordine da visualizzare.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ordini.length,
              itemBuilder: (context, index) {
                final ordine = ordini[index];
                return _buildOrderCard(context, ordine, authViewModel);
              },
            );
          },
        ),
      ),
    );
  }

  // WIDGET CARD SEPARATO PER CHIAREZZA
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> ordine, AuthViewModel authViewModel) {
    // Estraiamo i dati dalla mappa
    final nomeProdotto = ordine['nomeProdotto'] ?? 'N/D';
    final stato = ordine['stato'] ?? 'sconosciuto';
    final uidUtente = ordine['uidUtente'] ?? '';
    final timestamp = ordine['timestamp'];
    final date = timestamp is Timestamp ? timestamp.toDate() : DateTime.now();
    final statoMinuscolo = stato.toString().toLowerCase();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (statoMinuscolo != 'completato') {
            _showCompletaOrdineDialog(context, ordine['id'], authViewModel);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Usiamo un FutureBuilder per caricare il nome dell'utente
              FutureBuilder<String>(
                future: AuthService().getUserNameById(uidUtente),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Utente: Caricamento...', style: TextStyle(fontWeight: FontWeight.bold));
                  }
                  final nomeUtente = snapshot.data ?? 'Utente Sconosciuto';
                  return Text('Utente: $nomeUtente', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
                },
              ),
              const Divider(height: 16),

              Text('Prodotto: $nomeProdotto'),
              const SizedBox(height: 8),
              Text('Stato: $stato', style: TextStyle(color: statoMinuscolo == 'completato' ? Colors.green : Colors.orange, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Text('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(date)}'),
            ],
          ),
        ),
      ),
    );
  }



  void _showCompletaOrdineDialog(BuildContext context, String orderId, AuthViewModel authViewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Elimina Ordine'),
          content: const Text('Sei sicuro di voler eliminare questo ordine? L\'azione è irreversibile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Stile per un'azione distruttiva
              ),
              onPressed: () {
                // Chiama il metodo per eliminare l'ordine
                authViewModel.eliminaOrdine(orderId)
                    .then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ordine eliminato!'), backgroundColor: Colors.green),
                  );
                }).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Errore: ${e.toString()}'), backgroundColor: Colors.red),
                  );
                });
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }
}