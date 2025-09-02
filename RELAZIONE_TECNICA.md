# Relazione Tecnica - CircolApp Flutter

## Introduzione e Struttura del Progetto

CircolApp rappresenta un'applicazione mobile sviluppata in Flutter per la gestione completa di un circolo o club privato. L'applicazione nasce dalla conversione di un precedente progetto Android nativo in Kotlin, evolvendosi verso una soluzione cross-platform che mantiene tutte le funzionalità originali arricchendole con nuove possibilità offerte dall'ecosistema Flutter.

L'architettura dell'applicazione segue i principi del Model-View-ViewModel (MVVM) pattern, garantendo una separazione netta delle responsabilità e una gestione dello stato efficiente attraverso il pattern Provider di Flutter. La struttura del progetto è organizzata seguendo una logica feature-driven, dove ogni funzionalità dell'app è contenuta in moduli dedicati che includono le proprie schermate (screen), logica di business (viewmodels) e servizi di accesso ai dati (services).

### Architettura del Sistema

Il backend dell'applicazione si basa completamente sui servizi Firebase di Google, sfruttando:
- **Firebase Authentication** per la gestione dell'autenticazione degli utenti
- **Cloud Firestore** come database NoSQL per la persistenza dei dati
- **Firebase Storage** per l'archiviazione di file multimediali come immagini dei prodotti
- **Firebase Messaging** per le notifiche push (configurato ma non ancora implementato)

### Organizzazione delle Cartelle

La struttura delle cartelle segue una logica modulare ben definita:

- **`lib/core/`**: Contiene i componenti fondamentali condivisi da tutta l'applicazione
  - `models/`: Definisce le classi di dati principali (User, Evento, Product, Movimento)
  - `services/`: Servizi centrali per l'accesso ai dati e utilità generali
  - `screen/`: Schermate principali come MainScreen per la navigazione

- **`lib/features/`**: Organizzazione modulare per funzionalità specifiche
  - Ogni feature contiene le proprie `screen/`, `viewmodels/` e `services/`
  - Moduli principali: auth, chat, events, products, movements, payments, admin_panel

- **`lib/screens/`**: Frammenti e schermate ausiliarie che non appartengono a feature specifiche

### Gestione dello Stato e Navigazione

L'applicazione utilizza il pacchetto Provider per la gestione dello stato reattivo, permettendo ai ViewModels di notificare automaticamente le interfacce utente dei cambiamenti nei dati. La navigazione principale avviene attraverso una BottomNavigationBar configurata dinamicamente in base al ruolo dell'utente (admin o user normale), offrendo percorsi di navigazione personalizzati.

### Integrazione Firebase e Sicurezza

L'integrazione con Firebase garantisce sicurezza e scalabilità attraverso regole di sicurezza Firestore che limitano l'accesso ai dati in base all'autenticazione dell'utente. I dati sensibili come movimenti finanziari e informazioni personali sono protetti attraverso strutture gerarchiche di sottocollezioni che rispettano la privacy degli utenti.

---

## Analisi Dettagliata dei File di Codice

### AuthViewModel

Scopo e contesto  
Gestisce autenticazione email/password e recupero del ruolo utente da Firestore, esponendo uno stato reattivo (AuthResult). Rappresenta il cuore dell'applicazione fungendo da gestore centralizzato per tutti i dati dell'applicazione, non solo l'autenticazione.

Campi principali  
- firebaseAuth, firestore: servizi Firebase integrati tramite AuthService
- authResult (LiveData<AuthResult>): stato dell'autenticazione (Idle/Loading/Success/Error)  
- _currentUser, _currentUserRole: informazioni utente corrente
- _allAppData: mappa contenente tutti i dati dell'applicazione caricati
- _tuttiEventi, _eventiUtente, _movimenti, _prodotti: liste tipizzate dei dati principali
- _allUsers, _allMovimenti (admin): dati estesi per amministratori

Metodi e funzionalità  
- checkCurrentUser(): se un utente è già autenticato, imposta Loading e avvia il recupero del ruolo; altrimenti imposta Idle
- loginUser(email, password): valida input, effettua sign‑in e, se riuscito, prosegue con il recupero del ruolo  
- fetchUserRoleAndProceed(firebaseUser): legge il documento in "utenti/{uid}", determina il ruolo (ADMIN/USER o default USER) e pubblica Success; se il documento non esiste, lo crea con ruolo USER e pubblica Success
- createFirestoreUserDocument(firebaseUser, defaultRole): crea il documento utente in Firestore con il ruolo predefinito e i campi base
- refreshAllData(): ricarica tutti i dati dell'applicazione dopo modifiche importanti
- createTestDataForCurrentUser(): crea dati di esempio per test e sviluppo

### AuthService

Scopo e contesto  
Servizio dedicato esclusivamente alla gestione dell'autenticazione Firebase, separando le responsabilità dall'AuthViewModel e fornendo metodi per login, registrazione e gestione delle tessere utente.

Campi principali  
- _firebaseAuth: istanza Firebase Authentication per operazioni di autenticazione
- _firestore: riferimento Firestore per operazioni sui documenti utente
- _dataService: FirestoreDataService per caricamento completo dei dati post-autenticazione

Metodi e funzionalità  
- loginUser(email, password): autentica l'utente e carica tutti i dati dell'applicazione tramite _dataService.loadAllUserData()
- registerUser(email, password, username, nome): crea nuovo account Firebase e documento utente in Firestore
- getCurrentAuthUser(): ritorna l'utente Firebase correntemente autenticato
- checkCurrentUser(): verifica se esiste un utente autenticato e carica i suoi dati
- assegnaTessera(uid), revocaTessera(uid): gestione tessere membri del circolo
- logout(): disconnette l'utente dai servizi Firebase

### ProductService

Scopo e contesto  
Gestisce tutte le operazioni CRUD sui prodotti del catalogo, incluso il caricamento di immagini su Firebase Storage e la gestione delle quantità disponibili per il sistema di vendita.

Campi principali  
- _firestore: riferimento alla collezione 'prodotti' su Firestore
- _collectionPath: percorso della collezione prodotti ('prodotti')

Metodi e funzionalità  
- getAllProducts(): carica tutti i prodotti disponibili ordinandoli per nome
- getProductsByCategory(categoria): filtra prodotti per categoria specifica
- addProduct(product): aggiunge nuovo prodotto usando ID personalizzato
- updateProduct(product): aggiorna prodotto esistente mantenendo l'ID
- deleteProduct(productId): rimuove prodotto dal catalogo
- updateProductQuantity(productId, nuovaQuantita): aggiorna stock disponibile
- updateMultipleProductsStock(itemsSold): aggiorna quantità multiple prodotti dopo vendita
- uploadProductImage(imageFile, productId): carica immagine su Firebase Storage e ritorna URL
- getProductsStream(): stream in tempo reale per aggiornamenti automatici UI

### AddProductViewModel

Scopo e contesto  
Coordina l'interfaccia utente per l'aggiunta e modifica prodotti nel catalogo amministrativo, gestendo la selezione di immagini e la validazione dei dati prima dell'invio al ProductService.

Campi principali  
- _productService: istanza ProductService per operazioni sui prodotti
- _isLoading: stato caricamento per feedback visivo
- _selectedImage: File immagine selezionata dall'utente per il prodotto

Metodi e funzionalità  
- pickImage(): apre galleria dispositivo per selezione immagine prodotto
- saveProduct(): valida dati inseriti, carica eventuale immagine su Storage, crea oggetto Product e lo salva tramite ProductService
- _validateProductData(): metodi interni di validazione dati (implementazione implicita)

### EventiService

Scopo e contesto  
Fornisce accesso completo alla gestione degli eventi del circolo, includendo la creazione, recupero e gestione delle partecipazioni attraverso sottocollezioni Firestore dedicate ai partecipanti di ogni evento.

Campi principali  
- _firestore: riferimento Firestore per accesso collezione 'eventi'  
- _collectionPath: path collezione eventi ('eventi')

Metodi e funzionalità  
- getAllEventi(): recupera tutti gli eventi disponibili nel circolo
- partecipaEvento(eventId, user): iscrive utente all'evento creando documento nella sottocollezione 'partecipanti' con dati utente completi
- getPartecipanti(eventId): recupera lista completa partecipanti per visualizzazione amministrativa
- creaEvento(evento): aggiunge nuovo evento al sistema (implementazione implicita)
- verificaPartecipazioneUtente(eventId, userId): controlla se utente è già iscritto all'evento

### MovimentiService  

Scopo e contesto  
Gestisce la cronologia delle transazioni finanziarie degli utenti, utilizzando sottocollezioni Firestore per mantenere la privacy dei dati e consentire query efficienti sui movimenti di ciascun utente.

Campi principali  
- _firestore: istanza Firestore per accesso sottocollezioni movimenti

Metodi e funzionalità  
- getMovimentiUtente(userId): carica ultimi 20 movimenti dalla sottocollezione 'utenti/{userId}/movimenti'
- addMovimento(userId, movimento): aggiunge nuovo movimento finanziario nella sottocollezione utente specifica  
- updateUserSaldo(userId): ricalcola saldo utente basandosi sui movimenti (implementazione implicita)
- getAllMovimenti(): recupera tutti i movimenti del sistema per amministratori (implementazione implicita)

### RiscuotiViewModel

Scopo e contesto  
Coordina le operazioni di cassa per la vendita di prodotti agli utenti del circolo, gestendo la selezione utente, scansione prodotti e finalizzazione delle transazioni con aggiornamento automatico di saldi e scorte.

Campi principali  
- _selectedUser: utente selezionato per la transazione
- _scannedProducts: lista prodotti scansionati/selezionati  
- total: importo totale calcolato automaticamente

Metodi e funzionalità  
- setUser(user): imposta l'utente per la transazione corrente
- addProduct(product): aggiunge prodotto al carrello di vendita
- finalizeTransaction(): crea movimento finanziario per l'utente, aggiorna stock prodotti tramite ProductService e MovimentiService
- clearCart(): azzera la transazione per preparare la successiva
- _calculateTotal(): calcola totale carrello (implementazione implicita)

### ChatViewModel (base)

Scopo e contesto  
Gestisce la lista generale degli utenti disponibili per iniziare nuove conversazioni chat, fornendo la base per il sistema di messaggistica interno del circolo.

Campi principali  
- _dataService: FirestoreDataService per caricamento utenti
- _allUsers: lista completa utenti del circolo
- _isLoading: stato caricamento per feedback UI

Metodi e funzionalità  
- loadAllUsers(): carica tutti gli utenti registrati tramite FirestoreDataService
- getUserById(uid): recupera dati utente specifico dalla lista caricata
- _filterCurrentUser(): esclude utente corrente dalla lista (implementazione implicita)

### ConversationViewModel  

Scopo e contesto  
Gestisce una singola conversazione chat in tempo reale, fornendo stream di messaggi aggiornati automaticamente e permettendo l'invio di nuovi messaggi tramite ChatService.

Campi principali  
- _chatService: ChatService per operazioni messaggistica
- conversationId: identificativo univoco conversazione
- currentUserId: ID utente corrente per identificare messaggi propri
- _messagesSubscription: sottoscrizione stream messaggi in tempo reale
- _messages: lista messaggi conversazione corrente

Metodi e funzionalità  
- constructor: avvia automaticamente sottoscrizione stream messaggi per conversationId
- sendMessage(text): valida e invia nuovo messaggio tramite ChatService
- dispose(): cancella sottoscrizione stream per prevenire memory leaks
- _markMessageAsOwn(): identifica messaggi dell'utente corrente per UI (implementazione implicita)

### NewChatViewModel

Scopo e contesto  
Facilita la creazione di nuove conversazioni permettendo la ricerca e selezione di utenti con cui iniziare una chat, gestendo il flusso di navigazione verso la schermata di conversazione.

Campi principali  
- _dataService: FirestoreDataService per accesso dati utenti
- _users: lista utenti disponibili per nuove chat
- _isLoading: stato caricamento interfaccia

Metodi e funzionalità  
- _fetchAllUsers(): carica lista completa utenti escludendo utente corrente
- startChatWithUser(selectedUser): crea nuova conversazione o recupera esistente, emette evento navigazione
- _generateChatId(): genera ID consistente per conversazione tra due utenti (implementazione implicita)

### ChatService

Scopo e contesto  
Servizio centralizzato per tutte le operazioni di messaggistica, gestisce conversazioni e messaggi su Firestore con aggiornamenti in tempo reale tramite stream, mantenendo la struttura gerarchica conversazioni/messaggi.

Campi principali  
- _firestore: istanza Firestore per accesso collezioni chat

Metodi e funzionalità  
- getConversationsStream(userId): stream conversazioni utente ordinate per ultimo messaggio
- getMessagesStream(conversationId): stream messaggi conversazione ordinati cronologicamente
- sendMessage(conversationId, message): invia messaggio e aggiorna metadati conversazione
- createConversation(participants): crea nuova conversazione tra utenti (implementazione implicita)
- updateConversationMetadata(): aggiorna ultimo messaggio e timestamp (implementazione implicita)

### FeedbackViewModel

Scopo e contesto  
Gestisce la visualizzazione e amministrazione dei feedback ricevuti dagli utenti, permettendo agli amministratori di marcare i feedback come letti e mantenendo l'interfaccia aggiornata in tempo reale.

Campi principali  
- _feedbackService: FeedbackService per operazioni sui feedback
- _feedbacks: lista feedback caricati dal sistema  
- _isLoading: stato caricamento per feedback UI

Metodi e funzionalità  
- fetchFeedbacks(): carica tutti i feedback dal FeedbackService
- segnaFeedbackComeLetto(feedbackId): aggiorna stato lettura con feedback UI immediato e persistenza asincrona
- _handleUpdateError(): gestisce errori aggiornamento ripristinando stato precedente (implementazione implicita)

### GestioneTessereViewModel

Scopo e contesto  
Amministra le tessere membri del circolo permettendo agli amministratori di assegnare, revocare tessere e gestire le richieste di rinnovo degli utenti, con aggiornamento automatico della lista utenti dopo ogni operazione.

Campi principali  
- _dataService: FirestoreDataService per caricamento dati utenti
- _authService: AuthService per operazioni tessere  
- _allUsers: lista completa utenti con stato tessere
- _isLoading: stato caricamento interfaccia amministrazione

Metodi e funzionalità  
- fetchAllUsers(): carica tutti gli utenti del sistema con informazioni tessere
- assegnaTessera(uid): assegna tessera a utente specifico e ricarica lista
- rifiutaRichiesta(uid): rifiuta richiesta tessera utente
- revocaTessera(uid): revoca tessera esistente  
- _filterPendingRequests(): filtra utenti con richieste tessera pendenti (implementazione implicita)

### FeedbackService

Scopo e contesto  
Servizio dedicato alla gestione dei feedback degli utenti, permettendo il recupero, l'invio e la marcatura come letti dei suggerimenti e delle segnalazioni provenienti dalla comunità del circolo.

Campi principali  
- _firestore: istanza Firestore per accesso collezione 'feedback'
- _collectionPath: percorso collezione feedback ('feedback')

Metodi e funzionalità  
- getTuttiFeedback(): recupera tutti i feedback ordinati per timestamp decrescente, aggiungendo ID documento per operazioni successive
- segnaComeLetto(feedbackId): aggiorna stato lettura feedback specifico per amministrazione
- inviaFeedback(feedbackData): crea nuovo feedback nel sistema con timestamp automatico
- _validateFeedbackData(): validazione dati feedback prima dell'invio (implementazione implicita)

### OrdersService

Scopo e contesto  
Gestisce il sistema di ordinazioni del circolo, permettendo la creazione di nuovi ordini e la loro eliminazione, integrando il flusso di ordinazione prodotti con la gestione amministrativa.

Campi principali  
- _firestore: riferimento Firestore per collezione 'ordinazioni'
- _collectionPath: path collezione ordini ('ordinazioni')

Metodi e funzionalità  
- creaOrdine(orderData): inserisce nuovo ordine nel database con dati completi ordinazione
- eliminaOrdine(orderId): rimuove ordine specifico dal sistema per gestione amministrativa
- getOrdiniPendenti(): recupera ordini in attesa di elaborazione (implementazione implicita)
- updateStatoOrdine(): aggiorna stato elaborazione ordine (implementazione implicita)

## Analisi dei Modelli Dati

### Product

Scopo e contesto  
Rappresenta un prodotto del catalogo del circolo con informazioni complete per gestione vendite, inventario e visualizzazione, includendo supporto per immagini e stato disponibilità.

Campi principali  
- id: identificativo univoco prodotto
- nome, descrizione: informazioni descrittive per utente
- prezzo (double): costo unitario prodotto
- numeroPezzi: quantità disponibile in magazzino  
- ordinabile: flag attivazione vendita prodotto
- imageUrl: URL immagine archiviata su Firebase Storage

Proprietà computate e metodi  
- isAvailable: verifica disponibilità basata su ordinabile e stock
- isEsaurito: controllo esaurimento scorte
- immagine, importo: getter compatibilità con codice esistente
- fromMap(), toMap(): serializzazione/deserializzazione Firestore
- copyWith(): creazione copie modificate mantenendo immutabilità
- toString(): rappresentazione leggibile per debug

### Movimento

Scopo e contesto  
Modella le transazioni finanziarie degli utenti del circolo, registrando entrate, uscite e operazioni di pagamento con timestamp precisi e descrizioni dettagliate per tracciabilità completa.

Campi principali  
- id: identificativo univoco transazione
- importo: valore monetario (positivo/negativo per entrate/uscite)  
- descrizione: dettagli leggibili della transazione
- data: timestamp preciso operazione
- tipo: categoria movimento ('ricarica', 'pagamento', 'rimborso')
- userId: collegamento al proprietario transazione

Metodi di utilità  
- fromMap(): deserializzazione con gestione conversione timestamp flessibile attraverso _convertData()
- toMap(): serializzazione con Timestamp Firestore per consistenza
- _convertData(): helper conversione formati data multipli (Timestamp, int, String)

### ChatConversation

Scopo e contesto  
Rappresenta una conversazione nel sistema di messaggistica, mantenendo metadati essenziali per visualizzazione lista chat e ordinamento cronologico delle conversazioni attive.

Campi principali  
- id: identificativo univoco conversazione
- participants: array UID utenti partecipanti alla chat
- lastMessageText: anteprima ultimo messaggio per lista conversazioni
- lastMessageTimestamp: timestamp ultimo messaggio per ordinamento cronologico

Funzionalità specializzate  
- fromMap(): factory constructor con parsing Timestamp Firestore automatico
- Struttura ottimizzata per query efficienti su participants array
- Progettazione per supporto futuro chat di gruppo estendendo participants

### User

Scopo e contesto  
Modello completo utente del circolo includendo informazioni anagrafiche, ruolo, tessera di iscrizione, saldo finanziario e cronologia movimenti, rappresentando il profilo completo del membro.

Campi principali  
- uid: identificativo Firebase Auth utente
- username, nome, email: dati anagrafici identificazione
- displayName: nome visualizzazione pubblico
- ruolo: UserRole (admin/user) per controlli accesso
- saldo: credito disponibile utente
- movimenti: cronologia transazioni associate
- hasTessera, numeroTessera, dataScadenzaTessera: gestione tessere membri
- richiestaRinnovoInCorso: stato richiesta rinnovo tessera

Funzionalità estese  
- Supporto photoUrl per immagini profilo future
- telefono opzionale per contatti aggiuntivi
- Metodi serializzazione/deserializzazione Firestore completi
- Integrazione con sistema ruoli per controllo accesso differenziato

### Evento

Scopo e contesto  
Rappresenta eventi e attività del circolo con gestione partecipazioni, date multiple, capacità massima e visibilità pubblica/privata per coordinamento completo attività sociali.

Campi principali  
- id: identificativo evento univoco
- nome, descrizione: informazioni descrittive evento
- dataInizio, dataFine: periodo svolgimento attività
- luogo: localizzazione evento
- partecipanti: lista UID utenti iscritti
- organizzatore: responsabile evento
- maxPartecipanti: limite iscrizioni
- isPublico: visibilità evento
- quota: costo partecipazione opzionale

Gestione avanzata  
- immagine, metadata: supporto contenuti multimediali e dati estesi
- dataCreazione: timestamp creazione per ordinamento
- Sottocollezioni Firestore per partecipanti con dati dettagliati
- Logica isFuturo computata per filtraggio eventi attivi

---

## Considerazioni Architetturali e Best Practices

### Pattern Architetturale MVVM

L'applicazione implementa consistentemente il pattern MVVM attraverso:
- **ViewModels**: gestione stato e logica business con ChangeNotifier
- **Views**: componenti UI reactive che osservano ViewModels via Provider  
- **Models**: oggetti dati immutabili con serializzazione Firestore
- **Services**: layer astrazione per accesso dati e API esterne

### Gestione Stato Reattivo

La scelta di Provider + ChangeNotifier garantisce:
- Aggiornamenti UI automatici al cambio stato
- Separazione netta tra logica business e presentazione
- Gestione memoria efficiente con dispose() automatico
- Debugging facilitato attraverso pattern prevedibile

### Architettura Firebase

L'integrazione Firebase sfrutta:
- **Firestore**: database NoSQL con sottocollezioni per privacy dati
- **Authentication**: gestione sicura identità utenti
- **Storage**: archiviazione immagini con URL pubblici
- **Regole sicurezza**: controllo accesso basato su ruoli utente

### Scalabilità e Performance  

Le scelte implementative supportano crescita attraverso:
- Sottocollezioni Firestore per query efficienti su grandi dataset
- Stream real-time per aggiornamenti automatici senza polling
- Lazy loading e pagination per liste estese
- Cache locale attraverso stream Firestore automatici

### Sicurezza e Privacy

Il sistema garantisce protezione attraverso:
- Autenticazione obbligatoria per accesso funzionalità
- Controlli ruolo admin/user per operazioni sensibili
- Isolamento dati utente tramite sottocollezioni private
- Validazione client-side con enforcement server-side via regole Firestore

L'architettura risultante offre una base solida per l'evoluzione continua dell'applicazione, mantenendo codice manutenibile, prestazioni ottimali e sicurezza adeguata per un'applicazione di gestione circolo con dati sensibili finanziari e personali.
