import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/services/firestore_data_service.dart';

class NewChatViewModel extends ChangeNotifier {
  final FirestoreDataService _dataService = FirestoreDataService();

  List<User> _users = [];
  List<User> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  NewChatViewModel() {
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    // Usiamo il metodo che avevamo già creato per l'admin
    _users = await _dataService.loadAllUsers();
    _isLoading = false;
    notifyListeners();
  }
}