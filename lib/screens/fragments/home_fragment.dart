import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';
import '../movimenti_screen.dart';

class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CircolApp - Home'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigare alle notifiche
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          final user = authViewModel.currentUser;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card di benvenuto
                _buildWelcomeCard(user),
                const SizedBox(height: 20),

                // Card saldo e tessera
                _buildSaldoCard(user),
                const SizedBox(height: 20),

                // Azioni rapide
                _buildQuickActions(context),
                const SizedBox(height: 20),

                // Ultimi movimenti
                _buildUltimimMovimenti(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(User user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.deepPurple,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.nome.isNotEmpty ? user.nome[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benvenuto,',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    user.nome.isNotEmpty ? user.nome : user.username,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard(User user) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo Disponibile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.green[600],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '€ ${user.saldo.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  user.hasTessera ? Icons.check_circle : Icons.cancel,
                  color: user.hasTessera ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  user.hasTessera ? 'Tessera Attiva' : 'Tessera Non Attiva',
                  style: TextStyle(
                    color: user.hasTessera ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (user.hasTessera && user.numeroTessera != null) ...[
              const SizedBox(height: 8),
              Text(
                'Numero: ${user.numeroTessera}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Azioni Rapide',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.add_card,
                  label: 'Ricarica',
                  onTap: () {
                    // TODO: Navigare alla ricarica
                  },
                ),
                _buildActionButton(
                  icon: Icons.shopping_cart,
                  label: 'Catalogo',
                  onTap: () {
                    // TODO: Navigare al catalogo
                  },
                ),
                _buildActionButton(
                  icon: Icons.event,
                  label: 'Eventi',
                  onTap: () {
                    // TODO: Navigare agli eventi
                  },
                ),
                _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'QR Code',
                  onTap: () {
                    // TODO: Navigare al QR code
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.deepPurple,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUltimimMovimenti(User user) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Usa i movimenti dal ViewModel invece che dal modello User
        final ultimiMovimenti = authViewModel.ultimiMovimenti;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ultimi Movimenti',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MovimentiScreen(),
                          ),
                        );
                      },
                      child: const Text('Vedi tutti'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (ultimiMovimenti.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Nessun movimento disponibile'),
                    ),
                  )
                else
                  Column(
                    children: ultimiMovimenti.map((movimento) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: movimento.importo >= 0
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          child: Icon(
                            movimento.importo >= 0 ? Icons.add : Icons.remove,
                            color: movimento.importo >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(movimento.descrizione),
                        subtitle: Text('${movimento.tipo} - ${_formatDate(movimento.data)}'),
                        trailing: Text(
                          '€ ${movimento.importo.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: movimento.importo >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                if (authViewModel.movimenti.isNotEmpty)
                  Text(
                    'Caricati ${authViewModel.movimenti.length} movimenti da Firestore',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                // Pulsante per creare dati di test (solo se non ci sono dati)
                if (authViewModel.movimenti.isEmpty) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await authViewModel.createTestData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dati di test creati! Ricarica l\'app per vederli.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.data_object, size: 16),
                    label: const Text('Crea dati di test'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
