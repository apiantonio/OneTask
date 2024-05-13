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
            completato BOOLEAN CHECK (completato IS NULL OR
              (completato IS NOT NULL AND stato = 'archiviato')),
            motivazioneFallimento TEXT CHECK (motivazioneFallimento IS NULL OR 
              (motivazioneFallimento IS NOT NULL AND completato = false))
          )''');
          await db.execute('''
          CREATE TABLE task (
            nome TEXT PRIMARY KEY,
            team TEXT REFERENCES team(nome) ON DELETE CASCADE ON UPDATE CASCADE,
            scadenza TEXT NOT NULL,
            stato VARCHAR(10) NOT NULL CHECK (stato IN ('attivo', 'scaduto', 'archiviato')),
            descrizione TEXT NOT NULL,
            completato BOOLEAN CHECK (completato IS NULL OR
              (completato IS NOT NULL AND stato = 'archiviato')),
            motivazioneFallimento TEXT CHECK (motivazioneFallimento IS NULL OR 
              (motivazioneFallimento IS NOT NULL AND completato = false))
          )''');
      },
      version: 1,
    );
  }

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
        "utente", 
        utente.toMap(),
        where: 'matricola = ?',
        whereArgs: [utente.matricola],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Elimina un utente dalla tabella utente
  Future<int> deleteUtente(Utente utente) async {
    final db = await database;
    return await db.delete(
      "utente",
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
  Future<List<Utente>> getAllutente() async {
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
  
}