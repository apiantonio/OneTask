/// Questa classe rappresenta i singoli team 
class Team { 
  // ogni team ha un nome univoco
  String nome;

  //rappresenta il mio costruttore
  Team({
    required this.nome
  });
  
  // crea una mappa per un task
  Map<String, Object?> toMap() {
    return {'nome': nome};
  }

  @override
  String toString() {
    return 'Team{nome: $nome}';
  }
}