import 'package:OneTask/model/partecipazione.dart';
import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/model/team.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:OneTask/model/utente.dart';  

// singleton che gestisce il database
class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  // crea una connessione col db e crea le tabelle
  Future<Database> _initDatabase() async {
    return openDatabase(
      // getdatabasePath restituisce la directory del db che varia a seconda dell'OS
      // il db si chiamerà OneTask_database
      join(await getDatabasesPath(), 'OneTask_database.db'),
      onCreate: (db, version) async {
        // creo le tabelle del database
        await db.execute(
          'CREATE TABLE utente (matricola INTEGER PRIMARY KEY, nome TEXT, cognome TEXT)'
        );
        await db.execute(
          'CREATE TABLE team (nome TEXT PRIMARY KEY)'
        );
        await db.execute('''
          CREATE TABLE partecipazione (
            utente INTEGER NOT NULL REFERENCES utente(matricola) ON DELETE CASCADE ON UPDATE CASCADE, 
            team TEXT NOT NULL REFERENCES team(nome) ON DELETE CASCADE ON UPDATE CASCADE, 
            ruolo BOOLEAN NOT NULL,
            PRIMARY KEY(utente, team)
          )''');
        await db.execute('''
          CREATE TABLE progetto (
            nome TEXT PRIMARY KEY,
            team TEXT REFERENCES team(nome) ON DELETE CASCADE ON UPDATE CASCADE,
            scadenza TEXT NOT NULL,
            stato VARCHAR(10) NOT NULL CHECK (stato IN ('attivo', 'scaduto', 'archiviato')),
            descrizione TEXT NOT NULL,
            completato INTEGER CHECK (completato IS NULL OR
              (completato IS NOT NULL AND stato = 'archiviato')),
            motivazioneFallimento TEXT CHECK (motivazioneFallimento IS NULL OR 
              (motivazioneFallimento IS NOT NULL AND completato = false))
          )''');
          await db.execute('''
          CREATE TABLE task (
            id INTEGER PRIMARY KEY,
            progetto TEXT NOT NULL REFERENCES progetto(nome) ON DELETE CASCADE ON UPDATE CASCADE,
            attivita TEXT NOT NULL,
            completato INTEGER NOT NULL
          )''');
      },
      version: 1,
    );
  }

  /*
    ### INTERAZIONE CON GLI UTENTI ###
  */
  // Inserisci un utente nella tabella utente
  Future<void> insertUtente(Utente utente) async {
    final db = await database;
    await db.insert(
      'utente',
      utente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Esegue un UPDATE sulla tabella utente
  Future<int> updateUtente(Utente utente) async {
    final db = await database;
    return await db.update(
      'utente', 
      utente.toMap(),
      where: 'matricola = ?',
      whereArgs: [utente.matricola],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Elimina un utente dalla tabella utente
  Future<int> deleteUtente(Utente utente) async {
    final db = await database;
    return await db.delete(
      'utente',
      where: 'matricola = ?',
      whereArgs: [utente.matricola],
    );
  }

  // Cerca un Utente data una matricola
  Future<Utente?> selectUtenteByMatricola(int matricola) async {
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
        matricola: utente[0]['matricola'] as int,
        nome: utente[0]['nome'] as String,
        cognome: utente[0]['cognome'] as String,
      );
    }
  }

  // Restituisce una lista contenente tutti gli utenti della tabella 'utente' 
  Future<List<Utente>> getAllUtenti() async {
    final db = await database;

    final List<Map<String, Object?>> utenteMaps = await db.query('utente');

    return [
      for (final {
            'matricola': matricola as int,
            'nome': nome as String,
            'cognome': cognome as String,
          } in utenteMaps)
        Utente(matricola: matricola, nome: nome, cognome: cognome),
    ];
  }

  /*
    ### INTERAZIONE CON I PROGETTI ###
  */
  // Inserisci un nuovo progetto nel db
  Future<void> insertProgetto(Progetto progetto) async {
    final db = await database;
    await db.insert(
      'progetto',
      progetto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // Esegue un UPDATE sulla tabella progetto
  Future<int> updateProgetto(Progetto progetto) async {
    final db = await database;
    return await db.update(
      'progetto', 
      progetto.toMap(),
      where: 'nome = ?',
      whereArgs: [progetto.nome],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Elimina un progetto 
  Future<int> deleteProgetto(Progetto progetto) async {
    final db = await database;
    return await db.delete(
      'progetto',
      where: 'mome = ?',
      whereArgs: [progetto.nome],
    );
  }

  // Cerca un Progetto dato un nome
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
        completato: (progetto[0]['completato'] as int) == 1, // 'completato' deve essere un booleano ma nella tabella è un integer
        motivazioneFallimento: progetto[0]['motivazioneFallimento'] as String?,
      );
    }
  }

  // Restituisce una lista contenti tutti i progetti memorizzati nel db
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
        'completato': completato as int,
        'motivazioneFallimento': motivazioneFallimento as String?,
      } in progettoMaps)
        Progetto(
          nome: nome,
          team: team,
          scadenza: scadenza,
          stato: stato,
          descrizione: descrizione,
          completato: completato == 1, // 'completato' deve essere un booleano ma nella tabella è un integer che assume valori 0 o 1
          motivazioneFallimento: motivazioneFallimento,
        ),
    ];
  }

  /*
    ### INTERAZIONE CON I TEAM ###
  */
  // Inserisci un nuovo team nel db
  Future<void> insertTeam(Team team) async {
    final db = await database;
    await db.insert(
      'team',
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Esegue un UPDATE sulla tabella team
  Future<int> updateTeam(Team team) async {
    final db = await database;
    return await db.update(
      'team', 
      team.toMap(),
      where: 'nome = ?',
      whereArgs: [team.nome],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Elimina un team dalla tabella team
  Future<int> deleteTeam(Team team) async {
    final db = await database;
    return await db.delete(
      'team',
      where: 'nome = ?',
      whereArgs: [team.nome],
    );
  }

  // Cerca un team dato un nome
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

  // Restituisce una lista contenente tutti i team della tabella 'team' 
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
  // Inserisci un utente nella tabella task
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.insert(
      'task',
      task.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Esegue un UPDATE sulla tabella utente
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'task', 
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Elimina un task dalla tabella utente
  Future<int> deleteTask(Task task) async {
    final db = await database;
    return await db.delete(
      'task',
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Cerca un Utente data una matricola
  Future<Task?> selectTaskById(int id) async {
    final db = await database;
    final List<Map<String, Object?>> task = await db.query(
      'task',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (task.isEmpty) {
      return null;
    } else {
      return Task(
        id: task[0]['id'] as int,
        description: task[0]['description'] as String,
        completed: (task[0]['completed'] as int) == 1,
      );
    }
  }

  // Restituisce una lista contenente tutti gli utenti della tabella 'utente' 
  Future<List<Task>> getAllTasks() async {
    final db = await database;

    final List<Map<String, Object?>> taskMaps = await db.query('task');

    return [
      for (final {
            'id': id as int,
            'description': description as String,
            'completed': completed as int,
          } in taskMaps)
        Task(id: id, description: description, completed: completed == 1),
    ];
  }

  /*
    ### INTERAZIONE CON PARTECIPAZIONE ###
    Note: questa tabella associa utente e team
  */
  // inserisci nuova partecipazione
  Future<void> insertPartecipazione(Partecipazione part) async {
    final db = await database;
    await db.insert(
      'partecipazione',
      part.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Esegue un UPDATE sulla tabella partecipazione
  Future<int> updatePartecipazione(Partecipazione part) async {
    final db = await database;
    return await db.update(
      'partecipazione', 
      part.toMap(),
      where: 'utente = ? AND team = ?',
      whereArgs: [part.utente, part.team],
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Elimina un utente dalla tabella partecipazione
  Future<int> deletePartecipazione(Partecipazione part) async {
    final db = await database;
    return await db.delete(
      'partecipazione',
      where: 'utente = ? AND team = ?',
      whereArgs: [part.utente, part.team],
    );
  }

  // Cerca un Utente data una matricola
  Future<Partecipazione?> selectPartecipazioneByUtenteAndTeam(int matricolaUtente, String nomeTeam) async {
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
        utente: parts[0]['utente'] as int, 
        team: parts[0]['team'] as String,
        ruolo: (parts[0]['ruolo'] as int) == 1
      );
    }
  }

  // Restituisce una lista contenente tutti gli utenti della tabella 'utente' 
  Future<List<Partecipazione>> getAllPartecipazioni() async {
    final db = await database;

    final List<Map<String, Object?>> utenteMaps = await db.query('partecipazione');

    return [
      for (final {
            'utente': utente as int,
            'team': team as String,
            'ruolo': ruolo as bool,
          } in utenteMaps)
        Partecipazione(utente: utente, team: team, ruolo: ruolo == 1),
    ];
  }

  
}