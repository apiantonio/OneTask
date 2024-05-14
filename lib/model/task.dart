//questa classe si occupa dei singoli task
class Task {
  //ciascun task ha un id numerico univoco, una descrizione ed un booleano per lo stato
  final int id;
  String description;
  bool completed;
  
  //rappresenta il mio costruttore
  Task({
    required this.id,
    required this.description,
    this.completed = false,
  });
  
  // rappresenta un task come mappa
  Map<String, Object?> toMap() {
    return {'id': id, 'description': description, 'completed': completed ? 1 : 0};
  }

  // to string
   @override
  String toString() {
    return 'Task{id: $id, description: $description, completed: ${completed ? "yes" : "no"}}';
  }

  // Restituisce una lista vuota tipata per dei Task
  static List<Task> taskList() {
    return [];
  }
}