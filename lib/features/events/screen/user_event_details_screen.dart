import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/evento.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../services/eventi_service.dart';

class UserEventDetailsScreen extends StatefulWidget {
  final Evento evento;
  const UserEventDetailsScreen({super.key, required this.evento});

  @override
  State<UserEventDetailsScreen> createState() => _UserEventDetailsScreenState();
}

class _UserEventDetailsScreenState extends State<UserEventDetailsScreen> {
  bool _isLoading = true;
  bool _isParticipating = false;

  @override
  void initState() {
    super.initState();
    _checkInitialParticipationStatus();
  }

  // Controlla se l'utente partecipa già all'evento all'apertura della schermata
  Future<void> _checkInitialParticipationStatus() async {
    final authViewModel = context.read<AuthViewModel>();
    if (authViewModel.currentUser != null) {
      final participating = await EventiService().checkPartecipazione(
        widget.evento.id,
        authViewModel.currentUser!.uid,
      );
      if (mounted) {
        setState(() {
          _isParticipating = participating;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.evento.nome),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dettagli Evento
            Text('Data: ${widget.evento.data}'),
            const SizedBox(height: 8),
            Text('Luogo: ${widget.evento.luogo}'),
            const Divider(height: 32),
            Text(widget.evento.descrizione, style: const TextStyle(fontSize: 16)),
            const Spacer(), // Occupa tutto lo spazio disponibile

            // Sezione Partecipazione (mostrata solo dopo il caricamento)
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_isParticipating)
            // UI se l'utente sta già partecipando
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('✅ Parteciperai a questo evento!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      authViewModel.annullaPartecipazioneEvento(widget.evento.id);
                      setState(() => _isParticipating = false); // Aggiorna subito la UI
                    },
                    child: const Text('Annulla Partecipazione'),
                  ),
                ],
              )
            else
            // UI se l'utente non partecipa ancora
              ElevatedButton(
                onPressed: () {
                  authViewModel.partecipaAllEvento(widget.evento.id);
                  setState(() => _isParticipating = true); // Aggiorna subito la UI
                },
                child: const Text('Partecipa'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}