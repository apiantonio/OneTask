import 'package:flutter/material.dart';
import '../widgets/todo_item.dart';
import '../model/todo.dart';

class TodoApp extends StatefulWidget{
  const TodoApp({super.key});

  @override
  State<TodoApp> createState() => _ToDoAppState();
}

class _ToDoAppState extends State<TodoApp> {
  //mi restituisce una lista di Todo
  final List<Todo> todos = Todo.todoList(); 
  //questo controller mi serve per la gestione del campo di inserimento di un task
  final TextEditingController _todoController = TextEditingController();
  var count = 0;

  @override
  Widget build(BuildContext context) {
    return    
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: 10,
                    bottom: 10,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
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
                    controller: _todoController,
                    maxLength: 30,   //massimo 30 caratteri
                    decoration: InputDecoration(
                      border: InputBorder.none,   //nessun bordo perchè è nel container (che mi serve per mettere ombreggiatura)
                      hintText: 'Aggiungi un task...',
                    ),
                  ),
                ),
              ),

              //widget per il bottone di aggiunta dei task al progetto
              ElevatedButton(
                child: Icon( 
                  Icons.add,
                  size: 25,
                ),

                onPressed: () {     //se premuto
                    _addTodo(_todoController.text); // Chiamiamo la funzione per aggiungere un todo all'interno di setState
                },

                style: ButtonStyle(
                  //per impostare un padding personalizzato devo obbligatoriamente passare un materialStateProperty
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  ),
                  //vale lo stesso discorso fatto per il padding
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bordo arrotondato del pulsante
                    ),
                  ),
                ),
              ),
            ]
          ),


          //è il container sempre nel widget colonna che contiene la lista di task
          Container(
            //margin: EdgeInsets.only(bottom: 20),
            height: MediaQuery.of(context).size.height,
            child: ListView (
              //uso la funzione map per scorrere tutti i todo della lista visto che ListView non supporta il for
              //trasforma ciascun todo in un TodoItem
              children: todos.map((todo) => 
              //uso un container in cui inglobare i singoli TodoItem perchè voglio spaziatura tra loro
                Container(
                  margin: EdgeInsets.only(bottom: 8.0),   //spazio verticale tra i container
                  child: TodoItem(
                    todo: todo,
                    onChangeTodo: _changeStateTodo,
                    onDeleteTodo: _deleteTodo,
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      );
  }

  //metodo invocato quando clicchiamo sul task
  void _changeStateTodo(Todo todo) {
    setState(() {
      todo.completed = !todo.completed; 
    });
  }

  //metodo invocato quando premiamo il - accanto a ciascun task
  void _deleteTodo(Todo todo) {
    setState(() {
      todos.remove(todo); // Rimuoviamo il todo dalla lista di todos
    });
  }

  //metodo invocato quando si preme il +. Di default i task appena creati non hanno il check
  void _addTodo(String descr) {
    setState(() {
      if(descr.isNotEmpty){
        todos.add(Todo(id: count++,description: descr)); // Aggiungiamo un nuovo todo alla lista di todos
      }
    });
    _todoController.clear();
  }
}
