//questa classe si occupa dei singoli task
class Task {
  //ciascun task ha un id numerico univoco, una descrizione ed un booleano per lo stato
  int id;
  String description;
  bool completed;
  
  //rappresenta il mio costruttore
  Task({
    required this.id,
    required this.description,
    this.completed = false,
  });
  
  //restituisce la lista
  static List<Task> taskList() {
    return [];
  }
}