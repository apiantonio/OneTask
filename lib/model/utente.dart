// classe che rappresenta l'utente
class Utente {
  final int matricola;
  String nome;
  String cognome;

  Utente({
      required this.matricola,
      required this.cognome,
      required this.nome,
  });

  // Converte un Utente in una Map; le chiavi sono le colonne
  // della tabella 'utenti' nel database
  Map<String, Object?> toMap() {
    return {'matricola': matricola, 'nome': nome, 'cognome': cognome};
  }

  @override
  String toString() {
    return 'Utente{matricola: $matricola, nome: $nome, cognome: $cognome}}';
  }
}