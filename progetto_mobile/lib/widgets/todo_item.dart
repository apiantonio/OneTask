import 'package:flutter/material.dart';
import '../model/todo.dart';

//un nuovo widget per ciascun todo
class TodoItem extends StatelessWidget {
  const TodoItem({Key? key, required this.todo, required this.onChangeTodo, required this.onDeleteTodo}) : super(key: key);
  final Todo todo;    //un oggetto di tipo todo
  final onChangeTodo;
  final onDeleteTodo;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(    //una sola riga della lista
        onTap: () {onChangeTodo(todo);},   //azione quando premi sulla riga
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.blue.shade50,  //sfondo della riga
        title: Text(
          todo.description,
        ),
        leading: todo.completed ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),     //icona a sinistra, se completato abbiamo il check, altrimenti la casella vuota
        trailing: IconButton(   //icona a destra
          iconSize: 16,
          icon: Icon(Icons.remove),
          color: Colors.black,
          onPressed: () {onDeleteTodo(todo);},   //cosa fare quando premi sul bottone a destra
        )
    );
  }
}