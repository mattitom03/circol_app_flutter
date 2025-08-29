import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/models/user.dart';
import '../admin_panel/screen/gestione_tessere_screen.dart';
class ProfiloFragment extends StatelessWidget {
  const ProfiloFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.displayName ?? 'Profilo'),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // --- Sezione Intestazione Profilo ---
          const Icon(Icons.account_circle, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Telefono: ${user.telefono ?? 'Non disponibile'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Ruolo: ${authViewModel.isAdmin ? 'Amministratore' : 'Utente'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 32),

          // --- Sezione Informazioni Account ---
          _buildInfoCard(context, user),
          const SizedBox(height: 24),

          // --- Sezione Azioni (condizionale in base al ruolo) ---
          if (authViewModel.isAdmin)
            _buildAdminActionsCard(context) // Card per l'admin
          else
            _buildUserActionsCard(context), // Card per l'utente normale

          const SizedBox(height: 24),

          // --- Pulsante di Logout ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<AuthViewModel>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// --- FUNZIONI E WIDGET HELPER (FUORI DALLA CLASSE) ---

/// Costruisce la card con le informazioni dell'account (Saldo e Tessera).
Widget _buildInfoCard(BuildContext context, User user) {
  final currencyFormatter = NumberFormat.currency(locale: 'it_IT', symbol: '€');

  final String statoTessera;
  final Color coloreStatoTessera;

  if (user.hasTessera) {
    statoTessera = 'Attiva';
    coloreStatoTessera = Colors.green;
  } else if (user.richiestaRinnovoInCorso) {
    statoTessera = 'Richiesta in attesa';
    coloreStatoTessera = Colors.orange;
  } else {
    statoTessera = 'Non attiva';
    coloreStatoTessera = Colors.red;
  }

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informazioni Account', style: Theme.of(context).textTheme.titleLarge),
          const Divider(height: 24),
          _buildInfoRow(Icons.account_balance_wallet, 'Saldo:', currencyFormatter.format(user.saldo)),
          _buildInfoRow(Icons.credit_card, 'Tessera:', statoTessera, valueColor: coloreStatoTessera),
        ],
      ),
    ),
  );
}

/// Costruisce la card con le azioni per l'UTENTE NORMALE.
Widget _buildUserActionsCard(BuildContext context) {
  final user = context.read<AuthViewModel>().currentUser;
  if (user == null) return const SizedBox.shrink();

  return Card(
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text('Richiedi Tessera'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            if (user.richiestaRinnovoInCorso) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hai già una richiesta in attesa.'),
                  backgroundColor: Colors.orange,
                ),
              );
            } else if (user.hasTessera) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Hai già una tessera attiva.')),
              );
            } else {
              _showRichiediTesseraDialog(context);
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.feedback_outlined),
          title: const Text('Invia Feedback'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showFeedbackDialog(context),
        ),
      ],
    ),
  );
}

/// Costruisce la card con le azioni per l'ADMIN.
Widget _buildAdminActionsCard(BuildContext context) {
  return Card(
    child: Column(
      children: [
        ListTile(
          leading: const Icon(Icons.manage_accounts),
          title: const Text('Gestisci Tessere Utenti'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const GestioneTessereScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.reviews_outlined),
          title: const Text('Visualizza Feedback Ricevuti'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // Logica da implementare in futuro
            print('Pulsante "Visualizza Feedback" premuto.');
          },
        ),
      ],
    ),
  );
}

/// Costruisce una singola riga di informazioni (Icona, Etichetta, Valore).
Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    ),
  );
}

/// Mostra il dialogo per richiedere una nuova tessera.
void _showRichiediTesseraDialog(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();
  final user = authViewModel.currentUser;
  const double costoTessera = 3.0;

  if (user == null) return;

  final saldoAttuale = user.saldo;
  final saldoDopo = saldoAttuale - costoTessera;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Richiedi Tessera Socio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vuoi richiedere una nuova tessera?'),
            const SizedBox(height: 16),
            Text('Costo: ${costoTessera.toStringAsFixed(2)} €'),
            const Divider(height: 16),
            Text('Saldo attuale: ${saldoAttuale.toStringAsFixed(2)} €'),
            Text(
              'Saldo dopo il pagamento: ${saldoDopo.toStringAsFixed(2)} €',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: saldoDopo < 0 ? Colors.red : Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (saldoAttuale < costoTessera) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saldo insufficiente!'), backgroundColor: Colors.red),
                );
                Navigator.of(dialogContext).pop();
                return;
              }

              authViewModel.richiediTessera().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Richiesta inviata con successo!'), backgroundColor: Colors.green),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Errore: ${e.toString()}'), backgroundColor: Colors.red),
                );
              });

              Navigator.of(dialogContext).pop();
            },
            child: const Text('Conferma Pagamento'),
          ),
        ],
      );
    },
  );
}

/// Mostra il dialogo per inviare un feedback.
void _showFeedbackDialog(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();
  final formKey = GlobalKey<FormState>();
  final titoloController = TextEditingController();
  final messaggioController = TextEditingController();
  String selectedCategory = 'GENERALE';

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Invia il tuo feedback'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: ['GENERALE', 'TECNICO', 'SUGGERIMENTO']
                          .map((label) => DropdownMenuItem(child: Text(label), value: label))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedCategory = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: titoloController,
                      decoration: const InputDecoration(labelText: 'Titolo', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'Il titolo non può essere vuoto' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: messaggioController,
                      decoration: const InputDecoration(labelText: 'Messaggio', border: OutlineInputBorder()),
                      maxLines: 4,
                      validator: (value) => value!.isEmpty ? 'Il messaggio non può essere vuoto' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Annulla'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    authViewModel.inviaFeedback(
                      categoria: selectedCategory,
                      titolo: titoloController.text,
                      messaggio: messaggioController.text,
                    ).then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Feedback inviato con successo!'), backgroundColor: Colors.green),
                      );
                      Navigator.of(dialogContext).pop();
                    }).catchError((e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Errore: ${e.toString()}'), backgroundColor: Colors.red),
                      );
                    });
                  }
                },
                child: const Text('Invia'),
              ),
            ],
          );
        },
      );
    },
  );
}