import 'package:OneTask/main.dart';
import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';

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
            return ListView.builder(
              //scrollDirection: Axis.horizontal, // lista orizzontale dei progetti
              shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
              itemCount:  projects.length < 5 ? projects.length : 5, // se ci sono meno di 5 progetti allora renderizza solo quelli
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                Progetto project = projects[index];
                return ProjectDashboardWidget(progetto: project);
              }
            );
          }
        }
      }
    );
  }
}

class ProjectDashboardWidget extends StatelessWidget {
  final Progetto progetto;

  const ProjectDashboardWidget({super.key, required this.progetto});
  
  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: _taskInfo(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Errore nel caricamento info delle task del progetto'));
        } else {

          Map<String, int> taskInfo = snapshot.data ?? {'numTasks': 0, 'completate': 0};

          return ListTile(
            onTap: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => ViewProject(projectName: progetto.nome))
            ),
            title: Text(progetto.nome),
            subtitle: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 20),
                    Text(
                      '${taskInfo['completate']}/${taskInfo['numTasks']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ]
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month, size: 20),
                    Text(
                      progetto.scadenza,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ]
                ),
              ]
            ),
          );
        }
      }
    );
  }
  
  // metodo per sapere quante task ha un progetto e quante di queste sono completate
  Future<Map<String, int>> _taskInfo() async {
    
    List<Task>? tasks = await DatabaseHelper.instance.getTasksByProject(progetto.nome);
  
    int completate = tasks?.where((task) => task.completato == true).length ?? 0;
    int numTasks = tasks?.length ?? 0;    

    return {
      'numTasks': numTasks,
      'completate': completate,
    };
  }
}

