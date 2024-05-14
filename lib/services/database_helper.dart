import 'package:OneTask/model/progetto.dart';
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
            codice INTEGER PRIMARY KEY,
            progetto TEXT NOT NULL REFERENCES progetto(nome) ON DELETE CASCADE ON UPDATE CASCADE,
            attivita TEXT NOT NULL,
            completato INTEGER NOT NULL
          )''');
      },
      version: 1,
    );
  }

  /*## INTERAZIONE CON GLI UTENTI ##*/
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

  /*## INTERAZIONE CON I PROGETTI ##*/
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
  Future<List<Progetto>> getAllProgetto() async {
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

  /*## INTERAZIONE CON I TEAM */
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
  
  
}