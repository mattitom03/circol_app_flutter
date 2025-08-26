import 'package:flutter/material.dart';
import '../services/eventi_service.dart';
import '../../../core/models/evento.dart';

class AdminEventDetailsScreen extends StatefulWidget {
  final Evento evento;
  const AdminEventDetailsScreen({super.key, required this.evento});

  @override
  State<AdminEventDetailsScreen> createState() => _AdminEventDetailsScreenState();
}

class _AdminEventDetailsScreenState extends State<AdminEventDetailsScreen> {
  late Future<List<Map<String, dynamic>>> _partecipantiFuture;

  @override
  void initState() {
    super.initState();
    _partecipantiFuture = EventiService().getPartecipanti(widget.evento.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento.nome), // Usa 'nome' o 'titolo'
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text('Descrizione', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(widget.evento.descrizione),
          const Divider(height: 40),
          Text('Partecipanti', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _partecipantiFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Nessun partecipante.'));
              }
              final partecipanti = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: partecipanti.length,
                itemBuilder: (context, index) {
                  final partecipante = partecipanti[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(partecipante['nome'] ?? 'Nome non disponibile'),
                      subtitle: Text(partecipante['email'] ?? 'Email non disponibile'),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}