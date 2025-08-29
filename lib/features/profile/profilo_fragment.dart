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
            _buildInfoRow(
              Icons.credit_card,
              'Tessera:',
              user.hasTessera ? 'Attiva' : 'Non attiva',
              valueColor: user.hasTessera ? Colors.green : Colors.red,
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
                // Logica da implementare in futuro
                print('Pulsante "Richiedi Tessera" premuto.');
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('Invia Feedback'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Logica da implementare in futuro
                print('Pulsante "Invia Feedback" premuto.');
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