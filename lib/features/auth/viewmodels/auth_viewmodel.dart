import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../../../core/models/models.dart';
import '../../../core/services/test_data_service.dart';
import '../../products/services/product_service.dart';
import 'dart:io';
import '../../events/services/eventi_service.dart';
import '../../orders/services/orders_service.dart';
import '../../movements/services/movimenti_service.dart';
import '../../feedback/services/feedback_service.dart';




/// ViewModel per gestire lo stato dell'autenticazione e tutti i dati dell'app
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TestDataService _testDataService = TestDataService();
  final ProductService _productService = ProductService();
  final EventiService _eventiService = EventiService();
  final OrdersService _ordersService = OrdersService();
  final MovimentiService _movimentiService = MovimentiService();
  final FeedbackService _feedbackService = FeedbackService();

  AuthResult _authResult = const AuthIdle();
  User? _currentUser;
  UserRole _currentUserRole = UserRole.unknown;

  // Dati dell'applicazione
  Map<String, dynamic> _allAppData = {};
  List<Evento> _tuttiEventi = [];
  List<Evento> _eventiUtente = [];
  List<Movimento> _movimenti = [];
  List<Product> _prodotti = [];
  List<Map<String, dynamic>> _chatMessages = [];
  List<Map<String, dynamic>> _notifiche = [];

  // Dati admin (se applicabile)
  List<User> _allUsers = [];
  List<Movimento> _allMovimenti = [];
  List<Map<String, dynamic>> _orderHistory = [];

  // Getters per lo stato di autenticazione
  AuthResult get authResult => _authResult;

  User? get currentUser => _currentUser;

  UserRole get currentUserRole => _currentUserRole;

  bool get isLoggedIn => _currentUser != null;

  bool get isAdmin => _currentUserRole == UserRole.admin;

  bool get isLoading => _authResult is AuthLoading;

  // Getters per i dati dell'app
  Map<String, dynamic> get allAppData => _allAppData;

  List<Evento> get tuttiEventi => _tuttiEventi;

  List<Evento> get eventiUtente => _eventiUtente;

  List<Movimento> get movimenti => _movimenti;

  List<Product> get prodotti => _prodotti;

  List<Map<String, dynamic>> get chatMessages => _chatMessages;

  List<Map<String, dynamic>> get notifiche => _notifiche;

  // Getters per dati admin
  List<User> get allUsers => _allUsers;

  List<Movimento> get allMovimenti => _allMovimenti;

  List<Map<String, dynamic>> get orderHistory => _orderHistory;

  List<Product> get prodottiOrdinabili =>
      _prodotti.where((p) => p.ordinabile).toList();

  /// Effettua il login E carica tutti i dati
  Future<void> loginUser(String email, String password) async {
    _authResult = const AuthLoading();
    notifyListeners();

    final result = await _authService.loginUser(email, password);
    _authResult = result;

    if (result is AuthSuccess) {
      _currentUser = result.user;
      _currentUserRole = result.userRole;

      // Carica tutti i dati dall'AuthResult
      _loadAllDataFromResult(result);

      print('Login completato con ${_tuttiEventi.length} eventi, ${_movimenti
          .length} movimenti, ${_prodotti.length} prodotti');
    }

    notifyListeners();
  }

  /// Carica tutti i dati dal risultato dell'autenticazione
  void _loadAllDataFromResult(AuthSuccess result) {
    print('🔄 Inizio caricamento dati dal risultato AuthSuccess...');
    _allAppData = result.allData;

    // Carica i dati base dell'utente
    _tuttiEventi = _allAppData['tuttiEventi'] as List<Evento>? ?? [];
    _eventiUtente = _allAppData['eventiUtente'] as List<Evento>? ?? [];
    _movimenti = _allAppData['movimenti'] as List<Movimento>? ?? [];
    _prodotti = _allAppData['prodotti'] as List<Product>? ?? [];
    _chatMessages =
        _allAppData['chatMessages'] as List<Map<String, dynamic>>? ?? [];
    _notifiche = _allAppData['notifiche'] as List<Map<String, dynamic>>? ?? [];

    print('📊 DATI CARICATI NELL\'AUTHVIEWMODEL:');
    print('   📅 Eventi totali: ${_tuttiEventi.length}');
    print('   👤 Eventi utente: ${_eventiUtente.length}');
    print('   💰 Movimenti: ${_movimenti.length}');
    print('   🛍️ Prodotti: ${_prodotti.length}');
    print('   💬 Messaggi chat: ${_chatMessages.length}');
    print('   🔔 Notifiche: ${_notifiche.length}');

    // Se è admin, carica anche i dati amministrativi
    if (isAdmin) {
      _allUsers = _allAppData['allUsers'] as List<User>? ?? [];
      _allMovimenti = _allAppData['allMovimenti'] as List<Movimento>? ?? [];
      _orderHistory =
          _allAppData['orderHistory'] as List<Map<String, dynamic>>? ?? [];

      print('👨‍💼 DATI ADMIN CARICATI:');
      print('   👥 Tutti gli utenti: ${_allUsers.length}');
      print('   💸 Tutti i movimenti: ${_allMovimenti.length}');
      print('   📦 Storico ordini: ${_orderHistory.length}');
    }

    // Aggiorna il saldo dell'utente se disponibile
    final saldoAggiornato = _allAppData['saldoAggiornato'] as double?;
    if (saldoAggiornato != null && _currentUser != null) {
      print('💳 Aggiornamento saldo utente: €${saldoAggiornato.toStringAsFixed(
          2)}');
      _currentUser = _currentUser!.copyWith(
        saldo: saldoAggiornato,
        movimenti: _movimenti,
      );
    }

    print('✅ Caricamento dati completato con successo!');
  }

  /// Effettua la registrazione
  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    required String nome,
  }) async {
    _authResult = const AuthLoading();
    notifyListeners();

    final result = await _authService.registerUser(
      email: email,
      password: password,
      username: username,
      nome: nome,
    );
    _authResult = result;

    if (result is AuthSuccess) {
      _currentUser = result.user;
      _currentUserRole = result.userRole;

      // Dopo la registrazione, ricarica i dati
      await _reloadAllData();
    }

    notifyListeners();
  }

  /// Effettua il logout e pulisce tutti i dati
  Future<void> logout() async {
    await _authService.logout();

    // Pulisce tutti i dati
    _currentUser = null;
    _currentUserRole = UserRole.unknown;
    _authResult = const AuthIdle();
    _clearAllData();

    notifyListeners();
  }

  /// Pulisce tutti i dati dell'app
  void _clearAllData() {
    _allAppData.clear();
    _tuttiEventi.clear();
    _eventiUtente.clear();
    _movimenti.clear();
    _prodotti.clear();
    _chatMessages.clear();
    _notifiche.clear();
    _allUsers.clear();
    _allMovimenti.clear();
    _orderHistory.clear();
  }

  /// Resetta il risultato dell'autenticazione
  void resetAuthResult() {
    _authResult = const AuthIdle();
    notifyListeners();
  }

  /// Inizializza lo stato dell'autenticazione E carica tutti i dati
  Future<void> initializeAuth() async {
    _authResult = const AuthLoading();
    notifyListeners();

    try {
      final allUserData = await _authService.getCurrentUserData();
      if (allUserData != null && allUserData.isNotEmpty) {
        final user = allUserData['user'] as User?;
        if (user != null) {
          _currentUser = user;
          _currentUserRole = user.ruolo;

          // Crea un AuthSuccess sicuro per caricare i dati
          final successResult = AuthSuccess(
              user: user,
              userRole: user.ruolo,
              allData: allUserData
          );
          _loadAllDataFromResult(successResult);

          _authResult = successResult;
          print('Inizializzazione completata con tutti i dati caricati');
        } else {
          _authResult = const AuthIdle();
        }
      } else {
        _authResult = const AuthIdle();
      }
    } catch (e) {
      print('Errore durante l\'inizializzazione: $e');
      _authResult = AuthError('Errore durante l\'inizializzazione: $e');
    }

    notifyListeners();
  }

  /// Aggiorna i dati dell'utente
  Future<void> updateUser(User updatedUser) async {
    final success = await _authService.updateUserData(updatedUser);
    if (success) {
      _currentUser = updatedUser;
      _currentUserRole = updatedUser.ruolo;
      notifyListeners();
    }
  }

  /// Ricarica tutti i dati (utile per refresh)
  Future<void> _reloadAllData() async {
    if (_currentUser == null) return;

    try {
      final allUserData = await _authService.getCurrentUserData();
      if (allUserData != null) {
        final fakeResult = AuthSuccess(
            user: _currentUser!,
            userRole: _currentUserRole,
            allData: allUserData
        );
        _loadAllDataFromResult(fakeResult);
        notifyListeners();
      }
    } catch (e) {
      print('Errore nel reload dei dati: $e');
    }
  }

  /// Refresh manuale dei dati (chiamabile dall'interfaccia)
  Future<void> refreshAllData() async {
    await _reloadAllData();
  }

  /// Crea dati di test (solo per sviluppo)
  Future<void> createTestData() async {
    if (_currentUser == null) return;

    try {
      await _testDataService.createTestData(_currentUser!.uid);
      // Ricarica i dati dopo aver creato i dati di test
      await refreshAllData();
      print('✅ Dati di test creati e ricaricati');
    } catch (e) {
      print('❌ Errore nella creazione dati di test: $e');
    }
  }

  // Metodi di utilità per accedere ai dati

  /// Ottieni eventi non letti
  List<Map<String, dynamic>> get notificheNonLette =>
      _notifiche.where((n) => n['letta'] != true).toList();

  /// Ottieni ultimi movimenti
  List<Movimento> get ultimiMovimenti =>
      _movimenti.take(5).toList();

  /// Ottieni eventi futuri dell'utente
  List<Evento> get eventiFuturi {
    return _eventiUtente.where((evento) {
      return evento.isFuturo;
    }).toList();
  }

  /// Ottieni prodotti disponibili
  List<Product> get prodottiDisponibili =>
      _prodotti.where((p) => p.isAvailable).toList();

  Future<void> updateProduct(Product product) async {
    try {
      // Chiama il service per aggiornare il dato su Firestore
      await _productService.updateProduct(product);

      // Aggiorna la lista locale per riflettere subito la modifica nella UI
      final index = _prodotti.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _prodotti[index] = product;
        notifyListeners(); // Notifica la UI del cambiamento
      }
    } catch (e) {
      print('Errore durante l\'aggiornamento del prodotto: $e');
      // Rilancia l'errore così la UI può mostrarlo
      throw Exception('Salvataggio fallito');
    }
  }

  Future<String> uploadProductImage(File imageFile, String productId) {
    // Delega semplicemente la chiamata al service
    return _productService.uploadProductImage(imageFile, productId);
  }

  Future<void> partecipaAllEvento(String eventId) async {
    if (currentUser == null) {
      throw Exception('Nessun utente loggato.');
    }
    try {
      // Passa l'intero oggetto User al service
      await _eventiService.partecipaEvento(eventId, currentUser!);
      // Opzionale: puoi ricaricare i dati per un feedback immediato
      await refreshAllData();
    } catch (e) {
      rethrow;
    }
  }

  /// Chiama il service per eliminare un ordine.
  Future<void> eliminaOrdine(String orderId) async {
    try {
      await _ordersService.eliminaOrdine(orderId);
      // Ricarichiamo tutti i dati per far sparire l'ordine dalla lista nella UI
      await refreshAllData();
    } catch (e) {
      print('Errore nel ViewModel durante l\'eliminazione dell\'ordine: $e');
      rethrow;
    }
  }

  /// Gestisce l'intero processo di ricarica del saldo per un utente.
  Future<void> eseguiRicarica(String userId, double importo) async {
    try {
      // 1. Crea l'oggetto Movimento che rappresenta questa ricarica
      final ricaricaMovimento = Movimento(
        id: '',
        importo: importo,
        descrizione: 'Ricarica manuale',
        data: DateTime.now(),
        tipo: 'ricarica',
        userId: userId,
      );

      // 2. Esegui entrambe le operazioni
      await _authService.aggiornaSaldoUtente(userId, importo);
      await _movimentiService.addMovimento(userId, ricaricaMovimento);

      // 3. Ricarica tutti i dati per aggiornare la UI
      await refreshAllData();
    } catch (e) {
      print('Errore nel ViewModel durante la ricarica: $e');
      rethrow;
    }
  }

  /// Crea un nuovo ordine chiamando il service
  Future<void> creaNuovoOrdine({
    required Product prodotto,
    String? richiesteAggiuntive,
  }) async {
    if (currentUser == null) throw Exception('Utente non loggato');

    try {
      // 1. Prepara i dati per l'ordine
      final orderData = {
        'prodottoId': prodotto.id,
        'nomeProdotto': prodotto.nome,
        'uidUtente': currentUser!.uid,
        'nomeUtente': currentUser!.nome,
        'richiesteAggiuntive': richiesteAggiuntive,
        'stato': 'INVIATO',
        'timestamp': FieldValue.serverTimestamp(),
        'total': prodotto.prezzo,
      };

      // 2. Prepara i dati per il Movimento
      final movimento = Movimento(
        id: '',
        importo: -prodotto.prezzo,
        descrizione: 'Ordine: ${prodotto.nome}',
        data: DateTime.now(),
        tipo: 'pagamento',
        userId: currentUser!.uid,
      );

      // 3. Esegui TUTTE le operazioni sul database
      await _ordersService.creaOrdine(orderData);
      // 🔥 CORREZIONE: Chiama addMovimento passando l'ID dell'utente e il movimento
      await _movimentiService.addMovimento(currentUser!.uid, movimento);
      await _authService.aggiornaSaldoUtente(currentUser!.uid, -prodotto.prezzo);

      // 4. Ricarica tutti i dati per aggiornare la UI
      await refreshAllData();

    } catch (e) {
      print('Errore durante la creazione del nuovo ordine: $e');
      rethrow;
    }
  }

  /// Annulla la partecipazione di un utente a un evento.
  Future<void> annullaPartecipazioneEvento(String eventId) async {
    if (currentUser == null) {
      throw Exception('Nessun utente loggato.');
    }
    try {
      await _eventiService.annullaPartecipazione(eventId, currentUser!.uid);
      await refreshAllData(); // Ricarica i dati per aggiornare la UI
    } catch (e) {
      rethrow;
    }
  }

  /// Gestisce l'intero processo di richiesta di una nuova tessera.
  Future<void> richiediTessera() async {
    if (currentUser == null) {
      throw Exception('Nessun utente loggato.');
    }

    const double costoTessera = 3.0;

    // 1. Controlla se il saldo è sufficiente
    if (currentUser!.saldo < costoTessera) {
      throw Exception('Saldo insufficiente per richiedere la tessera.');
    }

    try {
      // 2. Prepara il movimento per registrare la transazione
      final movimentoTessera = Movimento(
        id: '',
        importo: -costoTessera,
        descrizione: 'Richiesta tessera socio',
        data: DateTime.now(),
        tipo: 'pagamento',
        userId: currentUser!.uid,
      );

      // 3. Esegui tutte le operazioni sul database
      await _authService.aggiornaSaldoUtente(currentUser!.uid, -costoTessera);
      await _movimentiService.addMovimento(currentUser!.uid, movimentoTessera);
      await _authService.impostaRichiestaTessera(currentUser!.uid, true);

      // 4. Aggiorna i dati nell'app
      await refreshAllData();

    } catch (e) {
      print('Errore durante la richiesta della tessera: $e');
      rethrow; // Rilancia l'errore per mostrarlo nella UI
    }
  }
  /// Gestisce l'invio di un nuovo feedback da parte dell'utente.
  Future<void> inviaFeedback({
    required String categoria,
    required String titolo,
    required String messaggio,
  }) async {
    if (currentUser == null) {
      throw Exception('Nessun utente loggato per inviare il feedback.');
    }

    // Prepara la mappa dei dati come nel tuo database
    final feedbackData = {
      'categoria': categoria,
      'titolo': titolo,
      'messaggio': messaggio,
      'letto': false,
      'timestamp': FieldValue.serverTimestamp(),
      'uidUtente': currentUser!.uid,
      'nomeUtente': currentUser!.displayName,
      'emailUtente': currentUser!.email,
    };

    try {
      await _feedbackService.inviaFeedback(feedbackData);
    } catch (e) {
      // L'errore viene rilanciato per essere mostrato nella UI
      rethrow;
    }
  }
}