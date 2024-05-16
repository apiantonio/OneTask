//questa classe rappresenta l'associazione tra utente e team
class Partecipazione {
  //ciascuna partecipazione ha la coppua (utente, team) univoca
  final String utente;
  final String team;
  final bool ruolo; // se true allora è manager altrimenti è dipendente
  
  // costruttore
  Partecipazione({
    required this.utente,
    required this.team,
    this.ruolo = false,
  });
  
  // partecipazione come mappa
  Map<String, Object?> toMap() {
    return {
      'utente': utente,
      'team': team,
      'ruolo': ruolo ? 1 : 0,
    };
  }

  // Rappresentazione testuale della classe
  @override
  String toString() {
    return 'Partecipazione{utente: $utente, team: $team, ruolo: ${ruolo ? "manager" : "dipendente"}}';
  }
  
}