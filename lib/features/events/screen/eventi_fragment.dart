import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/evento.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import 'admin_event_details_screen.dart'; // Importa la schermata admin che hai già creato

class EventiFragment extends StatelessWidget {
  const EventiFragment({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final eventi = authViewModel.tuttiEventi;
    final isLoading = authViewModel.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventi'),
      ),
      body: RefreshIndicator(
        onRefresh: () => authViewModel.refreshAllData(),
        child: Builder(
          builder: (context) {
            if (isLoading && eventi.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (eventi.isEmpty) {
              return const Center(child: Text('Nessun evento disponibile.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: eventi.length,
              itemBuilder: (context, index) {
                final evento = eventi[index];
                return _buildEventoCard(context, evento, authViewModel);
              },
            );
          },
        ),
      ),
    );
  }
}

// --- FUNZIONI HELPER (FUORI DALLA CLASSE) ---

Widget _buildEventoCard(BuildContext context, Evento evento, AuthViewModel authViewModel) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.calendar_month_outlined)),
      title: Text(evento.nome), // Usa 'nome' o il campo corretto del tuo modello
      subtitle: Text(
        evento.descrizione,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        if (authViewModel.isAdmin) {
          // ADMIN: Naviga alla schermata di dettaglio
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AdminEventDetailsScreen(evento: evento),
            ),
          );
        } else {
          // UTENTE NORMALE: Mostra il popup per iscriversi
          _showPartecipaDialog(context, evento, authViewModel);
        }
      },
    ),
  );
}

void _showPartecipaDialog(BuildContext context, Evento evento, AuthViewModel authViewModel) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(evento.nome), // Usa 'nome' o il campo corretto
        content: const Text('Vuoi iscriverti a questo evento?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Chiudi'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            child: const Text('Partecipa'),
            onPressed: () {
              authViewModel.partecipaAllEvento(evento.id)
                  .then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Iscrizione avvenuta!'), backgroundColor: Colors.green),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Errore: ${e.toString()}'), backgroundColor: Colors.red),
                );
              });
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}
