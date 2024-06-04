import 'package:OneTask/model/partecipazione.dart';
import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/model/team.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:OneTask/model/utente.dart';

/// Singleton che gestisce il database
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // variabile globale per impostare la versione del DB
  static const _dbVersion = 1;
  // per abilitare le foreign keys (references) alla creazione del DB
  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
}

  // crea una connessione col db e crea le tabelle
  Future<Database> _initDatabase() async {
    
    /*############### DA USARE QUANDO SI CAMBIA QUALCOSA DEL DB #################################*/
    //await deleteDatabase(join(await getDatabasesPath(), 'OneTask_database.db'));
    /*##############################################################################*/

    return await openDatabase(
      // getdatabasePath restituisce la directory del db che varia a seconda dell'OS
      // il db si chiamerà OneTask_database
      join(await getDatabasesPath(), 'OneTask_database.db'),
        version: _dbVersion,
        onConfigure: _onConfigure,
        onCreate: (db, version) async {
          // creo le tabelle del database
          // Tabella utente, NOTA: GLOB è un operatore
          await db.execute('''
            CREATE TABLE utente (
              matricola CHAR(5) PRIMARY KEY CHECK (
                  LENGTH(matricola) = 5 AND
                  SUBSTR(matricola, 1, 1) IN ('0','1','2','3','4','5','6','7','8','9') AND
                  SUBSTR(matricola, 2, 1) IN ('0','1','2','3','4','5','6','7','8','9') AND
                  SUBSTR(matricola, 3, 1) IN ('0','1','2','3','4','5','6','7','8','9') AND
                  SUBSTR(matricola, 4, 1) IN ('0','1','2','3','4','5','6','7','8','9') AND
                  SUBSTR(matricola, 5, 1) IN ('0','1','2','3','4','5','6','7','8','9')
                ),
            nome TEXT, 
            cognome TEXT)'''
          );
          await db.execute('''
            CREATE TABLE team (
              nome TEXT PRIMARY KEY
            )'''
          );
          await db.execute('''
            CREATE TABLE partecipazione (
              utente CHAR(5) NOT NULL REFERENCES utente(matricola) ON DELETE CASCADE ON UPDATE CASCADE, 
              team TEXT NOT NULL REFERENCES team(nome) ON DELETE CASCADE ON UPDATE CASCADE, 
              ruolo INTEGER NOT NULL,
              PRIMARY KEY(utente, team)
            )''');
          await db.execute('''
            CREATE TABLE progetto (
              nome TEXT PRIMARY KEY,
              team TEXT NOT NULL REFERENCES team(nome) ON DELETE RESTRICT ON UPDATE CASCADE,
              scadenza TEXT NOT NULL,
              stato VARCHAR(10) NOT NULL CHECK (stato IN ('attivo', 'sospeso', 'archiviato')),
              descrizione TEXT NOT NULL,
              completato INTEGER CHECK (completato IS NULL OR
                (completato IS NOT NULL AND stato = 'archiviato')),
              motivazioneFallimento TEXT CHECK (motivazioneFallimento IS NULL OR 
                (motivazioneFallimento IS NOT NULL AND completato = 0))
            )''');
          await db.execute('''
            CREATE TABLE task (
              id INTEGER,
              progetto TEXT NOT NULL REFERENCES progetto(nome) ON DELETE CASCADE ON UPDATE CASCADE,
              attivita TEXT NOT NULL,
              completato INTEGER NOT NULL,
              PRIMARY KEY(id, progetto)
            )''');
      },
    );
  }

  /*
    ### INTERAZIONE CON GLI UTENTI ###
  */
  /// Inserisci un utente nella tabella utente
  Future<void> insertUtente(Utente utente) async {
    final db = await database;
    await db.insert(
      'utente',
      utente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Esegue un UPDATE sulla tabella utente
  Future<int> updateUtente(Utente utente) async {
    final db = await database;
    return await db.update(
      'utente', 
      utente.toMap(),
      where: 'matricola = ?',
      whereArgs: [utente.matricola],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Elimina un utente dalla tabella utente
  Future<int> deleteUtente(Utente utente) async {
    final db = await database;
    return await db.delete(
      'utente',
      where: 'matricola = ?',
      whereArgs: [utente.matricola],
    );
  }

  /// Cerca un Utente data una matricola
  Future<Utente?> selectUtenteByMatricola(String matricola) async {
    final db = await database;
    final List<Map<String, Object?>> utente = await db.query(
      'utente',
      where: 'matricola = ?',
      whereArgs: [matricola],
    );

    if (utente.isEmpty) {
      return null;
    } else {
      return Utente(
        matricola: utente[0]['matricola'] as String,
        nome: utente[0]['nome'] as String,
        cognome: utente[0]['cognome'] as String,
      );
    }
  }

  /// Restituisce una lista contenente tutti gli utenti della tabella 'utente' 
  Future<List<Utente>> getAllUtenti() async {
    final db = await database;

    final List<Map<String, Object?>> utenteMaps = await db.query('utente');

    return [
      for (final {
            'matricola': matricola as String,
            'nome': nome as String,
            'cognome': cognome as String,
          } in utenteMaps)
        Utente(matricola: matricola, nome: nome, cognome: cognome),
    ];
  }

  /// restituisce tutti gli utenti che partecipano a meno di 2 team
  Future<List<Utente>?> getUtentiNot2Team() async {
    final db = await database;
    /// uso una query per estrarre gli utenti che non partecipano a 2 team
    final List<Map<String, Object?>> utentiDelTeam = await db.rawQuery('''
      SELECT *
      FROM utente
      WHERE matricola IN (
        SELECT matricola
        FROM utente
                EXCEPT
        SELECT utente
        FROM partecipazione
        GROUP BY utente
        HAVING COUNT(*) >= 2
      )
    '''
    );
    /// ritorno gli utenti creati dai dati forniti dalle mappe come detto prima
    return utentiDelTeam.map((m) => Utente(
      matricola: m['matricola'] as String,
      nome: m['nome'] as String,
      cognome: m['cognome'] as String,
    )).toList();
  }

  /// metodo per estrarre gli utenti che non partecipano a 2 team (escluso quello corrente)
  /// e che non sono già presenti nel team di partenza
  Future<List<Utente>?> getUtentiNotInTeam(List<String> team, String teamName) async {
    final db = await database;
    ///ottengo una stringa costituita dalle matricole degli utenti del team
    String listToString = team.map((mat) => "'$mat'").join(',');
    String condition = team.isEmpty ? "" : "AND matricola NOT IN ($listToString)";
    final List<Map<String, Object?>> utenti = await db.rawQuery('''
      SELECT *
      FROM utente
      WHERE matricola IN (
        SELECT matricola
        FROM utente
                EXCEPT
        SELECT utente
        FROM partecipazione
        WHERE partecipazione.team <> ?
        GROUP BY utente
        HAVING COUNT(*) >= 2
      )
        $condition
    ''', [teamName]
    );
    // ritorno gli utenti creati dai dati forniti dalle mappe come detto prima
    return utenti.map((m) => Utente(
      matricola: m['matricola'] as String,
      nome: m['nome'] as String,
      cognome: m['cognome'] as String,
    )).toList();
  }

  /*
    ### INTERAZIONE CON I PROGETTI ###
  */
  /// Inserisci un nuovo progetto nel db
  Future<void> insertProgetto(Progetto progetto) async {
    final db = await database;
    await db.insert(
      'progetto',
      progetto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  /// Esegue un UPDATE sulla tabella progetto
  Future<int> updateProgetto(String oldNomeProgetto, Progetto newProgetto) async {
    final db = await database;
    return await db.update(
      'progetto', 
      newProgetto.toMap(),
      where: 'nome = ?',
      whereArgs: [oldNomeProgetto],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Elimina un progetto 
  Future<int> deleteProgetto(String nomeProgetto) async {
    final db = await database;
    
    return await db.delete(
      'progetto',
      where: 'nome = ?',
      whereArgs: [nomeProgetto],
    );
  }

  /// Cerca un Progetto dato un nome
  Future<Progetto?> selectProgettoByNome(String nome) async {
    final db = await database;
    final List<Map<String, Object?>> progetto = await db.query(
      'progetto',
      where: 'nome = ?',
      whereArgs: [nome],
    );

    if (progetto.isEmpty) {
      return null;
    } else {
      return Progetto(
        nome: progetto[0]['nome'] as String,
        team: progetto[0]['team'] as String,
        scadenza: progetto[0]['scadenza'] as String,
        stato: progetto[0]['stato'] as String,
        descrizione: progetto[0]['descrizione'] as String,
        completato: progetto[0]['completato'] == null 
          ? null // se completato è null allora il valore è null
          : (progetto[0]['completato'] as int) == 1, // 'completato' se non è null allora deve essere un booleano ma nella tabella è un integer
        motivazioneFallimento: progetto[0]['motivazioneFallimento'] as String?,
      );
    }
  }

  /// Seleziona i progetti associati ad un dato team
  Future<List<Progetto>> selectProgettiByTeam(String nomeTeam) async {
    final db = await database;
    final List<Map<String, Object?>> progetti = await db.query(
      'progetto',
      where: 'team = ?',
      whereArgs: [nomeTeam],
    );
 
    return progetti.map((progetto) =>
      Progetto(
        nome: progetto['nome'] as String,
        team: progetto['team'] as String,
        scadenza: progetto['scadenza'] as String,
        stato: progetto['stato'] as String,
        descrizione: progetto['descrizione'] as String,
        completato: progetto['completato'] == null
          ? null // se completato è null allora il valore è null
          : (progetto['completato'] as int) == 1, // 'completato' se non è null allora deve essere un booleano ma nella tabella è un integer
        motivazioneFallimento:
            progetto['motivazioneFallimento'] as String?
      )).toList();
  }

  /// Restituisce una lista contenti tutti i progetti memorizzati nel db
  Future<List<Progetto>> getAllProgetti() async {
  final db = await database;

  final List<Map<String, Object?>> progettoMaps = await db.query('progetto');
    return [
      for (final {
        'nome': nome as String,
        'team': team as String,
        'scadenza': scadenza as String,
        'stato': stato as String,
        'descrizione': descrizione as String,
        'completato': completato as int?,
        'motivazioneFallimento': motivazioneFallimento as String?,
      } in progettoMaps)
        Progetto(
          nome: nome,
          team: team,
          scadenza: scadenza,
          stato: stato,
          descrizione: descrizione,
          completato: completato == null 
            ? null // se completato è null allora il valore è null
            : completato == 1, // 'completato' se non è null allora deve essere un booleano ma nella tabella è un integer
           motivazioneFallimento: motivazioneFallimento,
        ),
    ];
  }

  /// Restituisce quanti progetti sono completati
  /// ossia quelli per cui il booleano è true e la motivazione di fallimento è null
  Future<int> getNumProgettiCompletati() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('''
        SELECT COUNT(*) 
        FROM progetto 
        WHERE completato == 1
      '''
      )
    ) ?? 0;
  }

  /// Restitusce quanti progetti sono falliti
  /// ossia quelli per cui il booleano è false e neppure la motivazione di fallimento non è null
  Future<int> getNumProgettiFalliti() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('''
        SELECT COUNT(*) 
        FROM progetto 
        WHERE completato == 0 
      '''
      )
    ) ?? 0;
  }
  
  /// Restituisce il numero di progetti nel DB
  Future<int> countProgetti() async {
    final db = await database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM progetto')) ?? 0;
  }

  /// Restituisce tutti i progetti che hanno lo stato specificato.
  /// Ricorda: '''stato IN ('attivo', 'sospeso', 'archiviato')'''
  Future<List<Progetto>?> getProgettiByState(String stato) async {
    // se lo stato richiesto è non valido ritorna un errore
    if(!['attivo', 'sospeso', 'archiviato'].contains(stato)) {
      return [];
    }

    final db = await database;

    // query per ottenere i progetti con lo stato richiesto
    final List<Map<String, Object?>> progetti = await db.query(
      'progetto',
      where: 'stato = ?',
      whereArgs: [stato]
    );

    try {
      if(progetti.isEmpty) {
        return null;
      } else {
        return [
          for ( final {
            'nome': nome as String,
            'team': team as String,
            'scadenza': scadenza as String,
          //'stato': è già fornito come parametro
            'descrizione': descrizione as String?,
            'completato': completato as int?,
            'motivazioneFallimento': motiv as String?,
          } in progetti) 
            Progetto(nome: nome, team: team, scadenza: scadenza, stato: stato, /// lo stato è quello passato come argomento
              descrizione: descrizione, motivazioneFallimento: motiv,
              completato: completato != null 
                ? completato == 1 
                : null
            ),
        ];
      }
    } catch (e) {
      print('Errore nella query del database: $e');
      return [];
    }
  } 

  /*
    ### INTERAZIONE CON I TEAM ###
  */
  /// Inserisci un nuovo team nel db
  Future<void> insertTeam(Team team) async {
    final db = await database;
    await db.insert(
      'team',
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Esegue un UPDATE sulla tabella team, sostituisce il team con nome oldNomeTeam con il i dati del team newTeam
  Future<int> updateTeam(String oldNomeTeam, Team newTeam) async {
    final db = await database;
    return await db.update(
      'team', 
      newTeam.toMap(),
      where: 'nome = ?',
      whereArgs: [oldNomeTeam],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Elimina un team dalla tabella team
  Future<int> deleteTeam(Team team) async {
    final db = await database;

    return await db.delete(
      'team',
      where: 'nome = ?',
      whereArgs: [team.nome],
    );
  }

  /// Cerca un team dato un nome
  Future<Team?> selectTeamByNome(String nome) async {
    final db = await database;
    final List<Map<String, Object?>> team = await db.query(
      'team',
      where: 'nome = ?',
      whereArgs: [nome],
    );

    if (team.isEmpty) {
      return null;
    } else {
      return Team(
        nome: team[0]['nome'] as String,
      );
    }
  }

  /// query per sapere chi è il responsabile del team
  Future<Utente?> getTeamManager(String teamName) async {
    final db = await database;
    // prima prendo la matricola del responsabile
    final List<Map<String, Object?>> utente = await db.rawQuery('''
        SELECT *
        FROM utente
        WHERE matricola IN (
          SELECT utente 
          FROM partecipazione
          WHERE team = ? AND ruolo = 1
        )
      '''
      , [teamName]
    );

    if (utente.isEmpty) {
      return null;
    } else {
      return Utente(
        matricola: utente[0]['matricola'] as String, 
        nome: utente[0]['nome'] as String, 
        cognome: utente[0]['cognome'] as String
      );
    }
  }

  /// Restituisce una lista contenente tutti i team della tabella 'team' 
  Future<List<Team>> getAllTeams() async {
    final db = await database;

    final List<Map<String, Object?>> teamMaps = await db.query('team');

    return [
      for (final {
            'nome': nome as String,
          } in teamMaps)
        Team(nome: nome),
    ];
  }
  
  /*
    ### INTERAZIONE CON LE TASK ###
  */
  /// Inserisci un utente nella tabella task
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'task',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Esegue un UPDATE su una Task
  Future<int> updateTask(int oldId, String oldProjectName, Task task) async {
    final db = await database;
    return await db.update(
      'task', 
      task.toMap(),
      where: 'id = ? AND progetto = ?',
      whereArgs: [oldId, oldProjectName],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Inverte lo stato di completamento di un task, se è non completato viene impstato a completato e viceversa
  Future<int> toggleStateTask(Task task) async {
    final db = await database;
    return await db.update(
      'task', 
      {'completato': !task.completato},
      where: 'id = ? AND progetto = ?',
      whereArgs: [task.id, task.progetto],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  /// Elimina un task dalla tabella utente
  Future<int> deleteTask(Task task) async {
    final db = await database;
    return await db.delete(
      'task',
      where: 'id = ? AND progetto = ?',
      whereArgs: [task.id, task.progetto],
    );
  }

  /// Cerca un Utente data una matricola
  Future<Task?> selectTaskByIdAndProject(int id, String nomeProgetto) async {
    final db = await database;
    final List<Map<String, Object?>> task = await db.query(
      'task',
      where: 'id = ? AND progetto = ?',
      whereArgs: [id, nomeProgetto],
    );

    if (task.isEmpty) {
      return null;
    } else {
      return Task(
        id: task[0]['id'] as int,
        progetto: task[0]['progetto'] as String,
        attivita: task[0]['attivita'] as String,
        completato: (task[0]['completato'] as int) == 1,
      );
    }
  }

  /// per prendere tutti i task di un progetto
  Future<List<Task>> getTasksByProject(String projectName) async {
    final db = await database;
    final List<Map<String, Object?>> taskMaps = await db.query(
      'task',
      where: 'progetto = ?',
      whereArgs: [projectName],
    );

    return taskMaps.map((taskMap) {
      return Task(
        id: taskMap['id'] as int,
        progetto: taskMap['progetto'] as String,
        attivita: taskMap['attivita'] as String,
        completato: (taskMap['completato'] as int) == 1,
      );
    }).toList();
  }

  /// Restituisce una lista contenente tutti gli utenti della tabella 'utente' 
  Future<List<Task>> getAllTasks() async {
    final db = await database;

    final List<Map<String, Object?>> taskMaps = await db.query('task');

    return [
      for (final {
            'id': id as int,
            'progetto': progetto as String,
            'attivita': attivita as String,
            'completato': completato as int,
          } in taskMaps)
        Task(id: id, progetto: progetto, attivita: attivita, completato: completato == 1),
    ];
  }

  /*
    ### INTERAZIONE CON PARTECIPAZIONE ###
    Note: questa tabella associa utente e team
  */
  /// inserisci nuova partecipazione
  Future<void> insertPartecipazione(Partecipazione part) async {
    final db = await database;
    await db.insert(
      'partecipazione',
      part.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Esegue un UPDATE sulla tabella partecipazione
  Future<int> updatePartecipazione(String utente, bool ruolo, Partecipazione oldPart) async {
    final db = await database;
    return await db.update(
      'partecipazione', 
      {'utente': utente, 'ruolo': ruolo ? 1 : 0},
      where: 'utente = ? AND team = ?',
      whereArgs: [oldPart.utente, oldPart.team],
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Elimina un utente dalla tabella partecipazione
  Future<int> deletePartecipazione(Partecipazione part) async {
    final db = await database;
    return await db.delete(
      'partecipazione',
      where: 'utente = ? AND team = ?',
      whereArgs: [part.utente, part.team],
    );
  }

  /// Restituisce le partecipazioni ad un team 
  Future<List<Partecipazione>?> selectPartecipazioniOfTeam(String nomeTeam) async {
    final db = await database;
    final List<Map<String, Object?>> parts = await db.query(
      'partecipazione',
      where: 'team = ?',
      whereArgs: [nomeTeam],
    );

    return [
      for (final {
          'utente': utente as String, 
          'team': team as String,
          'ruolo': ruolo as int,
        } in parts )
        Partecipazione(team: team, utente: utente, ruolo: ruolo == 1),
    ];
  }

  /// Cerca una partecipazione dati utente e team 
  Future<Partecipazione?> selectPartecipazioneByUtenteAndTeam(String matricolaUtente, String nomeTeam) async {
    final db = await database;
    final List<Map<String, Object?>> parts = await db.query(
      'partecipazione',
      where: 'utente = ? AND team = ?',
      whereArgs: [matricolaUtente, nomeTeam],
    );

    if (parts.isEmpty) {
      return null;
    } else {
      return Partecipazione(
        utente: parts[0]['utente'] as String, 
        team: parts[0]['team'] as String,
        ruolo: (parts[0]['ruolo'] as int) == 1
      );
    }
  }

  /// Seleziona gli utenti di un team dato il nome del team
  Future<List<Utente>> selectUtentiByTeam(String nomeTeam) async {
    final db = await database;
    // uso una query per estrarre gli utenti che partecipano al team richiesto
    // la query non restituisce direttamente una lista do utenti ma una lista
    // contenete mappe che contengono i dati di ciascun utente
    // sarà dunque necessario rimappare ogni mappa in una istanza di Utente
    final List<Map<String, Object?>> utentiDelTeam = await db.rawQuery('''
        SELECT matricola, nome, cognome
        FROM utente JOIN partecipazione 
          ON utente.matricola = partecipazione.utente
        WHERE partecipazione.team = ?
    '''
    , [nomeTeam]);
    /// ritorno gli utenti creati dai dati forniti dalle mappe come detto prima
    return utentiDelTeam.map((m) => Utente(
      matricola: m['matricola'] as String,
      nome: m['nome'] as String,
      cognome: m['cognome'] as String,
    )).toList();
  }

  /// seleziona le matricole degli utenti del team
  /// UTILIZZATA IN MODIFICA TEAM
  Future<List<String>> selectMatricoleByTeam(String nomeTeam) async {
    final db = await database;
    // uso una query per estrarre le matricole degli utenti che partecipano al team richiesto
    final List<Map<String, Object?>> matricoleUtenti = await db.rawQuery('''
        SELECT matricola
        FROM utente JOIN partecipazione 
          ON utente.matricola = partecipazione.utente
        WHERE partecipazione.team = ?
    '''
    , [nomeTeam]);
    // restituisco le matricole degli utenti
    return matricoleUtenti.map((m) =>
      m['matricola'] as String,
    ).toList();
  }

  /// ritorna il numero di utenti nel DB
  Future<int> countUtentiTeam(String nomeTeam) async {
    final db = await database;
    final List<Map<String, Object?>> conteggio = await db.rawQuery('''
        SELECT count(*)
        FROM utente JOIN partecipazione 
          ON utente.matricola = partecipazione.utente
        WHERE partecipazione.team = ?
    '''
    , [nomeTeam]);
    int numUtentiTeam = Sqflite.firstIntValue(conteggio) ?? 0;
    return numUtentiTeam;
  }

  /// Metodo per la dashboard sui 3 team più grandi, mi restituisce i nomi dei team
  Future<List<String>?> getTeamPiuGrandi(int limit) async {
    final db = await database;
    final List<Map<String, Object?>> teamNumerosi = await db.rawQuery('''
        SELECT p.team, count(*) as numUtenti
        FROM utente u
          JOIN partecipazione p ON u.matricola = p.utente
        GROUP BY p.team
        ORDER BY numUtenti DESC
        LIMIT ?
    ''', [limit]
    );

    return teamNumerosi.map((t) => t['team'] as String).toList();
  }

  /// Restituisce una lista contenente tutti gli utenti della tabella 'utente' 
  Future<List<Partecipazione>> getAllPartecipazioni() async {
    final db = await database;

    final List<Map<String, Object?>> utenteMaps = await db.query('partecipazione');

    return [
      for (final {
            'utente': utente as String,
            'team': team as String,
            'ruolo': ruolo as int,
          } in utenteMaps)
        Partecipazione(utente: utente, team: team, ruolo: ruolo == 1),
    ];
  }

  /// ## METODO DI TESTING per popolare il DB con valori di default ##
  /*
  Future<void> populateDatabase() async {
    
    // Crea alcune istanze di Utente
    Utente utente1 = Utente(matricola: '00001', nome: 'Mario', cognome: 'Rossi');
    Utente utente2 = Utente(matricola: '00002', nome: 'Luigi', cognome: 'Verdi');
    Utente utente3 = Utente(matricola: '00003', nome: 'Anna', cognome: 'Bianchi');

    // Crea alcune istanze di Team
    Team team1 = Team(nome: 'Team Alpha');
    Team team2 = Team(nome: 'Team Beta');

    // Crea istanze di progetto
    Progetto progetto1 = Progetto(nome: 'progetto1', team: 'Team Alpha', stato: 'attivo', scadenza: '2020-05-20', descrizione: 'progetto test1');
    Progetto progetto2 = Progetto(nome: 'progetto2', team: 'Team Beta', stato: 'sospeso', scadenza: '2020-05-20', descrizione: 'progetto test1');
    Progetto progetto3 = Progetto(nome: 'progetto3', team: 'Team Alpha', stato: 'archiviato', scadenza: '2020-05-20', descrizione: 'progetto test1', completato: true);

    // Crea istanze di task
    Task task11 = Task(id: 0, attivita: 'task0 prg1', progetto: 'progetto1', completato: false);
    Task task12 = Task(id: 1, attivita: 'task1 prg1', progetto: 'progetto1', completato: true);
    Task task21 = Task(id: 0, attivita: 'task0 prg2', progetto: 'progetto2', completato: false);
    Task task22 = Task(id: 1, attivita: 'task1 prg2', progetto: 'progetto2', completato: true);
    Task task31 = Task(id: 0, attivita: 'task0 prg3', progetto: 'progetto3', completato: false);
    Task task32 = Task(id: 1, attivita: 'task1 prg3', progetto: 'progetto3', completato: true);

    // Inserisci gli utenti nel database
    await insertUtente(utente1);
    await insertUtente(utente2);
    await insertUtente(utente3);

    // Inserisci i team nel database
    await insertTeam(team1);
    await insertTeam(team2);

    // team alpha
    await insertPartecipazione(Partecipazione(utente: utente1.matricola, team: team1.nome, ruolo: false));
    await insertPartecipazione(Partecipazione(utente: utente2.matricola, team: team1.nome, ruolo: true));
    // team beta
    await insertPartecipazione(Partecipazione(utente: utente1.matricola, team: team2.nome, ruolo: true));
    await insertPartecipazione(Partecipazione(utente: utente3.matricola, team: team2.nome, ruolo: false));

    await insertProgetto(progetto1);
    await insertProgetto(progetto2);
    await insertProgetto(progetto3);

    await insertTask(task11);
    await insertTask(task12);
    await insertTask(task21);
    await insertTask(task22);
    await insertTask(task31);
    await insertTask(task32);
  }
  */
}
