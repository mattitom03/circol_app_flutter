import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodels/feedback_viewmodel.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedbackViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Feedback Ricevuti'),
        ),
        body: Consumer<FeedbackViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (viewModel.feedbacks.isEmpty) {
              return const Center(child: Text('Nessun feedback ricevuto.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: viewModel.feedbacks.length,
              itemBuilder: (context, index) {
                return _buildFeedbackCard(context, viewModel.feedbacks[index], viewModel);
              },
            );
          },
        ),
      ),
    );
  }
}

// Funzione helper per costruire la card del feedback
Widget _buildFeedbackCard(BuildContext context, Map<String, dynamic> feedback, FeedbackViewModel viewModel) {
  final categoria = feedback['categoria'] ?? 'N/A';
  final titolo = feedback['titolo'] ?? 'Nessun titolo';
  final nomeUtente = feedback['nomeUtente'] ?? 'Anonimo';
  final messaggio = feedback['messaggio'] ?? '';
  final isLetto = feedback['letto'] as bool? ?? false;
  final timestamp = feedback['timestamp'] as Timestamp?;
  final date = timestamp != null ? timestamp.toDate() : DateTime.now();

  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: InkWell(
      onTap: () {
        // Segna come letto solo se non lo è già
        if (!isLetto) {
          viewModel.segnaFeedbackComeLetto(feedback['id']);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: isLetto ? Colors.grey : Colors.blue),
                const SizedBox(width: 8),
                Chip(label: Text(categoria), visualDensity: VisualDensity.compact),
                const Spacer(),
                Text(DateFormat('dd/MM/yyyy HH:mm').format(date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(titolo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Da: $nomeUtente', style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text(messaggio),
          ],
        ),
      ),
    ),
  );
}