# Relazione Tecnica del Progetto CircolApp Flutter

## Introduzione

Questa relazione presenta un'analisi completa del progetto CircolApp, un'applicazione Flutter per la gestione di un circolo sociale. L'applicazione implementa un sistema completo che include autenticazione degli utenti, gestione di eventi, prodotti, pagamenti, chat e funzionalità amministrative. La struttura del codice è organizzata secondo il pattern architetturale MVVM (Model-View-ViewModel), garantendo separazione delle responsabilità e manutenibilità del codice.

---

## CORE - Modelli Dati (lib/core/models/)

### models.dart

**Scopo e contesto**
Questo file funge da punto centrale di importazione ed esportazione per tutti i modelli dell'applicazione, definendo anche gli stati dell'autenticazione attraverso classi sealed che implementano il pattern State.

**Campi principali**
- Nessun campo diretto, ma esporta tutti i modelli dell'app
- Definisce la gerarchia AuthResult per rappresentare gli stati dell'autenticazione

**Metodi e funzionalità**
Il file non contiene metodi specifici, ma definisce le seguenti classi di stato:
- `AuthIdle()`: rappresenta lo stato iniziale dell'autenticazione
- `AuthLoading()`: indica che è in corso un'operazione di autenticazione
- `AuthSuccess()`: contiene i dati dell'utente autenticato con successo
- `AuthError()`: rappresenta un errore nell'autenticazione con relativo messaggio

### user_role.dart

**Scopo e contesto**
Definisce un enum per gestire i diversi ruoli utente nell'applicazione, fornendo metodi per la conversione tra stringhe e enum per la compatibilità con il database.

**Campi principali**
- `user`: ruolo utente standard con permessi limitati
- `admin`: ruolo amministratore con permessi elevati  
- `unknown`: ruolo sconosciuto utilizzato come stato iniziale

**Metodi e funzionalità**
- `fromString(String? roleString)`: converte una stringa nel corrispondente UserRole
- `toDisplayString()`: converte l'enum in stringa per il salvataggio nel database

### user.dart

**Scopo e contesto** 
Definisce il modello dati principale per rappresentare un utente dell'applicazione, includendo informazioni personali, stato della tessera associativa e saldo economico.

**Campi principali**
- `uid`, `username`, `nome`, `email`, `displayName`: informazioni identificative dell'utente
- `ruolo`: ruolo dell'utente (user/admin) di tipo UserRole
- `saldo`: saldo economico dell'utente rappresentato come double
- `movimenti`: lista dei movimenti economici dell'utente
- `hasTessera`, `numeroTessera`, `dataScadenzaTessera`: gestione tessera associativa
- `richiestaRinnovoInCorso`: flag per tracciare richieste di rinnovo tessera
- `photoUrl`, `telefono`: informazioni aggiuntive opzionali

**Metodi e funzionalità**
- `fromMap(Map<String, dynamic> map)`: factory per creare User da Map (Firebase/JSON)
- `toMap()`: converte il User in Map per il salvataggio su database
- `copyWith()`: crea una copia del User con campi modificati
- `toString()`: rappresentazione stringa per debug
- `operator ==` e `hashCode`: confronto oggetti basato su uid

### movimento.dart

**Scopo e contesto**
Rappresenta le transazioni economiche degli utenti, permettendo di tracciare ricariche, pagamenti e movimenti di denaro all'interno dell'applicazione.

**Campi principali**
- `id`: identificatore univoco del movimento
- `importo`: valore economico della transazione (double)
- `descrizione`: descrizione testuale del movimento
- `data`: timestamp della transazione
- `tipo`: categoria del movimento (ricarica/pagamento/altro)
- `userId`: identificatore dell'utente proprietario del movimento

**Metodi e funzionalità**
- `fromMap(Map<String, dynamic> map, {String? documentId})`: factory per creare Movimento da Map
- `toMap()`: converte il Movimento in Map per Firestore
- `_convertData(dynamic dateData)`: helper privata per convertire vari tipi di data

### product.dart

**Scopo e contesto**
Modella i prodotti vendibili all'interno dell'applicazione, incluse informazioni su disponibilità, prezzi e stato dell'inventario.

**Campi principali**
- `id`, `nome`, `descrizione`: identificazione e descrizione del prodotto
- `prezzo`: prezzo del prodotto come double
- `numeroPezzi`: quantità disponibile in inventario
- `ordinabile`: flag booleano per abilitare/disabilitare la vendita
- `imageUrl`: URL opzionale dell'immagine del prodotto

**Metodi e funzionalità**
- `isAvailable`: getter che verifica se il prodotto è disponibile per l'acquisto
- `isEsaurito`: getter che indica se il prodotto è esaurito
- `immagine`, `importo`: getter per compatibilità con codice legacy
- `fromMap(Map<String, dynamic> map, {String? documentId})`: factory per creare Product da Map
- `toMap()`: converte Product in Map per Firestore
- `copyWith()`: crea copia del prodotto con campi modificati
- `_timestampToDateTime(dynamic timestamp)`: helper per conversione timestamp
- `operator ==`, `hashCode`, `toString()`: implementazioni standard per confronti e debug

### evento.dart

**Scopo e contesto**
Rappresenta gli eventi organizzati dal circolo, gestendo informazioni come date, partecipanti, disponibilità posti e stato dell'evento.

**Campi principali**
- `id`, `nome`, `descrizione`: identificazione e descrizione evento
- `dataInizio`, `dataFine`: periodo temporale dell'evento
- `luogo`: località dove si svolge l'evento
- `partecipanti`: lista degli ID degli utenti iscritti
- `organizzatore`: ID dell'utente organizzatore
- `maxPartecipanti`: limite massimo di partecipanti (0 = illimitato)
- `isPublico`: visibilità dell'evento
- `dataCreazione`: timestamp di creazione
- `immagine`: URL immagine evento
- `metadata`: dati aggiuntivi come Map
- `quota`: costo di partecipazione opzionale

**Metodi e funzionalità**
- `isFuturo`: getter che verifica se l'evento è programmato nel futuro
- `isAttivo`: getter che indica se l'evento è attualmente in corso
- `isTerminato`: getter per eventi conclusi
- `haPostiDisponibili`: verifica disponibilità posti
- `postiRimanenti`: calcola posti rimanenti
- `data`, `ora`: getter formattati per compatibilità UI
- `fromMap(Map<String, dynamic> map, {String? documentId})`: factory da Map
- `toMap()`: conversione in Map per Firestore
- `copyWith()`: crea copia con campi modificati
- `_timestampToDateTime(dynamic timestamp)`: helper conversione timestamp
- `operator ==`, `hashCode`, `toString()`: implementazioni standard

### chat_message.dart

**Scopo e contesto**
Rappresenta un singolo messaggio all'interno del sistema di chat dell'applicazione, supportando messaggi testuali e immagini.

**Campi principali**
- `id`: identificatore univoco del messaggio
- `senderId`: ID dell'utente che ha inviato il messaggio
- `text`: contenuto testuale del messaggio
- `imageUrl`: URL opzionale per messaggi con immagini
- `timestamp`: data e ora di invio del messaggio

**Metodi e funzionalità**
- `fromMap(Map<String, dynamic> map, String id)`: factory per creare ChatMessage da Map
- `toMap()`: converte ChatMessage in Map per il salvataggio su Firestore

### chat_conversation.dart

**Scopo e contesto**
Rappresenta una conversazione di chat tra più utenti, mantenendo informazioni sull'ultimo messaggio per ottimizzare la visualizzazione delle liste di conversazioni.

**Campi principali**
- `id`: identificatore univoco della conversazione
- `participants`: lista degli ID degli utenti partecipanti
- `lastMessageText`: testo dell'ultimo messaggio inviato
- `lastMessageTimestamp`: timestamp dell'ultimo messaggio

**Metodi e funzionalità**
- `fromMap(Map<String, dynamic> map, String id)`: factory per creare ChatConversation da Map

---

## CORE - Servizi (lib/core/services/)

### firestore_data_service.dart

**Scopo e contesto**
Servizio centrale per il caricamento e la gestione di tutti i dati dell'applicazione da Firestore, ottimizzando le performance attraverso caricamenti paralleli e fornendo una singola interfaccia per l'accesso ai dati.

**Campi principali**
- `_eventiService`, `_movimentiService`, `_productService`: istanze dei servizi specifici per ogni dominio
- `_firestore`: istanza di FirebaseFirestore per l'accesso diretto al database

**Metodi e funzionalità**
- `loadAllUserData(String userId)`: carica tutti i dati necessari per un utente in parallelo
- `loadAdminData(String userId)`: carica dati aggiuntivi per gli amministratori
- `_loadUserDocument(String userId)`: carica il documento utente da Firestore  
- `_loadChatMessages(String userId)`: carica messaggi di chat dell'utente
- `_loadNotifiche(String userId)`: carica notifiche dell'utente
- `loadAllUsers()`: carica tutti gli utenti (solo per admin)
- `_loadAllMovimenti()`: carica tutti i movimenti (solo per admin)
- `_loadOrderHistory()`: carica storico ordini
- `updateUserData(User user)`: aggiorna i dati utente e sincronizza con Firestore

### test_data_service.dart

**Scopo e contesto**
Servizio per la gestione di dati di test durante lo sviluppo, permettendo di popolare rapidamente il database con dati fittizi per testare le funzionalità dell'applicazione.

**Campi principali**
- `_firestore`: istanza di FirebaseFirestore per l'accesso al database

**Metodi e funzionalità**
- `createTestData(String userId)`: crea un set completo di dati di test per un utente
- `_createTestMovimenti(String userId)`: crea movimenti di test (ricariche e pagamenti)
- `_createTestEventi(String userId)`: crea eventi di test con date diverse
- `_createTestProducts()`: crea prodotti di esempio per il catalogo
- `hasTestData(String userId)`: verifica se esistono già dati di test
- `clearTestData(String userId)`: elimina tutti i dati di test

### main_screen.dart

**Scopo e contesto**
Schermata principale dell'applicazione che implementa una navigazione bottom-tab adattiva basata sul ruolo dell'utente, fornendo accesso alle diverse funzionalità attraverso fragment dedicati.

**Campi principali**
- `userRole`: ruolo dell'utente che determina le tab disponibili
- `_currentIndex`: indice della tab attualmente selezionata
- `_pageController`: controller per la gestione delle pagine

**Metodi e funzionalità**
- `build(BuildContext context)`: costruisce l'interfaccia con BottomNavigationBar
- `_getScreensForRole()`: restituisce le schermate appropriate per il ruolo utente
- `_getTabsForRole()`: costruisce le tab della navigazione basate sul ruolo
- `_onTabTapped(int index)`: gestisce il cambio di tab

---

## FEATURES - Autenticazione (lib/features/auth/)

### AuthViewModel

**Scopo e contesto**
ViewModel centrale che gestisce l'intero stato dell'autenticazione e coordina il caricamento di tutti i dati dell'applicazione, fornendo un'interfaccia reattiva per l'UI attraverso il pattern Observer.

**Campi principali**
- `_authService`: servizio per operazioni di autenticazione Firebase
- `_testDataService`, `_productService`, `_eventiService`, etc.: istanze dei vari servizi dell'applicazione
- `_authResult`: stato corrente dell'autenticazione (AuthIdle/Loading/Success/Error)
- `_currentUser`: utente attualmente autenticato
- `_currentUserRole`: ruolo dell'utente corrente
- `_allAppData`: mappa contenente tutti i dati dell'applicazione
- `_tuttiEventi`, `_eventiUtente`: liste degli eventi generali e dell'utente
- `_movimenti`: movimenti economici dell'utente
- `_prodotti`: catalogo prodotti
- `_chatMessages`, `_notifiche`: messaggi e notifiche
- `_allUsers`, `_allMovimenti`, `_orderHistory`: dati amministrativi

**Metodi e funzionalità**
- `loginUser(String email, String password)`: esegue login e carica tutti i dati utente
- `registerUser(String email, String password, String username, String nome)`: registra nuovo utente
- `initializeAuth()`: inizializza l'autenticazione controllando utente corrente
- `logout()`: effettua logout e pulisce lo stato
- `refreshAllData()`: ricarica manualmente tutti i dati
- `createTestData()`: crea dati di test per sviluppo
- `_loadAllDataFromResult(AuthSuccess result)`: carica dati nell'ViewModel dal risultato auth
- `_reloadAllData()`: ricarica dati internamente
- `_updateUserData(User updatedUser)`: aggiorna dati utente

Getter di accesso ai dati:
- `authResult`, `currentUser`, `currentUserRole`: stato autenticazione
- `isLoggedIn`, `isAdmin`, `isLoading`: flag di stato
- `tuttiEventi`, `eventiUtente`, `movimenti`: dati utente
- `prodotti`, `prodottiOrdinabili`: catalogo prodotti
- `allUsers`, `allMovimenti`: dati amministrativi
- `notificheNonLette`, `ultimiMovimenti`, `eventiFuturi`: dati filtrati
- `prodottiDisponibili`: prodotti disponibili per l'acquisto

### AuthService

**Scopo e contesto**
Servizio che gestisce tutte le operazioni di autenticazione con Firebase Authentication e coordina il caricamento dei dati utente da Firestore, implementando la logica di business per login, registrazione e gestione sessioni.

**Campi principali**
- `_firebaseAuth`: istanza di Firebase Authentication
- `_firestore`: istanza di Firestore per accesso ai documenti utente
- `_dataService`: servizio per caricamento dati completi

**Metodi e funzionalità**
- `loginUser(String email, String password)`: autentica utente e carica tutti i suoi dati
- `registerUser(String email, String password, String username, String nome)`: registra nuovo utente
- `getCurrentUserData()`: ottiene dati dell'utente corrente
- `logout()`: effettua logout da Firebase
- `assegnaTessera(String uid)`: assegna tessera a un utente
- `impostaRichiestaTessera(String uid, bool richiesta)`: gestisce richieste tessera
- `revocaTessera(String uid)`: revoca tessera utente

Proprietà di accesso:
- `authStateChanges`: stream per monitorare cambi di autenticazione
- `currentUser`: utente Firebase attualmente autenticato

### login_screen.dart e register_screen.dart

**Scopo e contesto**
Schermate per l'autenticazione degli utenti, fornendo interfacce intuitive per login e registrazione con validazione dei campi e gestione degli errori.

**Campi principali**
- Controllers per i campi di testo (email, password, username, nome)
- Chiavi per la validazione dei form
- Flag per gestire visibilità password e stato loading

**Metodi e funzionalità**
- `_login()` / `_register()`: eseguono operazioni di autenticazione
- `_showErrorDialog()`: mostra dialoghi di errore
- Validatori per i campi del form
- Gestione navigazione tra login e registrazione

---

## FEATURES - Pannello Amministrativo (lib/features/admin_panel/)

### GestioneTessereViewModel

**Scopo e contesto**
ViewModel specifico per la gestione delle tessere associative da parte degli amministratori, fornendo funzionalità per approvare richieste, assegnare e revocare tessere.

**Campi principali**
- `_dataService`: servizio per caricamento dati Firestore
- `_authService`: servizio per operazioni sulle tessere
- `_allUsers`: lista di tutti gli utenti del sistema
- `_isLoading`: flag di caricamento

**Metodi e funzionalità**
- `fetchAllUsers()`: carica lista completa utenti
- `assegnaTessera(String uid)`: assegna tessera a un utente
- `rifiutaRichiesta(String uid)`: rifiuta richiesta tessera
- `revocaTessera(String uid)`: revoca tessera esistente

### gestione_tessere_screen.dart

**Scopo e contesto**
Interfaccia amministrativa per la gestione visuale delle tessere associative, permettendo agli admin di visualizzare richieste e gestire lo stato delle tessere.

**Metodi e funzionalità**
- Visualizzazione lista utenti con stato tessere
- Bottoni per azioni di gestione (approva/rifiuta/revoca)
- Filtri per visualizzare diversi stati tessere
- Refresh pull-to-refresh per aggiornare dati

---

## FEATURES - Cassa Registratore (lib/features/cash_register/)

### RiscuotiViewModel

**Scopo e contesto**
ViewModel per la gestione delle transazioni di vendita alla cassa, permettendo di selezionare utenti, scansionare prodotti e finalizzare pagamenti con aggiornamento automatico di saldi e inventario.

**Campi principali**
- `_selectedUser`: utente selezionato per la transazione
- `_scannedProducts`: lista prodotti scansionati nel carrello
- `total`: totale calcolato della transazione

**Metodi e funzionalità**
- `setUser(User user)`: imposta utente per la transazione
- `addProduct(Product product)`: aggiunge prodotto al carrello
- `clearCart()`: pulisce carrello per nuova transazione
- `finalizeTransaction()`: completa vendita aggiornando saldo e inventario

### Schermate della cassa

**Scopo e contesto**
Le schermate `cassa_screen.dart`, `ricarica_screen.dart`, `riscuoti_screen.dart` e `scanner_screen.dart` forniscono un'interfaccia completa per le operazioni di cassa: ricarica saldi utente, vendita prodotti e scansione codici a barre.

**Funzionalità principali**
- Interfaccia per operazioni di ricarica credito utenti
- Sistema di scansione prodotti con lettore barcode/QR
- Gestione transazioni con selezione utente e calcolo totali
- Integrazione con sistema di pagamento e aggiornamento inventario

---

## FEATURES - Chat (lib/features/chat/)

### ChatService

**Scopo e contesto**
Servizio per la gestione del sistema di messaggistica in tempo reale, implementando conversazioni tra utenti con supporto per messaggi testuali e immagini.

**Campi principali**
- `_firestore`: istanza Firestore per persistenza messaggi

**Metodi e funzionalità**
- `getConversationsStream(String userId)`: stream conversazioni utente in tempo reale
- `getMessagesStream(String conversationId)`: stream messaggi di una conversazione
- `sendMessage(String conversationId, ChatMessage message)`: invia messaggio
- `startOrGetConversation(String currentUserId, String otherUserId)`: avvia o trova conversazione

### ChatViewModel, ConversationViewModel, NewChatViewModel

**Scopo e contesto**
ViewModels per la gestione dello stato delle diverse schermate di chat, fornendo reattività per liste conversazioni, messaggi e creazione nuove chat.

**Funzionalità principali**
- Gestione stato liste conversazioni
- Invio e ricezione messaggi in tempo reale  
- Selezione utenti per nuove conversazioni
- Gestione upload immagini nei messaggi

### Schermate Chat

**Scopo e contesto**
Le schermate `chat_list_screen.dart`, `conversation_screen.dart` e `new_chat_user_list_screen.dart` implementano un sistema di chat completo con liste conversazioni, visualizzazione messaggi e selezione contatti.

---

## FEATURES - Eventi (lib/features/events/)

### EventiService

**Scopo e contesto**
Servizio dedicato alla gestione degli eventi del circolo, implementando logica per partecipazioni, controlli disponibilità e gestione liste partecipanti.

**Campi principali**
- `_firestore`: istanza Firestore
- `_collectionPath`: percorso collezione eventi ('eventi')

**Metodi e funzionalità**
- `getAllEventi()`: recupera tutti gli eventi disponibili
- `partecipaEvento(String eventId, User user)`: iscrive utente a evento
- `getPartecipanti(String eventId)`: ottiene lista partecipanti per admin
- `checkPartecipazione(String eventId, String userId)`: verifica se utente partecipa
- `annullaPartecipazione(String eventId, String userId)`: annulla partecipazione utente

### Schermate Eventi

**Scopo e contesto**
Le schermate `eventi_fragment.dart`, `admin_event_details_screen.dart` e `user_event_details_screen.dart` forniscono interfacce distinte per visualizzazione eventi, dettagli amministrativi e iscrizione utenti.

**Funzionalità principali**
- Lista eventi con filtri e ricerca
- Dettagli evento con informazioni complete
- Sistema iscrizioni con controllo disponibilità
- Interfaccia admin per gestione partecipanti

---

## FEATURES - Feedback (lib/features/feedback/)

### FeedbackService

**Scopo e contesto**
Servizio per la gestione del sistema di feedback degli utenti, permettendo invio suggerimenti e gestione lettura da parte degli amministratori.

**Campi principali**
- `_firestore`: istanza Firestore
- `_collectionPath`: percorso collezione feedback

**Metodi e funzionalità**
- `getTuttiFeedback()`: recupera tutti i feedback ordinati per data
- `segnaComeLetto(String feedbackId)`: marca feedback come letto
- `inviaFeedback(Map<String, dynamic> feedbackData)`: invia nuovo feedback

### FeedbackViewModel

**Scopo e contesto**
ViewModel per la gestione dello stato dei feedback, fornendo reattività per invio e visualizzazione amministrativa.

**Funzionalità principali**
- Invio feedback con validazione campi
- Gestione stato caricamento
- Visualizzazione feedback per admin

### feedback_screen.dart

**Scopo e contesto**
Interfaccia per l'invio di feedback da parte degli utenti, con form strutturato per raccolta suggerimenti e segnalazioni.

---

## FEATURES - Home (lib/features/home/)

### home_fragment.dart

**Scopo e contesto**
Fragment principale che funge da dashboard dell'applicazione, mostrando un riepilogo delle informazioni più rilevanti per l'utente come saldo, eventi futuri e notifiche recenti.

**Funzionalità principali**
- Visualizzazione saldo corrente utente
- Ultimi movimenti economici
- Eventi futuri a cui l'utente è iscritto
- Notifiche non lette
- Quick actions per operazioni frequenti

---

## FEATURES - Movimenti (lib/features/movements/)

### MovimentiService

**Scopo e contesto**
Servizio specifico per la gestione dei movimenti economici degli utenti, implementando operazioni di lettura e scrittura nella struttura dati ottimizzata di Firestore.

**Campi principali**
- `_firestore`: istanza Firestore per accesso database

**Metodi e funzionalità**
- `getMovimentiUtente(String userId)`: recupera ultimi movimenti dalla sottocollezione utente
- `addMovimento(String userId, Movimento movimento)`: aggiunge nuovo movimento

### movimenti_screen.dart

**Scopo e contesto**
Schermata per la visualizzazione dello storico completo dei movimenti economici dell'utente con funzionalità di filtro e ricerca.

**Funzionalità principali**
- Lista cronologica movimenti
- Filtri per tipo movimento (ricariche/pagamenti)
- Visualizzazione saldo corrente
- Dettagli transazioni

---

## FEATURES - Ordini (lib/features/orders/)

### OrdersService

**Scopo e contesto**
Servizio per la gestione degli ordini di prodotti, implementando creazione ed eliminazione ordini nel sistema.

**Campi principali**
- `_firestore`: istanza Firestore
- `_collectionPath`: percorso collezione ordinazioni

**Metodi e funzionalità**
- `eliminaOrdine(String orderId)`: elimina ordine dal database
- `creaOrdine(Map<String, dynamic> orderData)`: crea nuovo ordine

### order_screen.dart

**Scopo e contesto**
Interfaccia per la visualizzazione e gestione degli ordini, permettendo agli utenti di vedere ordini effettuati e agli admin di gestire tutti gli ordini.

---

## FEATURES - Pagamenti (lib/features/payment/)

### Schermate Pagamento

**Scopo e contesto**
Le schermate `pagamento_screen.dart`, `product_list_ordering_screen.dart`, `product_order_screen.dart` e `qr_code_screen.dart` implementano un sistema completo di ordinazione e pagamento prodotti.

**Funzionalità principali**
- Selezione prodotti da catalogo
- Carrello con calcolo totali
- Sistema pagamento con saldo utente
- Generazione QR code per ordini
- Conferma e storico ordini

---

## FEATURES - Prodotti (lib/features/products/)

### ProductService

**Scopo e contesto**
Servizio completo per la gestione del catalogo prodotti, implementando tutte le operazioni CRUD, gestione inventario e upload immagini.

**Campi principali**
- `_firestore`: istanza Firestore
- `_collectionPath`: percorso collezione products

**Metodi e funzionalità**
- `getAllProducts()`: recupera tutti i prodotti
- `getProductsByCategory(String categoria)`: filtra prodotti per categoria
- `addProduct(Product product)`: aggiunge nuovo prodotto
- `updateProduct(Product product)`: aggiorna prodotto esistente
- `deleteProduct(String productId)`: elimina prodotto
- `updateProductStock(String productId, int newStock)`: aggiorna quantità
- `uploadProductImage(File imageFile, String productId)`: carica immagine prodotto
- `getProductsStream()`: stream prodotti in tempo reale
- `getProductById(String productId)`: recupera singolo prodotto
- `updateMultipleProductsStock(Map<Product, int> itemsSold)`: aggiorna stock multipli

### AddProductViewModel

**Scopo e contesto**
ViewModel per la gestione dell'aggiunta di nuovi prodotti al catalogo, con supporto per upload immagini e validazione dati.

**Campi principali**
- `_productService`: servizio prodotti
- `_isLoading`: stato caricamento
- `_selectedImage`: immagine selezionata

**Metodi e funzionalità**
- `selectImage()`: seleziona immagine da galleria
- `addProduct(Product product)`: aggiunge prodotto con immagine
- `uploadImage(File imageFile, String productId)`: carica immagine su storage

### Schermate Prodotti

**Scopo e contesto**
Le schermate `add_product_screen.dart`, `edit_product_screen.dart` e `product_catalog_fragment.dart` forniscono interfacce complete per gestione catalogo prodotti.

**Funzionalità principali**
- Catalogo prodotti con ricerca e filtri
- Form aggiunta/modifica prodotti
- Upload immagini prodotti
- Gestione inventario e disponibilità

---

## FEATURES - Profilo (lib/features/profile/)

### profilo_fragment.dart

**Scopo e contesto**
Fragment per la gestione del profilo utente, mostrando informazioni personali, stato tessera associativa e permettendo modifiche ai dati.

**Funzionalità principali**
- Visualizzazione dati profilo
- Stato e scadenza tessera associativa
- Modifica informazioni personali
- Logout dall'applicazione

---

## FILE PRINCIPALI DI CONFIGURAZIONE

### main.dart

**Scopo e contesto**
Punto di ingresso dell'applicazione che configura Firebase, inizializza l'app Flutter e gestisce il routing basato sullo stato di autenticazione.

**Componenti principali**
- `CircolApp`: widget principale con configurazione tema Material3
- `AuthWrapper`: gestisce navigazione condizionale basata su autenticazione
- Inizializzazione Firebase e localizzazione italiana

**Funzionalità principali**
- Configurazione Firebase con gestione errori
- Setup Provider per gestione stato
- Tema personalizzato con Material Design 3
- Routing condizionale login/main screen

### firebase_options.dart

**Scopo e contesto**
Configurazione automatica delle opzioni Firebase per le diverse piattaforme (Android, iOS, Web), generata da FlutterFire CLI.

### Fragment aggiuntivi

**Scopo e contesto**
I fragment `chat_fragment.dart`, `notifiche_fragment.dart` e `qr_code_fragment.dart` nella directory `screens/` forniscono funzionalità aggiuntive per navigazione bottom-tab.

---

## CONCLUSIONE

Il progetto CircolApp rappresenta un'applicazione Flutter completa e ben strutturata per la gestione di un circolo sociale. L'architettura adottata segue il pattern MVVM con separazione chiara delle responsabilità:

- **Models**: definiscono la struttura dati con supporto per serializzazione Firestore
- **Services**: implementano la logica di business e comunicazione con Firebase
- **ViewModels**: gestiscono stato dell'UI e coordinano servizi
- **Views/Screens**: implementano interfacce utente reattive

L'applicazione integra funzionalità avanzate come chat in tempo reale, sistema di pagamenti, gestione eventi e pannello amministrativo, utilizzando Firebase come backend per autenticazione, database e storage. La struttura modulare facilita manutenzione ed estensioni future, mentre l'uso del pattern Provider garantisce gestione efficiente dello stato reattivo.
