import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../../core/models/movimento.dart';

class MovimentiScreen extends StatelessWidget {
  const MovimentiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutti i Movimenti'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final movimenti = authViewModel.movimenti;
          
          if (movimenti.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessun movimento disponibile',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'I tuoi movimenti appariranno qui',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Card riassuntiva
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Totale Movimenti',
                        movimenti.length.toString(),
                        Icons.receipt_long,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Saldo Attuale',
                        '€ ${authViewModel.currentUser?.saldo.toStringAsFixed(2) ?? '0.00'}',
                        Icons.account_balance_wallet,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              // Lista movimenti
              Expanded(
                child: ListView.builder(
                  itemCount: movimenti.length,
                  itemBuilder: (context, index) {
                    final movimento = movimenti[index];
                    return _buildMovimentoTile(movimento);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implementare refresh
          context.read<AuthViewModel>().refreshAllData();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMovimentoTile(Movimento movimento) {
    final isPositive = movimento.importo >= 0;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPositive 
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            isPositive ? Icons.add : Icons.remove,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          movimento.descrizione,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movimento.tipo.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(movimento.data),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Text(
          '€ ${movimento.importo.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        onTap: () => _showMovimentoDetails(movimento),
      ),
    );
  }

  void _showMovimentoDetails(Movimento movimento) {
    // TODO: Implementare dettagli movimento
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
