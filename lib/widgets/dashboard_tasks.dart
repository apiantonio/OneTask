import 'package:OneTask/model/task.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget che si occupa della visualizzazione delle task non completate del progetto nella dashboard
class DashboardTasks extends StatelessWidget {
  const DashboardTasks({super.key, required this.tasks, required this.onTapTask});

  final List<Task> tasks;
  final void Function(Task task) onTapTask;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController(); // controller necessario per lo scroll delle task

    return SizedBox(
      height: 170, // Altezza fissa per la lista dei task
      child: Scrollbar(
        controller: scrollController, // controller dello scroll che deve essere associato anche a SingleChildScrollView
        thumbVisibility: true,    //per rendere sempre visibile la scrollbar
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            children: tasks.map((task) => 
              InkWell(
                onTap: () => onTapTask(task),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0), // spazio verticale tra i tasks
                  child: Row(
                    children: [
                      task.completato ? const Icon(Icons.check_box, size: 24, color: Color(0XFF0E4C56)) : const Icon(Icons.check_box_outline_blank, size: 24, color: Color(0XFF0E4C56)),
                      const SizedBox(width: 10), // spazio orizzontale tra l'icona e il testo
                      // necessario per rendere il testo flexible in modo che non causi oveflow
                      Expanded( 
                        child: Text(
                          task.attivita,
                          style: GoogleFonts.inter(
                            fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ).toList(),
          ),
        ),
      ),
    );
  }
}