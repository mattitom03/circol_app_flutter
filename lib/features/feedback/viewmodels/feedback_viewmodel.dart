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

  Future<void> segnaFeedbackComeLetto(String feedbackId) async {
    final index = _feedbacks.indexWhere((fb) => fb['id'] == feedbackId);
    if (index != -1 && _feedbacks[index]['letto'] == false) {
      _feedbacks[index]['letto'] = true;
      notifyListeners();
    }

    try {
      await _feedbackService.segnaComeLetto(feedbackId);
    } catch (e) {
      _feedbacks[index]['letto'] = false;
      notifyListeners();
    }
  }
}