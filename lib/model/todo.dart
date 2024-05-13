//questa classe si occupa dei singoli todo
class Todo {
  //ciascun todo ha un id numerico univoco, una descrizione ed un booleano per lo stato
  int id;
  String description;
  bool completed;
  
  //rappresenta il mio costruttore
  Todo({
    required this.id,
    required this.description,
    this.completed = false,
  });
  
  //restituisce la lista
  static List<Todo> todoList() {
    return [];
  }
}