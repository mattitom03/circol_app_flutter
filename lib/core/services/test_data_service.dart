import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movimento.dart';
import '../models/evento.dart';
import '../models/product.dart';

class TestDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crea dati di test per un utente
  Future<void> createTestData(String userId) async {
    print('🔄 Creazione dati di test per utente: $userId');

    try {
      await Future.wait([
        _createTestMovimenti(userId),
        _createTestEventi(userId),
        _createTestProducts(),
      ]);
      print('✅ Dati di test creati con successo!');
    } catch (e) {
      print('❌ Errore nella creazione dati di test: $e');
    }
  }

  /// Crea movimenti di test
  Future<void> _createTestMovimenti(String userId) async {
    final movimentiTest = [
      Movimento(
        id: '1',
        importo: 50.0,
        descrizione: 'Ricarica iniziale',
        data: DateTime.now().subtract(const Duration(days: 10)),
        tipo: 'ricarica',
        userId: '',
      ),
      Movimento(
        id: '2',
        importo: -15.50,
        descrizione: 'Acquisto bar - Aperitivo',
        data: DateTime.now().subtract(const Duration(days: 8)),
        tipo: 'pagamento',
        userId: '',
      ),
      Movimento(
        id: '3',
        importo: -8.00,
        descrizione: 'Quota evento - Torneo ping pong',
        data: DateTime.now().subtract(const Duration(days: 5)),
        tipo: 'pagamento',
        userId: '',
      ),
      Movimento(
        id: '4',
        importo: 25.0,
        descrizione: 'Ricarica da app',
        data: DateTime.now().subtract(const Duration(days: 3)),
        tipo: 'ricarica',
        userId: '',
      ),
      Movimento(
        id: '5',
        importo: -12.30,
        descrizione: 'Pranzo - Menu del giorno',
        data: DateTime.now().subtract(const Duration(days: 1)),
        tipo: 'pagamento',
        userId: '',
      ),
    ];

    for (final movimento in movimentiTest) {
      final movimentoData = movimento.toMap();
      movimentoData['userId'] = userId;

      await _firestore.collection('movimenti').add(movimentoData);
    }

    print('📊 Creati ${movimentiTest.length} movimenti di test');
  }

  /// Crea eventi di test
  Future<void> _createTestEventi(String userId) async {
    final eventiTest = [
      Evento(
        id: '1',
        nome: 'Torneo di Tennis',
        descrizione: 'Torneo mensile di tennis. Iscrizioni aperte a tutti i soci.',
        dataInizio: DateTime.now().add(const Duration(days: 7)),
        dataFine: DateTime.now().add(const Duration(days: 7, hours: 4)),
        luogo: 'Campo da tennis del circolo',
        quota: 15.0,
        maxPartecipanti: 16,
        partecipanti: [userId],
        organizzatore: 'admin123',
        dataCreazione: DateTime.now().subtract(const Duration(days: 15)),
        isPublico: true,
      ),
      Evento(
        id: '2',
        nome: 'Cena Sociale',
        descrizione: 'Cena sociale con menù degustazione dello chef. Prenotazione obbligatoria.',
        dataInizio: DateTime.now().add(const Duration(days: 14)),
        dataFine: DateTime.now().add(const Duration(days: 14, hours: 3)),
        luogo: 'Sala ristorante',
        quota: 35.0,
        maxPartecipanti: 50,
        partecipanti: [],
        organizzatore: 'admin123',
        dataCreazione: DateTime.now().subtract(const Duration(days: 20)),
        isPublico: true,
      ),
      Evento(
        id: '3',
        nome: 'Lezione di Yoga',
        descrizione: 'Lezione di yoga per tutti i livelli con istruttore certificato.',
        dataInizio: DateTime.now().add(const Duration(days: 2)),
        dataFine: DateTime.now().add(const Duration(days: 2, hours: 1)),
        luogo: 'Sala polivalente',
        quota: 10.0,
        maxPartecipanti: 20,
        partecipanti: [userId],
        organizzatore: 'admin123',
        dataCreazione: DateTime.now().subtract(const Duration(days: 5)),
        isPublico: true,
      ),
      Evento(
        id: '',
        nome: 'Torneo di Calcetto',
        descrizione: 'Torneo amichevole di calcetto tra soci',
        dataInizio: DateTime.now().add(const Duration(days: 7)),
        luogo: 'Campo sportivo del circolo',
        partecipanti: [],
        organizzatore: userId,
        maxPartecipanti: 20,
        quota: 10.0,
        dataCreazione: DateTime.now(),
        isPublico: true,
      ),
      Evento(
        id: '',
        nome: 'Serata Pizza',
        descrizione: 'Serata conviviale con pizza per tutti i soci',
        dataInizio: DateTime.now().add(const Duration(days: 14)),
        luogo: 'Sala del circolo',
        partecipanti: [],
        organizzatore: userId,
        maxPartecipanti: 50,
        quota: 15.0,
        dataCreazione: DateTime.now(),
        isPublico: true,
      ),
      Evento(
        id: '',
        nome: 'Corso di Cucina',
        descrizione: 'Corso base di cucina italiana con chef professionista',
        dataInizio: DateTime.now().add(const Duration(days: 21)),
        luogo: 'Cucina del circolo',
        partecipanti: [],
        organizzatore: userId,
        maxPartecipanti: 15,
        quota: 25.0,
        dataCreazione: DateTime.now(),
        isPublico: true,
      ),
    ];

    for (final evento in eventiTest) {
      await _firestore.collection('eventi').add(evento.toMap());
    }

    print('📅 Creati ${eventiTest.length} eventi di test');
  }

  /// Crea prodotti di test
  Future<void> _createTestProducts() async {
    final prodottiTest = [
      Product(
        id: '1',
        nome: 'Aperitivo Spritz',
        descrizione: 'Aperitivo Spritz con olive e patatine',
        prezzo: 8.50,
        ordinabile: true,
        numeroPezzi: 100,
      ),
      Product(
        id: '2',
        nome: 'Panino Club',
        descrizione: 'Panino con pollo, lattuga, pomodoro e maionese',
        prezzo: 12.00,
        ordinabile: true,
        numeroPezzi: 50,
      ),
      Product(
        id: '3',
        nome: 'Caffè Espresso',
        descrizione: 'Caffè espresso italiano',
        prezzo: 1.50,
        ordinabile: true,
        numeroPezzi: 200,
      ),
      Product(
        id: '4',
        nome: 'Insalata Caesar',
        descrizione: 'Insalata Caesar con pollo grigliato e crostini',
        prezzo: 14.50,
        ordinabile: true,
        numeroPezzi: 30,
      ),
      Product(
        id: '5',
        nome: 'Birra Media',
        descrizione: 'Birra alla spina media 0.4L',
        prezzo: 5.00,
        ordinabile: true,
        numeroPezzi: 150,
      ),
    ];

    for (final prodotto in prodottiTest) {
      await _firestore.collection('products').add(prodotto.toMap());
    }

    print('🛍️ Creati ${prodottiTest.length} prodotti di test');
  }

  /// Verifica se esistono già dati di test
  Future<bool> hasTestData(String userId) async {
    try {
      final movimenti = await _firestore
          .collection('movimenti')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return movimenti.docs.isNotEmpty;
    } catch (e) {
      print('Errore nella verifica dati di test: $e');
      return false;
    }
  }

  /// Elimina tutti i dati di test
  Future<void> clearTestData(String userId) async {
    try {
      // Elimina movimenti dell'utente
      final movimenti = await _firestore
          .collection('movimenti')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in movimenti.docs) {
        await doc.reference.delete();
      }

      // Elimina eventi (solo se creati per test)
      final eventi = await _firestore
          .collection('eventi')
          .get();

      for (final doc in eventi.docs) {
        await doc.reference.delete();
      }

      // Elimina prodotti
      final prodotti = await _firestore
          .collection('products')
          .get();

      for (final doc in prodotti.docs) {
        await doc.reference.delete();
      }

      print('🧹 Dati di test eliminati');
    } catch (e) {
      print('Errore nell\'eliminazione dati di test: $e');
    }
  }
}
