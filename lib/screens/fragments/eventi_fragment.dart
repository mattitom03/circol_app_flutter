import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/evento.dart';
import '../../viewmodels/auth_viewmodel.dart';

class EventiFragment extends StatefulWidget {
  const EventiFragment({super.key});

  @override
  State<EventiFragment> createState() => _EventiFragmentState();
}

class _EventiFragmentState extends State<EventiFragment> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Evento> _eventi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventi();
  }

  Future<void> _loadEventi() async {
    try {
      setState(() => _isLoading = true);

      final querySnapshot = await _firestore
          .collection('eventi')
          .orderBy('data', descending: false)
          .get();

      _eventi = querySnapshot.docs
          .map((doc) => Evento.fromMap(doc.data(), documentId: doc.id))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nel caricamento eventi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventi'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigare ad AddEvento
              _showAddEventDialog();
            },
          ),
        ],
      ),
      body: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          // Usa gli eventi dal ViewModel invece di caricarli separatamente
          final eventi = authViewModel.tuttiEventi;
          final isLoading = authViewModel.isLoading;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (eventi.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nessun evento disponibile',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Gli eventi verranno caricati da Firestore',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Informazioni di debug
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  'Caricati ${eventi.length} eventi da Firestore',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Lista eventi
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => authViewModel.refreshAllData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: eventi.length,
                    itemBuilder: (context, index) {
                      final evento = eventi[index];
                      return _buildEventoCard(evento);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventoCard(Evento evento) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEventoDetails(evento),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.event,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evento.nome,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${evento.data} - ${evento.ora}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (evento.quota != null && evento.quota! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '€ ${evento.quota!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                evento.descrizione,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      evento.luogo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '${evento.partecipanti.length} partecipanti',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventoDetails(Evento evento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(evento.nome),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descrizione:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(evento.descrizione),
              const SizedBox(height: 12),
              Text(
                'Data e Ora:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${evento.data} alle ${evento.ora}'),
              const SizedBox(height: 12),
              Text(
                'Luogo:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(evento.luogo),
              const SizedBox(height: 12),
              if (evento.quota != null && evento.quota! > 0) ...[
                Text(
                  'Quota di partecipazione:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '€ ${evento.quota!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                'Partecipanti: ${evento.partecipanti.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _partecipateToEvent(evento);
            },
            child: const Text('Partecipa'),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Evento'),
        content: const Text('Funzionalità in sviluppo...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }

  void _partecipateToEvent(Evento evento) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iscritto all\'evento: ${evento.nome}'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
