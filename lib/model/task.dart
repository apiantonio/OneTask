/// questa classe si occupa di rappresentare i singoli task
class Task {
  //ciascun task ha un id numerico univoco, un progetto a cui è assegnato, una descrizione ed un booleano per lo stato
  final int id;
  String progetto;
  String attivita;
  bool completato;
  
  //rappresenta il mio costruttore
  Task({
    required this.id,
    required this.progetto,
    required this.attivita,
    this.completato = false,
  });
  
  // rappresenta un task come mappa
  Map<String, Object?> toMap() {
    return {'id': id, 'progetto': progetto, 'attivita': attivita, 'completato': completato ? 1 : 0};
  }

  // to string
   @override
  String toString() {
    return 'Task{id: $id, progetto: $progetto, attivita: $attivita, completato: ${completato ? "yes" : "no"}}';
  }
}