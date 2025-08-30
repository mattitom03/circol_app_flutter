import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/services/firestore_data_service.dart';

class ChatViewModel extends ChangeNotifier {
  final FirestoreDataService _dataService = FirestoreDataService();

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ChatViewModel() {
    loadAllUsers();
  }

  Future<void> loadAllUsers() async {
    _isLoading = true;
    notifyListeners();
    _allUsers = await _dataService.loadAllUsers();
    _isLoading = false;
    notifyListeners();
  }

  User? getUserById(String uid) {
    try {
      return _allUsers.firstWhere((user) => user.uid == uid);
    } catch (e) {
      // Se l'utente non è nella lista, ritorna null
      return null;
    }
  }
}