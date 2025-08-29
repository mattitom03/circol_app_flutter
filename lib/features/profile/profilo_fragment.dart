import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Per formattare il saldo
import '../auth/viewmodels/auth_viewmodel.dart';

class ProfiloFragment extends StatelessWidget {
  const ProfiloFragment({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Accediamo al ViewModel per prendere i dati dell'utente loggato
    final authViewModel = context.watch<AuthViewModel>();
    final user = authViewModel.currentUser;
    final currencyFormatter = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilo'),
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
          Text(
            'Telefono: ${user.telefono ?? 'Non disponibile'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (authViewModel.isAdmin)
            Chip(
              label: const Text('ADMIN'),
              backgroundColor: Colors.orange.shade100,
              labelStyle: TextStyle(color: Colors.orange.shade800),
            ),
          const SizedBox(height: 32),

          // --- Sezione Informazioni Account ---
          _buildInfoCard(context, [
            _buildInfoRow(Icons.email, 'Email:', user.email),
            _buildInfoRow(Icons.account_balance_wallet, 'Saldo:', currencyFormatter.format(user.saldo)),
            Builder(
              builder: (context) {
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

                return _buildInfoRow(
                  Icons.credit_card,
                  'Tessera:',
                  statoTessera,
                  valueColor: coloreStatoTessera,
                );
              },
            ),
          ]),
          const SizedBox(height: 24),

          // --- Sezione Azioni ---
          _buildActionsCard(context, [
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: const Text('Richiedi Tessera'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Controlla lo stato dell'utente prima di decidere cosa fare
                if (user.richiestaRinnovoInCorso) {
                  // Se c'è già una richiesta, mostra un messaggio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hai già una richiesta in attesa.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (user.hasTessera) {
                  // Se ha già la tessera, mostra un altro messaggio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Hai già una tessera attiva.'),
                    ),
                  );
                } else {
                  // Altrimenti, apri il dialogo per la richiesta
                  _showRichiediTesseraDialog(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Invia Feedback'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Chiama la nuova funzione che crea il dialogo
                _showFeedbackDialog(context);
              },
            ),
          ]),
          const SizedBox(height: 24),

          // --- Pulsante di Logout ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Logica di Logout (funzionante)
              context.read<AuthViewModel>().logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Widget helper per creare le card
  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informazioni Account', style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Azioni', style: Theme.of(context).textTheme.titleLarge),
          ),
          ...children,
        ],
      ),
    );
  }

  // Widget helper per creare le righe di informazioni
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

}

void _showRichiediTesseraDialog(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();
  final user = authViewModel.currentUser;
  const double costoTessera = 3.0;

  if (user == null) return; // Sicurezza

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
              // Controlla di nuovo il saldo prima di procedere
              if (saldoAttuale < costoTessera) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saldo insufficiente!'), backgroundColor: Colors.red),
                );
                Navigator.of(dialogContext).pop();
                return;
              }

              // Chiama la funzione del ViewModel per eseguire l'operazione
              authViewModel.richiediTessera()
                  .then((_) {
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

//mostra feedback
void _showFeedbackDialog(BuildContext context) {
  final authViewModel = context.read<AuthViewModel>();
  final _formKey = GlobalKey<FormState>();
  final _titoloController = TextEditingController();
  final _messaggioController = TextEditingController();
  String _selectedCategory = 'GENERALE'; // Valore iniziale

  showDialog(
    context: context,
    builder: (dialogContext) {
      // Usiamo StatefulBuilder per gestire lo stato del dropdown
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Invia il tuo feedback'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Dropdown per la categoria
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: ['GENERALE', 'TECNICO', 'SUGGERIMENTO']
                          .map((label) => DropdownMenuItem(
                        child: Text(label),
                        value: label,
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo per il titolo
                    TextFormField(
                      controller: _titoloController,
                      decoration: const InputDecoration(
                        labelText: 'Titolo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Il titolo non può essere vuoto' : null,
                    ),
                    const SizedBox(height: 16),
                    // Campo per il messaggio
                    TextFormField(
                      controller: _messaggioController,
                      decoration: const InputDecoration(
                        labelText: 'Messaggio',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      validator: (value) => value!.isEmpty ? 'Il messaggio non può essere vuoto' : null,
                    ),
                    const SizedBox(height: 8),
                    const Text('Il tuo feedback ci aiuta a migliorare l\'app. Grazie!', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                  if (_formKey.currentState!.validate()) {
                    authViewModel.inviaFeedback(
                      categoria: _selectedCategory,
                      titolo: _titoloController.text,
                      messaggio: _messaggioController.text,
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