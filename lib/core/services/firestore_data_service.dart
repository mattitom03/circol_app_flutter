import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/movimento.dart';
import '../models/evento.dart';
import '../models/product.dart';
import '../../features/events/services/eventi_service.dart';
import '../../features/movements/services/movimenti_service.dart';
import '../../features/products/services/product_service.dart';

class FirestoreDataService {
  final EventiService _eventiService = EventiService();
  final MovimentiService _movimentiService = MovimentiService();
  final ProductService _productService = ProductService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Carica tutti i dati necessari per un utente
  Future<Map<String, dynamic>> loadAllUserData(String userId) async {
    try {
      print('Caricamento completo dati per utente: $userId');

      // Carica tutti i dati in parallelo per migliorare le performance
      final results = await Future.wait([
        _loadUserDocument(userId),
        _eventiService.getAllEventi(),
        _eventiService.getEventiPerUtente(userId),
        _movimentiService.getMovimentiUtente(userId),
        _productService.getAllProducts(),
        _loadChatMessages(userId),
        _loadNotifiche(userId),
      ]);

      final userData = results[0] as User?;
      final tuttiEventi = results[1] as List<Evento>;
      final eventiUtente = results[2] as List<Evento>;
      final movimenti = results[3] as List<Movimento>;
      final prodotti = results[4] as List<Product>;
      final chatMessages = results[5] as List<Map<String, dynamic>>;
      final notifiche = results[6] as List<Map<String, dynamic>>;

      // Aggiorna il saldo dell'utente con i movimenti più recenti
      double saldoCalcolato = 0.0;
      for (final movimento in movimenti) {
        saldoCalcolato += movimento.importo;
      }

      // Aggiorna l'utente con i dati più recenti
      User? updatedUser = userData;
      if (userData != null) {
        updatedUser = userData.copyWith(
          movimenti: movimenti,
          saldo: saldoCalcolato,
        );
      }

      final allData = {
        'user': updatedUser,
        'tuttiEventi': tuttiEventi,
        'eventiUtente': eventiUtente,
        'movimenti': movimenti,
        'prodotti': prodotti,
        'chatMessages': chatMessages,
        'notifiche': notifiche,
        'saldoAggiornato': saldoCalcolato,
      };

      print('Caricamento completo terminato:');
      print('- Eventi totali: ${tuttiEventi.length}');
      print('- Eventi utente: ${eventiUtente.length}');
      print('- Movimenti: ${movimenti.length}');
      print('- Prodotti: ${prodotti.length}');
      print('- Messaggi chat: ${chatMessages.length}');
      print('- Notifiche: ${notifiche.length}');
      print('- Saldo calcolato: €${saldoCalcolato.toStringAsFixed(2)}');

      return allData;
    } catch (e) {
      print('Errore nel caricamento completo dati: $e');
      return {};
    }
  }

  /// Carica il documento utente da Firestore
  Future<User?> _loadUserDocument(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('utenti')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print('Documento utente non trovato');
        return null;
      }

      return User.fromMap(userDoc.data()!);
    } catch (e) {
      print('Errore nel caricamento documento utente: $e');
      return null;
    }
  }

  /// Carica i messaggi di chat dell'utente
  Future<List<Map<String, dynamic>>> _loadChatMessages(String userId) async {
    try {
      print('Caricamento messaggi chat per utente: $userId');

      // Query semplificata per evitare errori di indici
      final conversationsSnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .get(); // Rimuovo orderBy che richiede indice composto

      List<Map<String, dynamic>> allMessages = [];

      // Ordino le conversazioni in memoria per lastMessageTime
      final conversations = conversationsSnapshot.docs.toList();
      conversations.sort((a, b) {
        final aTime = a.data()['lastMessageTimestamp'] as Timestamp?;
        final bTime = b.data()['lastMessageTimestamp'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      // Per ogni conversazione, carica gli ultimi messaggi
      for (final convDoc in conversations) {
        final messagesSnapshot = await _firestore
            .collection('chats')
            .doc(convDoc.id)
            .collection('messages')
            .orderBy('lastMessageTimestamp', descending: true)
            .limit(50) // Limita a 50 messaggi per conversazione
            .get();

        for (final msgDoc in messagesSnapshot.docs) {
          final messageData = msgDoc.data();
          messageData['conversationId'] = convDoc.id;
          messageData['messageId'] = msgDoc.id;
          allMessages.add(messageData);
        }
      }

      print('Caricati ${allMessages.length} messaggi chat');
      return allMessages;
    } catch (e) {
      print('Errore nel caricamento messaggi chat: $e');
      return [];
    }
  }

  /// Carica le notifiche dell'utente
  Future<List<Map<String, dynamic>>> _loadNotifiche(String userId) async {
    try {
      print('Caricamento notifiche per utente: $userId');

      // Query semplificata per evitare errori di indici
      final notificheSnapshot = await _firestore
          .collection('notifiche')
          .where('userId', isEqualTo: userId)
          .get(); // Rimuovo orderBy che richiede indice composto

      final notifiche = notificheSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Ordino in memoria per timestamp
      notifiche.sort((a, b) {
        final aTime = a['timestamp'] as Timestamp?;
        final bTime = b['timestamp'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      // Limito alle ultime 100 notifiche
      final notificheLimitate = notifiche.take(100).toList();

      print('Caricate ${notificheLimitate.length} notifiche');
      return notificheLimitate;
    } catch (e) {
      print('Errore nel caricamento notifiche: $e');
      return [];
    }
  }

  /// Carica i dati per l'admin (include tutti i dati del sistema)
  Future<Map<String, dynamic>> loadAdminData(String adminUserId) async {
    try {
      print('Caricamento dati admin per: $adminUserId');

      final results = await Future.wait([
        loadAllUserData(adminUserId), // Dati dell'admin stesso
        _loadAllUsers(), // Tutti gli utenti
        _loadAllMovimenti(), // Tutti i movimenti del sistema
        _loadOrderHistory(), // Storico ordini
      ]);

      final adminUserData = results[0] as Map<String, dynamic>;
      final allUsers = results[1] as List<User>;
      final allMovimenti = results[2] as List<Movimento>;
      final orderHistory = results[3] as List<Map<String, dynamic>>;

      final adminData = {
        ...adminUserData, // Include tutti i dati dell'admin
        'allUsers': allUsers,
        'allMovimenti': allMovimenti,
        'orderHistory': orderHistory,
      };

      print('Caricamento dati admin completato:');
      print('- Utenti totali: ${allUsers.length}');
      print('- Movimenti totali: ${allMovimenti.length}');
      print('- Ordini: ${orderHistory.length}');

      return adminData;
    } catch (e) {
      print('Errore nel caricamento dati admin: $e');
      return {};
    }
  }

  /// Carica tutti gli utenti (solo per admin)
  Future<List<User>> _loadAllUsers() async {
    try {
      final usersSnapshot = await _firestore
          .collection('utenti')
          .orderBy('nome')
          .get();

      return usersSnapshot.docs
          .map((doc) => User.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Errore nel caricamento di tutti gli utenti: $e');
      return [];
    }
  }

  /// Carica tutti i movimenti (solo per admin)
  Future<List<Movimento>> _loadAllMovimenti() async {
    try {
      final movimentiSnapshot = await _firestore
          .collection('movimenti')
          .orderBy('data', descending: true)
          .limit(1000) // Limita ai 1000 movimenti più recenti
          .get();

      return movimentiSnapshot.docs
          .map((doc) => Movimento.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Errore nel caricamento di tutti i movimenti: $e');
      return [];
    }
  }

  /// Carica lo storico degli ordini
  Future<List<Map<String, dynamic>>> _loadOrderHistory() async {
    try {
      final ordersSnapshot = await _firestore
          .collection('ordinazioni')
          .orderBy('timestamp', descending: true)
          .limit(500)
          .get();

      return ordersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Errore nel caricamento storico ordini: $e');
      return [];
    }
  }

  /// Aggiorna i dati utente e sincronizza con Firestore
  Future<bool> updateUserData(User user) async {
    try {
      await _firestore
          .collection('utenti')
          .doc(user.uid)
          .update(user.toMap());

      print('Dati utente aggiornati: ${user.email}');
      return true;
    } catch (e) {
      print('Errore nell\'aggiornamento dati utente: $e');
      return false;
    }
  }
}
