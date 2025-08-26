import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/models.dart';
import '../../../core/services/firestore_data_service.dart';

/// Servizio per gestire l'autenticazione con Firebase
class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreDataService _dataService = FirestoreDataService();

  /// Stream per monitorare lo stato dell'autenticazione
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Utente attualmente autenticato
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Login con email e password - ORA CARICA TUTTI I DATI
  Future<AuthResult> loginUser(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return const AuthError('Email e password sono obbligatori');
      }

      print('Tentativo di login per: $email');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const AuthError('Errore durante il login');
      }

      print('Login Firebase riuscito per: ${credential.user!.email}');

      // Carica TUTTI i dati dell'utente da Firestore
      final allUserData = await _dataService.loadAllUserData(credential.user!.uid);

      if (allUserData.isEmpty) {
        return const AuthError('Errore nel caricamento dati utente');
      }

      final user = allUserData['user'] as User?;
      if (user == null) {
        // Se l'utente non esiste in Firestore, crea un documento base
        print('Documento utente non trovato in Firestore, creando utente base...');
        final basicUser = User(
          uid: credential.user!.uid,
          email: credential.user!.email ?? email,
          nome: credential.user!.displayName ?? 'Utente',
          username: credential.user!.email?.split('@')[0] ?? 'user',
          displayName: credential.user!.displayName ?? 'Utente',
          ruolo: UserRole.user,
        );

        await _firestore
            .collection('utenti')
            .doc(credential.user!.uid)
            .set(basicUser.toMap());

        return AuthSuccess(
          user: basicUser,
          userRole: basicUser.ruolo,
          allData: allUserData,
        );
      }

      print('Dati completi caricati per: ${user.email}, ruolo: ${user.ruolo}');

      // Se l'utente è admin, carica anche i dati amministrativi
      Map<String, dynamic> finalData = allUserData;
      if (user.ruolo == UserRole.admin) {
        print('Caricamento dati admin...');
        finalData = await _dataService.loadAdminData(user.uid);
      }

      return AuthSuccess(
        user: user,
        userRole: user.ruolo,
        allData: finalData,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Errore Firebase Auth: ${e.code} - ${e.message}');
      String errorMessage = 'Errore durante il login';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Utente non trovato';
          break;
        case 'wrong-password':
          errorMessage = 'Password incorretta';
          break;
        case 'invalid-email':
          errorMessage = 'Email non valida';
          break;
        case 'user-disabled':
          errorMessage = 'Account disabilitato';
          break;
        case 'invalid-credential':
          errorMessage = 'Credenziali non valide';
          break;
        default:
          errorMessage = 'Errore durante il login: ${e.message}';
      }

      return AuthError(errorMessage);
    } catch (e) {
      print('Errore generico durante il login: $e');
      return AuthError('Errore imprevisto: $e');
    }
  }

  /// Registrazione nuovo utente
  Future<AuthResult> registerUser({
    required String email,
    required String password,
    required String username,
    required String nome,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty || nome.isEmpty) {
        return const AuthError('Tutti i campi sono obbligatori');
      }

      print('Tentativo di registrazione per: $email');

      // Verifica se l'username è già in uso
      final usernameQuery = await _firestore
          .collection('utenti')
          .where('username', isEqualTo: username)
          .get();

      if (usernameQuery.docs.isNotEmpty) {
        return const AuthError('Username già in uso');
      }

      // Crea l'account Firebase
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return const AuthError('Errore durante la registrazione');
      }

      // Crea il documento utente in Firestore
      final newUser = User(
        uid: credential.user!.uid,
        username: username,
        nome: nome,
        email: email,
        displayName: nome,
        ruolo: UserRole.user, // Default a utente normale
      );

      await _firestore
          .collection('utenti')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      print('Registrazione completata per: ${newUser.email}');
      return AuthSuccess(user: newUser, userRole: newUser.ruolo, allData: {});
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('Errore Firebase Auth durante registrazione: ${e.code} - ${e.message}');
      String errorMessage = 'Errore durante la registrazione';

      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password troppo debole';
          break;
        case 'email-already-in-use':
          errorMessage = 'Email già registrata';
          break;
        case 'invalid-email':
          errorMessage = 'Email non valida';
          break;
        default:
          errorMessage = 'Errore durante la registrazione: ${e.message}';
      }

      return AuthError(errorMessage);
    } catch (e) {
      print('Errore generico durante registrazione: $e');
      return AuthError('Errore imprevisto: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      print('Logout completato');
    } catch (e) {
      print('Errore durante logout: $e');
    }
  }

  /// Recupera i dati dell'utente corrente - ORA CARICA TUTTI I DATI
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      print('Nessun utente autenticato');
      return null;
    }

    try {
      print('Caricamento dati completi per utente corrente: ${user.uid}');
      final allUserData = await _dataService.loadAllUserData(user.uid);

      if (allUserData.isEmpty) {
        print('Nessun dato trovato per l\'utente');
        return null;
      }

      final userData = allUserData['user'] as User?;
      if (userData == null) {
        return null;
      }

      // Se è admin, carica i dati amministrativi
      if (userData.ruolo == UserRole.admin) {
        return await _dataService.loadAdminData(user.uid);
      }

      return allUserData;
    } catch (e) {
      print('Errore durante caricamento dati utente corrente: $e');
      return null;
    }
  }

  /// Aggiorna i dati dell'utente
  Future<bool> updateUserData(User user) async {
    try {
      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .update(user.toMap());
      print('Dati utente aggiornati: ${user.email}');
      return true;
    } catch (e) {
      print('Errore durante aggiornamento dati utente: $e');
      return false;
    }
  }
}
