
import 'package:OneTask/model/task.dart';
import 'package:flutter/material.dart';

//un nuovo widget per ciascun todo
class TaskItem extends StatelessWidget {
  const TaskItem({Key? key, required this.task, required this.onChangeTask, required this.onDeleteTask}) : super(key: key);
  final Task task;    //un oggetto di tipo task
  final onChangeTask;
  final onDeleteTask;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(    //una sola riga della lista
        onTap: () {onChangeTask(task);},   //azione quando premi sulla riga
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.blue.shade50,  //sfondo della riga
        title: Text(
          task.description,
        ),
        leading: task.completed ? Icon(Icons.check_box) : Icon(Icons.check_box_outline_blank),     //icona a sinistra, se completato abbiamo il check, altrimenti la casella vuota
        trailing: IconButton(   //icona a destra
          iconSize: 16,
          icon: Icon(Icons.remove),
          color: Colors.black,
          onPressed: () {onDeleteTask(task);},   //cosa fare quando premi sul bottone a destra
        )
    );
  }
}