import 'package:flutter/material.dart';
import '../services/feedback_service.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();

  List<Map<String, dynamic>> _feedbacks = [];
  List<Map<String, dynamic>> get feedbacks => _feedbacks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  FeedbackViewModel() {
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    _isLoading = true;
    notifyListeners();
    _feedbacks = await _feedbackService.getTuttiFeedback();
    _isLoading = false;
    notifyListeners();
  }

  /// Segna un feedback come letto e aggiorna la UI istantaneamente.
  Future<void> segnaFeedbackComeLetto(String feedbackId) async {
    // Aggiorna l'interfaccia subito per un feedback visivo immediato
    final index = _feedbacks.indexWhere((fb) => fb['id'] == feedbackId);
    if (index != -1 && _feedbacks[index]['letto'] == false) {
      _feedbacks[index]['letto'] = true;
      notifyListeners();
    }

    // Esegui l'aggiornamento sul database in background
    try {
      await _feedbackService.segnaComeLetto(feedbackId);
    } catch (e) {
      // Se l'aggiornamento fallisce, ripristina lo stato precedente e mostra un errore
      _feedbacks[index]['letto'] = false;
      notifyListeners();
      // Qui potresti voler mostrare un messaggio di errore
    }
  }
}