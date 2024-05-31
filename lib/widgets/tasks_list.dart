import 'package:OneTask/model/task.dart';
import 'package:flutter/material.dart';

/// widget di utilità per visualizzare una colonna contente una lista di tasks
class TasksList extends StatelessWidget {
  const TasksList({super.key, required this.tasks});

  final List<Task> tasks;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tasks
        .map((task) => Container(
          height: 30,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: task.completato ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank),
            title: Text(task.attivita),
          ),
        )
      ).toList(),
    );
  }
}

