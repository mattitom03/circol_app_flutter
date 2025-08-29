import 'package:flutter/material.dart';
import '../../../core/models/user.dart';
import '../../../core/services/firestore_data_service.dart';
import '../../auth/services/auth_service.dart';

class GestioneTessereViewModel extends ChangeNotifier {
  final FirestoreDataService _dataService = FirestoreDataService();
  final AuthService _authService = AuthService();

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GestioneTessereViewModel() {
    fetchAllUsers();
  }

  Future<void> fetchAllUsers() async {
    _isLoading = true;
    notifyListeners();
    // Usiamo il metodo che avevamo già in FirestoreDataService
    _allUsers = await _dataService.loadAllUsers();
    _isLoading = false;
    notifyListeners();
  }

  // Qui aggiungeremo le azioni che chiamano l'AuthService
  Future<void> assegnaTessera(String uid) async {
    await _authService.assegnaTessera(uid);
    await fetchAllUsers(); // Ricarica la lista per mostrare i cambiamenti
  }

  Future<void> rifiutaRichiesta(String uid) async {
    await _authService.impostaRichiestaTessera(uid, false);
    await fetchAllUsers();
  }

  Future<void> revocaTessera(String uid) async {
    await _authService.revocaTessera(uid);
    await fetchAllUsers();
  }
}