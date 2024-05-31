import 'package:OneTask/main.dart';
import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/task_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../widgets/tasks_list.dart';
import '../widgets/team_dashboard_widget.dart';
import '../widgets/view_dashboard_team.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
          children: [
            ViewDasboardProjects(),
            SizedBox(height: 20), // Spazio tra le sezioni
            ViewDashboardTeam(),
          ]
        ),
      ),
    );
  }
}
 

class ViewDasboardProjects extends StatelessWidget {
  const ViewDasboardProjects({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Progetto>?>(
      //future: DatabaseHelper.instance.getProgettiByState('attivo'), // i progetti attivi
      future: DatabaseHelper.instance.getAllProgetti(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError){
          print('Errore caricamento progetti dal db: ${snapshot.error}'); 
          return const Text('Errore caricamento progetti dal db');
        } else {  
          // team composti da più utenti
          List<Progetto> projects = snapshot.data ?? [];
    
          if(projects.isEmpty) {
            return const Center(child: Text('Nessun progetto presente al momento'));
          }else{
            return SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // lista orizzontale dei progetti
                shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                itemCount:  projects.length < 5 ? projects.length : 5, // se ci sono meno di 5 progetti allora renderizza solo quelli
                itemBuilder: (context, index) {
                  Progetto project = projects[index];
                  return Container(
                    width: 300, // Larghezza fissa per ogni elemento, regola secondo necessità
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.symmetric(horizontal: 8.0), // Spazio tra gli elementi
                    child: ProjectDashboardWidget(progetto: project)
                  );
                }
              ),
            );
          }
        }
      }
    );
  }
}

class ProjectDashboardWidget extends StatefulWidget {
  final Progetto progetto;

  const ProjectDashboardWidget({super.key, required this.progetto});

  @override
  State<ProjectDashboardWidget> createState() => _ProjectDashboardWidgetState();
}

class _ProjectDashboardWidgetState extends State<ProjectDashboardWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: DatabaseHelper.instance.getTasksByProject(widget.progetto.nome),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Errore nel caricamento info delle task del progetto'));
        } else {

          List<Task> tasks = snapshot.data?.where((task) => task.completato == false).toList() ?? [];

          return InkWell( // utile per impostare funzioni in reazioni a gesture dell'utente (es: onTap)
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewProject(projectName: widget.progetto.nome)),
            ),
            // aggiungere bordi tondi a inkwell
            splashColor: Colors.blue, 
            child: Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.progetto.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const Icon(Icons.calendar_month, size: 20),
                            const SizedBox(height: 5),
                            Text(
                              widget.progetto.scadenza,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    DashboardTasks(tasks: tasks, onTapTask: _changeStateTask),
                  ],
                ),
              ),
          );
        }
      }
    );
  }

  void _changeStateTask(Task task) {
    setState(() {  
      DatabaseHelper.instance.toggleStateTask(task);
    });
  }
}

class DashboardTasks extends StatelessWidget {
  const DashboardTasks({super.key, required this.tasks, required this.onTapTask});

  final List<Task> tasks;
  final void Function(Task task) onTapTask;

  @override
  Widget build(BuildContext context) {
    final ScrollController _scrollController = ScrollController(); // controller necessario per lo scroll delle task

    return SizedBox(
      height: 155, // Altezza fissa per la lista dei task
      child: Scrollbar(
       controller: _scrollController, // controller dello scroll che deve essere associato anche a SingleChildScrollView
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: tasks.map((task) => 
              InkWell(
                onTap: () => onTapTask(task),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0), // spazio verticale tra i tasks
                  child: Row(
                    children: [
                      task.completato ? const Icon(Icons.check_box, size: 24) : const Icon(Icons.check_box_outline_blank, size: 24),
                      const SizedBox(width: 10), // spazio orizzontale tra l'icona e il testo
                      Expanded(
                        child: Text(
                          task.attivita,
                          style: TextStyle(fontSize: 16),
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