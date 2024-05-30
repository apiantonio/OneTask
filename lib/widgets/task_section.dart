import 'package:OneTask/model/task.dart';
import 'package:OneTask/widgets/task_item.dart';
import 'package:flutter/material.dart';

class TaskApp extends StatefulWidget{
  final Function(List<Task>) onTasksChanged; // funzione di callback per passare lo stato al wodget genitore (form NewProject)
  //i valori dei vecchi task vengono passati soltanto se siamo sulla pagina di modifica
  final List<Task>? oldTasks; // task da dover rappresentare nella lista di task 
  const TaskApp({super.key, required this.onTasksChanged, this.oldTasks});

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  //questo controller mi serve per la gestione del campo di inserimento di un task
  final TextEditingController _taskController = TextEditingController();
  // una lista di Task 
  List<Task> tasks = []; 
  int count = 0; // contatore usato per l'id delle tasks, inizia da 0

  @override
  void initState() {
    super.initState();
    if (widget.oldTasks != null) {
      tasks.addAll(widget.oldTasks ?? []);
      // associo al contatore per l'id delle task il massimo valore presente nelle task già associate al progetto
      // + 1 perché count rappresenta il prossimo id
      tasks.isEmpty 
        ? count = 0
        : count = tasks.map((task) => task.id).reduce((value, element) => value > element ? value : element); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return    
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 70,
                  margin: const EdgeInsets.only(
                    right: 10,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 0.0),
                      blurRadius: 10.0,
                      spreadRadius: 0.0,
                    )],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _taskController,
                    maxLength: 30,   //massimo 30 caratteri
                    decoration: const InputDecoration(
                      counterText: '', // Rimuove il contatore di caratteri
                      border: InputBorder.none,   //nessun bordo perchè è nel container (che mi serve per mettere ombreggiatura)
                      hintText: 'Aggiungi un task...',
                    ),
                  ),
                ),
              ),
              //widget per il bottone di aggiunta dei task al progetto
              ElevatedButton(
                onPressed: () {     //se premuto
                  _addTask(_taskController.text); // Chiamiamo la funzione per aggiungere un Task all'interno di setState
                },
                style: ButtonStyle(
                  //per impostare un padding personalizzato devo obbligatoriamente passare un materialStateProperty
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  ),
                  //vale lo stesso discorso fatto per il padding
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bordo arrotondato del pulsante
                    ),
                  ),
                ),
                child: const Icon( 
                  Icons.add,
                  size: 25,
                ),
              ),
            ]
          ),
          //è il container sempre nel widget colonna che contiene la lista di task
          Column(
            children: tasks.map((task) => 
            //uso un container in cui inglobare i singoli TaskItem perchè voglio spaziatura tra loro
              Container(
                margin: const EdgeInsets.only(bottom: 8.0),   //spazio verticale tra i container
                child: TaskItem(
                  task: task,
                  onChangeTask: _changeStateTask,
                  onDeleteTask: _deleteTask,
                ),
              ),
            ).toList(),
          ),
        ],
      );
  }

  //meTask invocato quando clicchiamo sul task
  void _changeStateTask(Task task) {
    setState(() {
      task.completato = !task.completato; 
      widget.onTasksChanged(tasks);
    });
  }

  //meTask invocato quando premiamo il - accanto a ciascun task
  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task); // Rimuoviamo il Task dalla lista di Tasks
      widget.onTasksChanged(tasks);
    });
  }

  //meTask invocato quando si preme il +. Di default i task appena creati non hanno il check
  void _addTask(String att) {
    setState(() {
      if(att.isNotEmpty) {
        tasks.add(Task(id: count++, progetto: '', attivita: att)); // Aggiungiamo un nuovo Task alla lista di Tasks
        widget.onTasksChanged(tasks);
        _taskController.clear();
      }
    });
  }
}