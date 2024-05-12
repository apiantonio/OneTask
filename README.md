# Progetto-Mobile
**Gestione progetti**
Informazioni varie
- Non è necessario che i dati usati nell’applicazione siano veritieri.
- L’interfaccia utente deve contenere sempre almeno tre schermate.
- Le feature evidenziate in giallo sono consigliate ma non necessarie.
- Si è liberi di implementare qualunque altra feature utile nel contesto affrontato dall’applicazione.
  
## Descrizione generale dell’applicazione
L’obiettivo di questo tema di progetto è sviluppare un’applicazione mobile multipiattaforma per la gestione dei progetti e task all’interno di un’azienda. L'app dovrebbe offrire strumenti per pianificare, monitorare e revisionare i progressi dei progetti e le attività dei team.
### Feature Interfaccia Utente
**L’applicazione dovrebbe essere composta almeno dalle seguenti schermate principali:**
1. Schermata principale (dashboard)
    1. Lista dei progetti modificati recentemente e attivi
        1.1.1. Ogni progetto ha diverse informazioni (nome, descrizione, team associato, data di rilascio, etc) ma nella dashboard si mostra solo un rapido sommario.
        1.1.2. Lo stato di un progetto può essere: attivo, sospeso, archiviato. Un progetto archiviato può essere ulteriormente etichettato come completo oppure fallito.
               1.1.2.1. Quando si archivia un progetto con status fallito, si deve fornire una motivazione al riguardo (es, nessun team a disposizione).
        1.1.3. Ogni progetto ha una lista di task associati ad esso.
               1.1.3.1. Un task può essere completato o non completato. In questa schermata, solo i task non completati vengono mostrati, e viene data la possibilità di completarli.
        1.1.4. La lista visualizza k progetti (con k scelto dall’utente; esempio: 5 di default, 10, 20).
   1.2. Lista dei team    
        1.2.1. Un team ha un nome ed è sempre composto da almeno due dipendenti.
               1.2.1.1. Per i dipendenti si deve tenere di conto di almeno delle seguenti informazioni: matricola, nome, cognome, ruolo nel team.
               1.2.1.2. Un dipendente può stare in al più due team.
        1.2.2. La lista visualizza i primi tre team per dimensione (numero di dipendenti all’interno).
   1.3. Accesso rapido per aggiungere un nuovo progetto.    
2. Schermata gestione progetto
   2.1. Lista completa dei progetti e dei team.
   2.2. Funzione di filtraggio e ricerca del progetto e team.
   2.3. Possibilità di vedere tutti i dettagli di un progetto o team.
        2.3.1. In questa schermata, dato un progetto vengono mostrati tutti i task.
3. Schermata aggiunta e modifica progetto e team
   3.1. Deve permettere di aggiungere un nuovo progetto oppure modificarne uno esistente (quest’ultimo scelto dalla schermata 2).
        3.1.1. Nella parte di modifica progetto, si deve poter modificare anche i task.
4. Schermata statistiche
   4.1. Almeno una statistica a scelta.
   4.2. Un grafico a scelta.

### Funzionalità dell’app
* L’utente deve poter inserire, modificare o eliminare progetti, task e team.
* L’utente deve poter associare accedere ad un progetto o un team, e quindi poterlo modificare, senza dover passare dalla funzione di ricerca.
* L’app può inviare notifiche push per ricordare all’utente delle informazioni (esempio: l’utente può scegliere di ricevere una notifica push per ogni progetto la cui scadenza è tra 5 giorni).
### Vincoli tecnici
* L’app deve essere sviluppata utilizzando React Native o Flutter.
* L’interfaccia deve essere responsive ed adattarsi a diverse dimensioni di schermo.
  - L’app deve adattarsi sia in portrait che in landscape mode.
* Per la persistenza dei dati, è consigliato usare SQLite.
* Librerie e package esterni possono essere utilizzati.

## APPUNTI PERSONALI
- Nell’aggiunta di un nuovo progetto lo stato sarà di default attivo
- Nell’aggiunta di un nuovo team bisogna dare un segnale di allerta nel caso in cui il dipendente già partecipi a 2 team
- Nella modifica di un team bisogna prestare attenzione che non si aggiungano persone che partecipano già a 2 team
- Non si può eliminare un team che è associato ad un progetto con stato attivo/sospeso
- Quando si modifica un progetto si deve dare la possibilità di cambiarne lo stato e se attivo di completarne i task.

