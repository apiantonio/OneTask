import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
 

class ViewDasboardProjects extends StatefulWidget {
  const ViewDasboardProjects({super.key});

  @override
  State<ViewDasboardProjects> createState() => _ViewDasboardProjectsState();
}

class _ViewDasboardProjectsState extends State<ViewDasboardProjects> {
  int _numProgettiVisualizzati = 5;

  @override
  void initState() {
    super.initState();
    _loadNumPreference();
  }

  Future<void> _loadNumPreference() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _numProgettiVisualizzati = prefs.getInt('numProgetti') ?? 5;
    });
  } 

  Future<void> _updateNumPreference(int numProgetti) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('numProgetti', numProgetti);
    
    setState(() {
      _numProgettiVisualizzati = numProgetti;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Progetto>?>(
      future: DatabaseHelper.instance.getProgettiByState('attivo'), // i progetti attivi
      //future: DatabaseHelper.instance.getAllProgetti(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError){
          print('Errore caricamento progetti dal db: ${snapshot.error}'); 
          return const Text('Errore caricamento progetti dal db');
        } else {  
          // team composti da più utenti
          List<Progetto> projects = snapshot.data ?? [];
  
          return Container(
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row( // riga che contiene il titolo 'Progetti' e il menu a tre puntini
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                      child: Text(
                        'Progetti attivi',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '$_numProgettiVisualizzati',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        PopupMenuButton<int>(
                          onSelected: (value) {
                            _updateNumPreference(value);
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 5,
                              child: Text('Mostra 5 progetti'),
                            ),
                            const PopupMenuItem(
                              value: 10,
                              child: Text('Mostra 10 progetti'),
                            ),
                            const PopupMenuItem(
                              value: 20,
                              child: Text('Mostra 20 progetti'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ), 
                projects.isEmpty 
                  ? SizedBox( // box che contiene una lista orizzontale di widget che contengono i progetti
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Nessun progetto attivo presente al momento!',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0XFFEB701D),
                            ),
                          ),
                        ),
                      )
                    )
                  : SizedBox(
                    height: 280,
                    child: ListView.builder( // se ci sono progetti mostra una lista orizzontale
                      scrollDirection: Axis.horizontal, // lista orizzontale dei progetti
                      shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                      itemCount:  projects.length < _numProgettiVisualizzati ? projects.length : _numProgettiVisualizzati, // se ci sono meno progetti di quelli selezionati da visualizzare allora renderizza solo quelli che ci sono
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
                  )  
              ],
            ),
          );
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DashboardTasks(tasks: tasks, onTapTask: _changeStateTask),
                  ),
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
    final ScrollController scrollController = ScrollController(); // controller necessario per lo scroll delle task

    return SizedBox(
      height: 170, // Altezza fissa per la lista dei task
      child: Scrollbar(
       controller: scrollController, // controller dello scroll che deve essere associato anche a SingleChildScrollView
        thumbVisibility: true,
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
                      task.completato ? const Icon(Icons.check_box, size: 24) : const Icon(Icons.check_box_outline_blank, size: 24),
                      const SizedBox(width: 10), // spazio orizzontale tra l'icona e il testo
                      Text(
                        task.attivita,
                        style: TextStyle(fontSize: 16),
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