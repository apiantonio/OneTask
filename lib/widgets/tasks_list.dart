import 'package:OneTask/model/task.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// widget di utilità per visualizzare una colonna contente una lista di tasks
class TasksList extends StatelessWidget {
  const TasksList({super.key, required this.tasks});

  final List<Task> tasks;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tasks
        .map((task) => SizedBox(
          height: 30,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: task.completato ? const Icon(Icons.check_box, color: Color(0XFF0E4C56)) : const Icon(Icons.check_box_outline_blank, color: Color(0XFF0E4C56)),
            title: Text(
              task.attivita,
              style: GoogleFonts.inter(
                fontSize: 17,
              ),
            ),
          ),
        )
      ).toList(),
    );
  }
}

