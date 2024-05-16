// questa classe rappresenta un progetto
class Progetto {
  final String nome; 
  String team;
  String scadenza; // la data di scadenza è rappresentata come String perché in SQLite le date sono campi di testo
  String stato;
  String descrizione;
  bool? completato; // completato è un booleano che dovrà essere convertito a int per compatibilià con sqlite
  String? motivazioneFallimento; // motivazioneFallimento può essere NULL

  Progetto({
    required this.nome, // nome obbligatorio, è la chiave primaria di un progetto
    required this.team, // team del progetto obbligatorio
    required this.scadenza, // data scadenza obbligatoria
    this.stato = 'attivo', // lo stato di un progetto è di default attivo
    required this.descrizione, // la descrizione del progetto è obbligatoria
    this.completato, // inizialmente il progetto non ha info di completamento, completato sarà non null solo quando il progetto è archiviato, in quel caso se compleatto è true allora il progetto è stato completato altrimenti se completato è false allora il progettp è fallito e dovrà essere presente una motivazione
    this.motivazioneFallimento, // inizialmente la motivazioneFallimento è impostata a NULL
  });

  // converte un progetto in una mappa
  Map<String, Object?> toMap() {
    return {
      'nome': nome,
      'team': team,
      'scadenza': scadenza,
      'stato': stato,
      'descrizione': descrizione,
      'completato': completato == null 
        ? null 
        : completato == true ? 1 : 0, // Converti da booleano a integer perché in SQLite non esiste il tipo booleano che viene invece rappresentato come integer
      'motivazioneFallimento': motivazioneFallimento
    };
  }

  // metodo to string di utilità
  @override
  String toString() {
    return 'Progetto{nome: $nome, team: $team, scadenza: $scadenza, stato: $stato, descrizione: $descrizione,'
        'completato: $completato, motivazioneFallimento: $motivazioneFallimento}';
  }
}