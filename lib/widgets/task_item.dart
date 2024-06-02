import 'package:OneTask/model/task.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//un nuovo widget per ciascuna task
class TaskItem extends StatelessWidget {
  const TaskItem({super.key, required this.task, required this.onChangeTask, required this.onDeleteTask});
  final Task task;    //un oggetto di tipo task
  final Function(Task) onChangeTask;
  final Function(Task) onDeleteTask;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(    //una sola riga della lista
        onTap: () {onChangeTask(task);},   //azione quando premi sulla riga
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor:const Color.fromARGB(255, 171, 197, 202),  //sfondo della riga
        //il valore contenuto in ciascun list item è il nome dell'attività
        title: Text(
          task.attivita,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.black,  
            fontWeight: FontWeight.w400,
          ),
        ),
        //icona a sinistra, se completato abbiamo il check, altrimenti la casella vuota
        leading: task.completato ? const Icon(Icons.check_box, color:Color(0XFFEB701D)) : const Icon(Icons.check_box_outline_blank, color: Color(0XFFEB701D)), 
        //a destra abbiamo l'icona che consente l'eliminazione dei task
        trailing: IconButton(   
          iconSize: 16,
          icon: const Icon(Icons.remove),
          color: const Color(0XFFEB701D),
          onPressed: () {onDeleteTask(task);},   //cosa fare quando premi sul bottone a destra
        )
    );
  }
}