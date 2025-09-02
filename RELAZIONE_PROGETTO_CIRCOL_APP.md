# Relazione di Analisi del Progetto CircolApp Flutter

## Introduzione

Il progetto CircolApp rappresenta una conversione di un'applicazione Android nativa in Flutter, progettata per gestire le attività di un circolo. L'applicazione implementa un sistema completo di gestione utenti, eventi, prodotti, pagamenti e comunicazioni attraverso un'architettura modulare basata sul pattern MVVM (Model-View-ViewModel).

L'architettura del progetto è organizzata in due cartelle principali all'interno di `lib/`: `core` che contiene i modelli di dati fondamentali e i servizi centrali, e `features` che raggruppa le funzionalità dell'applicazione per area tematica. Ogni feature include le proprie schermate (screen), ViewModel per la logica di business, e servizi per l'accesso ai dati.

---

## Analisi dei File per Cartelle

### Cartella `lib/core/models/`

#### File: `models.dart`

**Scopo e contesto**  
Funge da punto di esportazione centralizzato per tutti i modelli dell'applicazione, definendo inoltre le classi fondamentali per la gestione dello stato di autenticazione. Questo file facilita l'importazione dei modelli in altre parti dell'applicazione e definisce una gerarchia di classi per rappresentare i diversi stati del processo di autenticazione.

**Campi principali**  
- Esportazioni: User, UserRole, Movimento, Evento, Product per l'accesso unificato ai modelli.
- AuthResult: classe astratta base per rappresentare lo stato dell'autenticazione.
- AuthSuccess: contiene user (User), userRole (UserRole) e allData (Map<String, dynamic>) con tutti i dati dell'utente.
- AuthError: contiene message (String) con il messaggio di errore.

**Metodi e funzionalità**  
- Definisce le classi sealed per lo stato dell'autenticazione (AuthIdle, AuthLoading, AuthSuccess, AuthError).
- Fornisce un pattern type-safe per gestire i diversi stati del processo di login e registrazione.
- Centralizza l'accesso a tutti i modelli dell'applicazione attraverso le export.

---

#### File: `user_role.dart`

**Scopo e contesto**  
Definisce l'enumerazione per i ruoli utente nell'applicazione, gestendo la conversione tra stringhe e valori enum. Questo sistema permette di distinguere tra utenti normali, amministratori e stati indeterminati, fornendo un controllo granulare sui permessi.

**Campi principali**  
- user: ruolo per utenti standard con permessi limitati.
- admin: ruolo per utenti amministratori con permessi elevati.  
- unknown: ruolo sconosciuto utilizzato come stato iniziale o per gestire casi imprevisti.

**Metodi e funzionalità**  
- fromString(String?): converte una stringa (come "ADMIN" o "USER") nel corrispondente UserRole, ritornando unknown per valori non riconosciuti.
- toDisplayString(): converte l'enum in una stringa leggibile per l'interfaccia utente.
- Gestisce la conversione case-insensitive delle stringhe in input.

---

#### File: `user.dart`

**Scopo e contesto**  
Rappresenta il modello dati principale per gli utenti dell'applicazione, includendo informazioni personali, ruolo, saldo e storico movimenti. Il modello integra funzionalità per la gestione delle tessere associative e supporta la serializzazione con Firestore.

**Campi principali**  
- uid, username, nome, email, displayName: identificativi e informazioni personali dell'utente.
- ruolo (UserRole): determina i permessi dell'utente nell'applicazione.
- saldo (double): credito disponibile per acquisti e servizi.
- movimenti (List<Movimento>): storico delle transazioni finanziarie.
- hasTessera, numeroTessera, dataScadenzaTessera: gestione tessere associative.
- richiestaRinnovoInCorso: flag per tracciare le richieste di rinnovo tessera pendenti.

**Metodi e funzionalità**  
- fromMap(Map<String, dynamic>): costruisce un'istanza User dai dati di Firestore, gestendo la conversione dei tipi e i valori null.
- toMap(): serializza l'utente in una Map per il salvataggio su Firestore, convertendo appropriatamente le date in Timestamp.
- copyWith(): crea una copia dell'utente modificando solo i campi specificati, utile per gli aggiornamenti parziali.
- Implementa equals e hashCode basati sull'uid per confronti efficienti.

---

#### File: `movimento.dart`

**Scopo e contesto**  
Modella le transazioni finanziarie degli utenti, supportando diversi tipi di operazioni come ricariche, pagamenti e rimborsi. La classe gestisce la conversione robusta delle date da diversi formati e garantisce la compatibilità con Firestore.

**Campi principali**  
- id: identificativo univoco del movimento.
- importo (double): valore della transazione, negativo per pagamenti, positivo per ricariche.
- descrizione (String): descrizione testuale dell'operazione.
- data (DateTime): timestamp dell'operazione.
- tipo (String): categoria del movimento (ricarica, pagamento, rimborso).
- userId (String): associazione con l'utente proprietario.

**Metodi e funzionalità**  
- fromMap(Map<String, dynamic>, {String? documentId}): costruisce un Movimento da dati Firestore, utilizzando una funzione helper per convertire timestamp flessibilmente.
- toMap(): serializza il movimento per Firestore usando Timestamp per consistenza.
- _convertData(dynamic): funzione helper che gestisce la conversione di date da Timestamp, int, double o String, assicurando robustezza nella gestione dei dati.

---

#### File: `evento.dart`

**Scopo e contesto**  
Rappresenta gli eventi del circolo con tutte le informazioni necessarie per gestione, iscrizioni e partecipazione. Include logica di business per determinare stato degli eventi e disponibilità posti, supportando sia eventi pubblici che privati.

**Campi principali**  
- id, nome, descrizione: identificativo e informazioni base dell'evento.
- dataInizio, dataFine: periodo di svolgimento dell'evento.
- luogo: sede dell'evento.
- partecipanti (List<String>): lista degli utenti iscritti.
- organizzatore: responsabile dell'evento.
- maxPartecipanti: limite massimo di partecipanti, 0 per illimitato.
- isPublico: visibilità dell'evento.
- quota: costo di partecipazione opzionale.

**Metodi e funzionalità**  
- Proprietà calcolate: isFuturo, isAttivo, isTerminato determinano lo stato temporale dell'evento.
- haPostiDisponibili, postiRimanenti: gestiscono la logica di capacità massima.
- Getter di compatibilità: data, ora forniscono formato string per fragment esistenti.
- fromMap(), toMap(): serializzazione con Firestore gestendo timestamp appropriatamente.
- copyWith(): permette modifiche parziali dell'evento.
- _timestampToDateTime(): helper robusto per conversione date da diversi formati.

---

#### File: `product.dart`

**Scopo e contesto**  
Modella i prodotti vendibili nel circolo, gestendo disponibilità, ordinabilità e informazioni commerciali. Il sistema supporta la gestione dell'inventario e l'integrazione con il sistema di ordinazione.

**Campi principali**  
- id, nome, descrizione: identificazione e descrizione del prodotto.
- prezzo (double): costo unitario del prodotto.
- numeroPezzi (int): quantità disponibile in magazzino.
- ordinabile (bool): flag per abilitare/disabilitare la vendita.
- imageUrl: URL opzionale per l'immagine del prodotto.

**Metodi e funzionalità**  
- Proprietà calcolate: isAvailable combina ordinabilità e disponibilità, isEsaurito verifica se il prodotto è esaurito.
- Getter di compatibilità: immagine, importo per mantenere compatibilità con codice esistente.
- fromMap(), toMap(): gestione serializzazione con Firestore, mappando 'importo' a 'prezzo' per compatibilità.
- copyWith(): permette aggiornamenti parziali del prodotto.

---

#### File: `chat_message.dart`

**Scopo e contesto**  
Rappresenta i singoli messaggi nelle conversazioni chat dell'applicazione. Supporta messaggi testuali e immagini con timestamp precisi per l'ordinamento cronologico.

**Campi principali**  
- id: identificativo univoco del messaggio.
- senderId: ID dell'utente mittente.
- text: contenuto testuale del messaggio.
- imageUrl: URL opzionale per allegati immagine.
- timestamp: momento di invio del messaggio.

**Metodi e funzionalità**  
- fromMap(Map<String, dynamic>, String id): costruisce il messaggio da dati Firestore includendo l'ID del documento.
- toMap(): serializza per il salvataggio su Firestore convertendo timestamp appropriatamente.
- Gestione robusta dei timestamp con fallback a Timestamp.now().

---

#### File: `chat_conversation.dart`

**Scopo e contesto**  
Modella le conversazioni chat tra utenti, mantenendo metadati essenziali per l'interfaccia delle chat come ultimo messaggio e timestamp per l'ordinamento.

**Campi principali**  
- id: identificativo univoco della conversazione.
- participants (List<String>): lista degli utenti partecipanti alla conversazione.
- lastMessageText: testo dell'ultimo messaggio per l'anteprima.
- lastMessageTimestamp: timestamp per ordinamento delle conversazioni.

**Metodi e funzionalità**  
- fromMap(Map<String, dynamic>, String id): costruisce la conversazione da dati Firestore con gestione robusta dei timestamp.
- Supporta conversazioni multi-utente attraverso la lista participants.

---

### Cartella `lib/core/services/`

#### File: `firestore_data_service.dart`

**Scopo e contesto**  
Servizio centrale per la gestione dell'accesso ai dati Firestore, orchestrando il caricamento parallelo di tutti i dati necessari per l'utente. Centralizza la logica di accesso ai dati e ottimizza le performance attraverso il caricamento concorrente.

**Campi principali**  
- _eventiService, _movimentiService, _productService: istanze dei servizi specializzati per ogni tipo di dato.
- _firestore: istanza di FirebaseFirestore per accesso diretto quando necessario.

**Metodi e funzionalità**  
- loadAllUserData(String userId): carica tutti i dati utente in parallelo per ottimizzare i tempi di caricamento, restituendo una Map comprensiva di user, eventi, movimenti, prodotti, chat e notifiche.
- loadAdminData(String userId): versione specializzata per amministratori che carica dati aggiuntivi come tutti gli utenti e storico ordini completo.
- _loadUserDocument(), _loadChatMessages(), _loadNotifiche(): metodi privati specializzati per il caricamento di specifiche tipologie di dati.
- _loadOrderHistory(): carica lo storico completo delle ordinazioni per gli amministratori.
- updateUserData(User user): sincronizza le modifiche utente con Firestore.

---

#### File: `test_data_service.dart`

**Scopo e contesto**  
Servizio dedicato alla generazione di dati di test per lo sviluppo e il debugging dell'applicazione. Crea dataset rappresentativi per tutte le entità principali permettendo di testare l'applicazione con dati realistici.

**Campi principali**  
- _firestore: istanza FirebaseFirestore per la creazione diretta dei documenti di test.

**Metodi e funzionalità**  
- createTestData(String userId): coordina la creazione completa dei dati di test per un utente, chiamando i metodi specializzati per ogni tipo di entità.
- _createTestMovimenti(String userId): genera movimenti di esempio inclusi ricariche, acquisti bar e quote eventi con importi e date realistiche.
- _createTestEventi(String userId): crea eventi di test con diverse tipologie (tornei, feste, riunioni) variando date, capacità e stato pubblico/privato.
- _createTestProducts(): popola il catalogo con prodotti rappresentativi delle categorie tipiche del circolo (bevande, snack, gadget) con prezzi e disponibilità variabili.

---

### Cartella `lib/core/screen/`

#### File: `main_screen.dart`

**Scopo e contesto**  
Schermata principale dell'applicazione che implementa la navigazione a tab differenziata per ruolo utente. Gestisce la bottom navigation e organizza l'accesso alle diverse sezioni funzionali dell'app in base ai permessi dell'utente.

**Campi principali**  
- userRole: determina la configurazione dell'interfaccia e le funzionalità accessibili.
- _currentIndex: indice della tab attualmente selezionata.
- _pages: lista delle schermate associate a ogni tab.
- _bottomNavItems: elementi della bottom navigation bar.

**Metodi e funzionalità**  
- _setupNavigationBasedOnRole(): configura l'interfaccia in base al ruolo utente, creando layout diversi per admin (catalogo prodotti, eventi, cassa, ordini, profilo) e user (home, eventi, pagamenti, chat, profilo).
- Gestisce la navigazione tra le diverse sezioni mantenendo lo stato di ogni fragment.
- Implementa icone e etichette appropriate per ogni sezione funzionale.

---

### Cartella `lib/features/auth/`

#### File: `services/auth_service.dart`

**Scopo e contesto**  
Servizio core per l'autenticazione Firebase che gestisce login, registrazione e recupero dati utente. Integra Firebase Authentication con Firestore per una gestione completa dell'identità utente e carica automaticamente tutti i dati applicativi dopo l'autenticazione.

**Campi principali**  
- _firebaseAuth: istanza Firebase Authentication per operazioni di autenticazione.
- _firestore: istanza Firestore per gestione documenti utente.
- _dataService: istanza FirestoreDataService per caricamento dati completi.

**Metodi e funzionalità**  
- loginUser(String email, String password): autentica l'utente e carica automaticamente tutti i suoi dati applicativi, determinando il ruolo e restituendo AuthSuccess con dati completi o AuthError con messaggi specifici per ogni tipo di errore Firebase.
- registerUser(): crea nuovo account Firebase, verifica unicità username, crea documento Firestore con ruolo USER predefinito e carica i dati iniziali.
- assegnaTessera(), revocaTessera(), impostaRichiestaTessera(): metodi per la gestione delle tessere associative.
- logout(): termina la sessione Firebase.
- Gestione errori specifici con messaggi localizzati per ogni codice di errore Firebase.

---

#### File: `viewmodels/auth_viewmodel.dart`

**Scopo e contesto**  
ViewModel centrale dell'applicazione che gestisce lo stato di autenticazione e tutti i dati applicativi. Funge da ponte tra l'interfaccia utente e i servizi, mantenendo in memoria tutti i dati necessari per il funzionamento dell'app e notificando i cambiamenti alle viste.

**Campi principali**  
- _authService e servizi specializzati: istanze di tutti i servizi dell'applicazione.
- _authResult: stato corrente dell'autenticazione (AuthIdle/Loading/Success/Error).
- _currentUser, _currentUserRole: informazioni utente autenticato.
- _allAppData: container principale per tutti i dati applicativi.
- Dati specifici: _tuttiEventi, _eventiUtente, _movimenti, _prodotti, _chatMessages, _notifiche per utenti standard.
- Dati admin: _allUsers, _allMovimenti, _orderHistory per amministratori.

**Metodi e funzionalità**  
- initializeAuth(): verifica sessione esistente e avvia caricamento dati o mantiene stato idle.
- loginUser(email, password): gestisce processo completo di login con loading state e aggiornamento dati.
- registerUser(): gestisce registrazione con validazione e caricamento dati iniziali.
- refreshAllData(), _reloadAllData(): ricaricano tutti i dati mantenendo lo stato di autenticazione.
- createTestData(): utilizza TestDataService per generare dati di sviluppo.
- Getter convenience: eventiFuturi, prodottiDisponibili, notificheNonLette per filtrare i dati.
- _updateAppData(): aggiorna lo stato interno con i dati ricevuti dai servizi, differenziando tra utenti normali e admin.

---

#### File: `screen/login_screen.dart` e `screen/register_screen.dart`

**Scopo e contesto**  
Schermate per l'autenticazione utente che implementano interfacce intuitive per login e registrazione. Gestiscono la validazione input, gli stati di caricamento e la presentazione degli errori con feedback visivo appropriato.

**Campi principali**  
- Controller per i campi di input: email, password, username, nome.
- Validatori per assicurare format corretto email e sicurezza password.

**Metodi e funzionalità**  
- Interfacce form con validazione real-time.
- Gestione stati di caricamento con indicatori visivi.
- Navigazione automatica post-autenticazione.
- Presentazione errori con SnackBar informativi.

---

### Cartella `lib/features/chat/`

#### File: `services/chat_service.dart`

**Scopo e contesto**  
Servizio per la gestione delle comunicazioni in tempo reale tra utenti attraverso Firebase Firestore. Implementa chat one-to-one e di gruppo con aggiornamenti live e gestione persistente della cronologia messaggi.

**Campi principali**  
- _firestore: istanza Firestore per accesso alle collezioni chat e messaggi.

**Metodi e funzionalità**  
- getConversationsStream(String userId): stream in tempo reale delle conversazioni utente ordinate per ultimo messaggio.
- getMessagesStream(String conversationId): stream dei messaggi di una conversazione specifica in ordine cronologico inverso.
- sendMessage(String conversationId, ChatMessage message): invia messaggio utilizzando batch write per aggiornare atomicamente sia la collezione messaggi che i metadati della conversazione.
- createOrGetConversation(String userId, String otherUserId): crea una nuova conversazione o recupera quella esistente tra due utenti.

---

#### File: `viewmodels/chat_viewmodel.dart`

**Scopo e contesto**  
ViewModel per la gestione della lista utenti nelle chat, fornendo accesso agli utenti disponibili per iniziare nuove conversazioni e mantenendo una cache locale per performance ottimali.

**Campi principali**  
- _dataService: servizio per caricamento dati utente.
- _allUsers: lista completa degli utenti dell'applicazione.
- _isLoading: stato di caricamento per feedback UI.

**Metodi e funzionalità**  
- loadAllUsers(): carica lista completa utenti da Firestore.
- getUserById(String uid): recupera utente specifico dalla cache locale con gestione sicura dei casi non trovati.

---

#### File: `viewmodels/conversation_viewmodel.dart`

**Scopo e contesto**  
ViewModel specializzato per la gestione di una singola conversazione chat, mantenendo il flusso di messaggi in tempo reale e gestendo l'invio di nuovi messaggi.

**Campi principali**  
- _chatService: servizio chat per operazioni backend.
- conversationId, currentUserId: identificatori per la conversazione e utente corrente.
- _messagesSubscription: sottoscrizione stream per aggiornamenti in tempo reale.
- _messages: lista messaggi della conversazione.

**Metodi e funzionalità**  
- Costruttore: inizializza automaticamente la sottoscrizione al stream messaggi.
- sendMessage(String text): crea e invia nuovo messaggio con validazione contenuto.
- dispose(): pulizia risorse cancellando sottoscrizioni attive.

---

#### File: `screen/chat_list_screen.dart`, `screen/conversation_screen.dart`, `screen/new_chat_user_list_screen.dart`

**Scopo e contesto**  
Interfacce utente per il sistema di chat che includono lista conversazioni, visualizzazione conversazione singola e selezione utenti per nuove chat.

**Metodi e funzionalità**  
- Lista conversazioni con anteprime ultimo messaggio e timestamp.
- Interfaccia conversazione con bubble messaggi e campo input.
- Schermata selezione utenti con ricerca e filtri.

---

### Cartella `lib/features/events/`

#### File: `services/eventi_service.dart`

**Scopo e contesto**  
Servizio specializzato per la gestione degli eventi del circolo, supportando operazioni CRUD, gestione partecipanti e integrazione con il sistema di notifiche.

**Campi principali**  
- _firestore: istanza Firestore per accesso dati.
- _collectionPath: percorso collezione eventi ('eventi').

**Metodi e funzionalità**  
- getAllEventi(): recupera tutti gli eventi disponibili.
- partecipaEvento(String eventId, User user): iscrive utente ad evento creando documento nella sottocollezione partecipanti con nome, email e timestamp iscrizione.
- getPartecipanti(String eventId): recupera lista partecipanti per visualizzazione admin.
- disiscriviUtente(String eventId, String userId): rimuove partecipazione utente.

---

#### File: `screen/eventi_fragment.dart`, `screen/admin_event_details_screen.dart`, `screen/user_event_details_screen.dart`

**Scopo e contesto**  
Interfacce per la gestione e visualizzazione eventi con schermate differenziate per utenti normali e amministratori.

**Metodi e funzionalità**  
- Lista eventi con filtri per stato e categoria.
- Dettagli evento con gestione iscrizioni per utenti.
- Pannello admin con gestione partecipanti e modifiche evento.

---

### Cartella `lib/features/products/`

#### File: `services/product_service.dart`

**Scopo e contesto**  
Servizio per la gestione del catalogo prodotti con funzionalità di ordinamento, filtraggio per categoria e gestione inventario.

**Campi principali**  
- _firestore: istanza Firestore per accesso dati.
- _collectionPath: percorso collezione prodotti ('prodotti').

**Metodi e funzionalità**  
- getAllProducts(): carica tutti i prodotti con ordinamento alfabetico in memoria per ottimizzare query Firestore.
- getProductsByCategory(String categoria): filtra prodotti per categoria specifica considerando solo quelli ordinabili.
- updateProductQuantity(String productId, int newQuantity): aggiorna disponibilità prodotto.
- uploadProductImage(String productId, File imageFile): gestisce upload immagini prodotto su Firebase Storage.

---

#### File: `viewmodels/add_product_viewmodel.dart`

**Scopo e contesto**  
ViewModel per l'aggiunta e modifica prodotti nel catalogo, gestendo validazione dati, upload immagini e sincronizzazione con database.

**Metodi e funzionalità**  
- Validazione campi obbligatori e formati numerici.
- Gestione upload immagini con progress tracking.
- Creazione/aggiornamento prodotti con feedback stati.

---

#### File: `screen/product_catalog_fragment.dart`, `screen/add_product_screen.dart`, `screen/edit_product_screen.dart`

**Scopo e contesto**  
Interfacce per gestione catalogo prodotti con funzionalità differenziate per visualizzazione, aggiunta e modifica.

**Metodi e funzionalità**  
- Griglia prodotti con immagini e informazioni essenziali.
- Form aggiunta prodotto con validazione e upload immagini.
- Modifica prodotti esistenti con pre-popolamento campi.

---

### Cartella `lib/features/payment/`

#### File: `screen/pagamento_screen.dart`

**Scopo e contesto**  
Schermata hub per le modalità di pagamento disponibili nell'applicazione, fornendo accesso alle funzioni di pagamento tramite QR code e ordinazione prodotti.

**Metodi e funzionalità**  
- Navigazione verso QrCodeScreen per pagamenti veloci tramite codice QR.
- Navigazione verso ProductListForOrderingScreen per ordinazione prodotti con pagamento.

---

#### File: `screen/qr_code_screen.dart`

**Scopo e contesto**  
Genera e visualizza codici QR per pagamenti rapidi, tipicamente contenenti informazioni utente per identificazione presso cassa o terminali automatici.

---

#### File: `screen/product_list_ordering_screen.dart`, `screen/product_order_screen.dart`

**Scopo e contesto**  
Interfacce per l'ordinazione prodotti con gestione carrello, calcolo totali e conferma ordini.

**Metodi e funzionalità**  
- Selezione prodotti con quantità e calcolo automatico totali.
- Gestione carrello con modifica quantità e rimozione items.
- Conferma ordine con verifica saldo e creazione transazione.

---

### Cartella `lib/features/cash_register/`

#### File: `screen/cassa_screen.dart`

**Scopo e contesto**  
Interfaccia principale per le operazioni di cassa riservata agli amministratori, centralizzando l'accesso alle funzioni di ricarica credito, riscossione e scanning codici.

**Metodi e funzionalità**  
- Navigazione verso funzioni ricarica, riscossione e scanner.
- Dashboard riassuntiva con statistiche operazioni giornaliere.

---

#### File: `screen/ricarica_screen.dart`, `screen/riscuoti_screen.dart`

**Scopo e contesto**  
Schermate specializzate per operazioni finanziarie: ricarica credito utenti e riscossione pagamenti.

**Metodi e funzionalità**  
- Ricerca utenti per identificazione.
- Inserimento importi con validazione.
- Registrazione movimenti automatica.

---

#### File: `screen/scanner_screen.dart`

**Scopo e contesto**  
Interfaccia per la lettura di codici QR degli utenti attraverso fotocamera per identificazione rapida nelle operazioni di cassa.

---

#### File: `viewmodels/riscuoti_viewmodel.dart`

**Scopo e contesto**  
ViewModel per la gestione delle operazioni di riscossione con validazione saldi, creazione movimenti e sincronizzazione database.

**Metodi e funzionalità**  
- Validazione disponibilità fondi utente.
- Creazione movimenti di addebito.
- Aggiornamento saldi in tempo reale.

---

### Cartella `lib/features/admin_panel/`

#### File: `viewmodels/gestione_tessere_viewmodel.dart`

**Scopo e contesto**  
ViewModel specializzato per la gestione amministrativa delle tessere associative, permettendo agli admin di approvare richieste, assegnare tessere e gestire rinnovi.

**Campi principali**  
- _dataService: servizio per caricamento dati utenti.
- _authService: servizio per operazioni tessere.
- _allUsers: lista completa utenti per gestione tessere.

**Metodi e funzionalità**  
- fetchAllUsers(): ricarica lista utenti completa.
- assegnaTessera(String uid): approva richiesta tessera e assegna numero.
- rifiutaRichiesta(String uid): rifiuta richiesta tessera pendente.
- revocaTessera(String uid): revoca tessera esistente per violazioni o scadenza.

---

#### File: `screen/gestione_tessere_screen.dart`

**Scopo e contesto**  
Interfaccia amministrativa per gestione tessere con lista utenti filtrabili per stato tessera e azioni rapide per approvazione/rifiuto richieste.

---

### Cartella `lib/features/feedback/`

#### File: `services/feedback_service.dart`

**Scopo e contesto**  
Servizio per la gestione del sistema di feedback e segnalazioni, permettendo agli utenti di comunicare con la gestione e agli admin di tracciare e rispondere alle comunicazioni.

**Campi principali**  
- _firestore: istanza Firestore per persistenza feedback.
- _collectionPath: collezione 'feedback' per archiviazione.

**Metodi e funzionalità**  
- getTuttiFeedback(): recupera tutti i feedback ordinati cronologicamente con flag ID per operazioni successive.
- segnaComeLetto(String feedbackId): marca feedback come letto da admin per tracking.
- inviaFeedback(Map<String, dynamic> feedbackData): crea nuovo feedback con timestamp e dati utente.

---

#### File: `viewmodels/feedback_viewmodel.dart`

**Scopo e contesto**  
ViewModel per gestione feedback con funzionalità di invio per utenti normali e gestione lista per amministratori.

**Metodi e funzionalità**  
- Invio feedback con validazione contenuto.
- Lista feedback per admin con filtri per stato lettura.
- Aggiornamento stati lettura in tempo reale.

---

#### File: `screen/feedback_screen.dart`

**Scopo e contesto**  
Interfaccia per invio feedback utenti con form validato e interfaccia amministrativa per gestione feedback ricevuti.

---

### Cartella `lib/features/movements/`

#### File: `services/movimenti_service.dart`

**Scopo e contesto**  
Servizio specializzato per la gestione dei movimenti finanziari degli utenti, supportando diverse tipologie di transazioni e mantenendo storico dettagliato per ogni utente.

**Campi principali**  
- _firestore: istanza Firestore per accesso dati movimenti.

**Metodi e funzionalità**  
- getMovimentiUtente(String userId): carica gli ultimi 20 movimenti dalla sottocollezione specifica dell'utente con ordinamento cronologico decrescente.
- addMovimento(String userId, Movimento movimento): aggiunge nuovo movimento nella sottocollezione utente per tracking delle transazioni.
- Gestione robusta degli errori con logging dettagliato per troubleshooting.

---

#### File: `screen/movimenti_screen.dart`

**Scopo e contesto**  
Interfaccia per visualizzazione storico movimenti finanziari dell'utente con dettagli transazioni e saldi progressivi.

---

### Cartella `lib/features/orders/`

#### File: `services/orders_service.dart`

**Scopo e contesto**  
Servizio per la gestione degli ordini prodotti con funzionalità di creazione, eliminazione e tracking stato ordini.

**Metodi e funzionalità**  
- eliminaOrdine(String orderId): rimuove ordine dal database.
- creaOrdine(Map<String, dynamic> orderData): crea nuovo ordine con timestamp e dettagli.

---

#### File: `screen/order_screen.dart`

**Scopo e contesto**  
Interfaccia amministrativa per gestione ordini con visualizzazione lista, dettagli ordine e operazioni di evasione/cancellazione.

---

### Cartella `lib/features/home/`

#### File: `home_fragment.dart`

**Scopo e contesto**  
Schermata principale per utenti normali che presenta dashboard personalizzata con saldo corrente, ultimi movimenti e accesso rapido alle funzioni principali.

**Metodi e funzionalità**  
- Visualizzazione saldo formattato con localizzazione italiana.
- Lista ultimi movimenti con refresh pull-to-refresh.
- Accesso rapido a eventi futuri e notifiche non lette.
- Integrazione con AuthViewModel per dati in tempo reale.

---

### Cartella `lib/features/profile/`

#### File: `profilo_fragment.dart`

**Scopo e contesto**  
Schermata profilo utente per visualizzazione e modifica informazioni personali, gestione tessera associativa e impostazioni account.

**Metodi e funzionalità**  
- Visualizzazione informazioni profilo con possibilità di modifica.
- Richiesta e gestione tessera associativa per utenti.
- Opzioni logout e impostazioni privacy.

---

### Cartella `lib/screens/` (Legacy)

#### File: `chat_fragment.dart`, `qr_code_fragment.dart`, `notifiche_fragment.dart`

**Scopo e contesto**  
Fragment legacy mantenuti per compatibilità durante la migrazione architetturale, implementano funzionalità base per chat, codici QR e notifiche.

**Metodi e funzionalità**  
- Interfacce semplificate per funzionalità chat, QR e notifiche.
- Graduale sostituzione con implementazioni nella struttura features.

---

### File Root della Cartella lib/

#### File: `main.dart`

**Scopo e contesto**  
Entry point dell'applicazione che configura Firebase, inizializza i provider per la gestione stato e implementa il wrapper di autenticazione per il routing basato sullo stato di login.

**Campi principali**  
- Firebase initialization con gestione errori graceful.
- ChangeNotifierProvider per AuthViewModel globale.
- MaterialApp con tema personalizzato e configurazione routing.

**Metodi e funzionalità**  
- main(): inizializza Firebase con DefaultFirebaseOptions, configura localizzazione italiana e avvia CircolApp.
- AuthWrapper: widget che monitora stato autenticazione e naviga tra LoginScreen e MainScreen basato su AuthResult.
- Tema Material3 personalizzato con colori corporate e componenti stilizzati.
- Gestione stati loading con indicatori visivi durante inizializzazione.

---

#### File: `firebase_options.dart`

**Scopo e contesto**  
File di configurazione generato automaticamente da FlutterFire CLI che contiene le opzioni Firebase per tutte le piattaforme supportate (Android, iOS, Web, macOS, Windows).

**Metodi e funzionalità**  
- currentPlatform: getter che restituisce configurazione appropriata per la piattaforma di esecuzione.
- Configurazioni specifiche per ogni piattaforma con API keys, project ID e identificatori app.

---

## Conclusioni

Il progetto CircolApp presenta un'architettura modulare ben strutturata che segue i pattern moderni dello sviluppo Flutter. L'organizzazione in features separate permette una manutenibilità elevata e una chiara separazione delle responsabilità. L'utilizzo del pattern MVVM attraverso i ViewModel garantisce una gestione reattiva dello stato, mentre l'integrazione con Firebase fornisce una solida base per autenticazione, storage dati e notifiche in tempo reale.

L'applicazione dimostra una comprensione matura delle best practices Flutter, implementando correttamente la gestione degli stream per dati in tempo reale, la serializzazione robusta dei modelli, e un sistema di navigazione intuitivo differenziato per ruoli utente. La presenza di servizi specializzati per ogni dominio funzionale e l'uso appropriato dei provider per la gestione stato globale evidenziano un design architetturale solido e scalabile.