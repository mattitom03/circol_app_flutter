import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gestione_tessere_viewmodel.dart';
import '../../../core/models/user.dart';
import 'package:intl/intl.dart';

class GestioneTessereScreen extends StatelessWidget {
  const GestioneTessereScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GestioneTessereViewModel(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Gestione Tessere Socio')),
        body: Consumer<GestioneTessereViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: viewModel.allUsers.length,
              itemBuilder: (context, index) {
                final user = viewModel.allUsers[index];
                return _buildUserCard(context, user, viewModel);
              },
            );
          },
        ),
      ),
    );
  }

}

Widget _buildUserCard(BuildContext context, User user, GestioneTessereViewModel viewModel) {
  final currencyFormatter = NumberFormat.currency(locale: 'it_IT', symbol: '€');
  Widget statusWidget;

  if (user.hasTessera) {
    statusWidget = const Row(children: [
      Icon(Icons.check_circle, color: Colors.green, size: 16),
      SizedBox(width: 4),
      Text('Tessera attiva'),
    ]);
  } else if (user.richiestaRinnovoInCorso) {
    statusWidget = const Row(children: [
      Icon(Icons.hourglass_top, color: Colors.orange, size: 16),
      SizedBox(width: 4),
      Text('Richiesta in attesa'),
    ]);
  } else {
    statusWidget = const Row(children: [
      Icon(Icons.cancel, color: Colors.grey, size: 16),
      SizedBox(width: 4),
      Text('Nessuna tessera'),
    ]);
  }

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(user.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('UID: ${user.uid}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(),
          statusWidget,
          Text('Saldo: ${currencyFormatter.format(user.saldo)}'),
          if (user.hasTessera && user.dataScadenzaTessera != null)
            Text('Scadenza: ${DateFormat('dd/MM/yyyy').format(user.dataScadenzaTessera!)}'),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () => _showManageCardDialog(context, user, viewModel),
              child: const Text('Gestisci'),
            ),
          ),
        ],
      ),
    ),
  );
}

void _showManageCardDialog(BuildContext context, User user, GestioneTessereViewModel viewModel) {
  Widget title;
  Widget content;
  List<Widget> actions;

  if (user.richiestaRinnovoInCorso) {
    title = Text('Gestisci Richiesta - ${user.displayName}');
    content = const Text('L\'utente ha richiesto una nuova tessera. Vuoi approvare o rifiutare la richiesta?');
    actions = [
      TextButton(onPressed: () => viewModel.rifiutaRichiesta(user.uid), child: const Text('Rifiuta')),
      ElevatedButton(onPressed: () => viewModel.assegnaTessera(user.uid), child: const Text('Approva')),
    ];
  }
  else if (user.hasTessera) {
    title = Text('Gestisci Tessera - ${user.displayName}');
    content = const Text('L\'utente ha già una tessera attiva. Puoi rinnovarla o revocarla.');
    actions = [
      TextButton(onPressed: () => viewModel.revocaTessera(user.uid), child: const Text('Revoca Tessera')),
      ElevatedButton(onPressed: () { /* TODO: Logica Rinnovo */ }, child: const Text('Rinnova')),
    ];
  }
  else {
    title = Text('Assegna Tessera - ${user.nome}');
    content = const Text('L\'utente non ha una tessera socio. Vuoi assegnargliene una nuova?');
    actions = [
      ElevatedButton(onPressed: () => viewModel.assegnaTessera(user.uid), child: const Text('Assegna Tessera')),
    ];
  }

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: title,
        content: content,
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Chiudi')),
          ...actions,
        ],
      );
    },
  );
}