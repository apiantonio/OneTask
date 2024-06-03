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
    //la paggina è contenuta interamente in un componente scrollabile
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        //è possibile immaginare la schermata in sottosezioni: una sezione relativa ai progetti, un sizedbox, 
        //ed una relativa ai team
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
  //numero di progetti visualizzati di default
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
          //print('Errore caricamento progetti dal db: ${snapshot.error}'); 
          return const Text('Errore caricamento progetti dal db');
        } else {  
          // team composti da più utenti
          List<Progetto> projects = snapshot.data ?? [];

          //si tratta del container che contiene tutti i progetti
          return Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 252, 187, 143),
              borderRadius: BorderRadius.circular(8.0),   //per far in modo che il container abbia i bordi arrotondati
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,    //quanto deve essere sfocato il bordo
                ),
              ],
            ),
            child: Column(
              children: [
                Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //nel widget padding abbiamo il testo 'Progetti attivi'
                    Padding(
                      //in questo modo setto un padding solo dal bordo sinistro
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                      child: Text(
                        'Progetti attivi',
                        style: GoogleFonts.inter(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color:const Color.fromARGB(255, 28, 98, 103),
                        ),
                      ),
                    ),
                    //in questa riga invece abbiamo il valore corrispondente al numero di progetti
                    //visualizzati al momento e il menu a 3 pallini per cambiare la scelta
                    Row(
                      children: [
                        Text(
                          '$_numProgettiVisualizzati',
                          style: GoogleFonts.inter(
                            fontSize: 18, 
                            fontWeight: FontWeight.w700,
                            color:const Color.fromARGB(255, 28, 98, 103),
                          ),
                        ),
                        //questo popmenu button è costituito da 3 item per impostare quanti
                        //progetti visualizzare nella sezione apposita della
                        PopupMenuButton<int>(
                          color: const Color(0XFFE8E5E0),   //in questo modo posso cambiare il colore del menu a tendina
                          onSelected: (value) {
                            _updateNumPreference(value);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 5,
                              child: Text(
                                'Mostra 5 progetti',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0XFF0E4C56),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 10,
                              child: Text(
                                'Mostra 10 progetti',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0XFF0E4C56),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 20,
                              child: Text(
                                'Mostra 20 progetti',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0XFF0E4C56),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ), 
                //con il codice seguente abbiamo gestito la condizione in cui non ci siano progetti registrati nel db
                projects.isEmpty 
                  ? SizedBox( 
                    //nel caso in cui non ci siano progetti un messaggio di testo avvisa di ciò
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Nessun progetto attivo presente al momento!',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0Xff167485),
                            ),
                          ),
                        ),
                      )
                    )
                  //in caso contrario vengono visualizzati i progetti
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
                          child: ProjectDashboardWidget(progetto: project),
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
          return Center(child: Text(
            'Errore nel caricamento info delle task del progetto',
            style: GoogleFonts.inter(
              fontSize: 16,
            ),
          ));
        } else {
          //per ciascun progetto attivo, inserisci nella lista di tasks solo quelli che non risultano ancora completati
          List<Task> tasks = snapshot.data?.where((task) => task.completato == false).toList() ?? [];
          //widget utile per impostare funzioni in reazioni a gesture dell'utente (es: onTap)
          return InkWell( 
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ViewProject(projectName: widget.progetto.nome)),
            ),
            //quanto segue è il container che ospita il progetto
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color:const Color.fromARGB(255, 243, 243, 243),
                borderRadius: BorderRadius.circular(8.0),     //per arrotondare i bordi
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              //all'interno del widget abbiamo una riga e un padding contenente 
              //a sua volta un widget creato ad hoc per visualizzare la lista di tasks del progetto
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    //nella riga (in cui abbiamo il titolo del progetto e la scadenza) i componenti vengono
                    //distanziati usando la proprietà spaceBetween sull'asse principale - vale a dire quello orizzontale
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          //inserendo il testo in un SingleChildScrollView si prevengono condizioni di overflow
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,   //il testo sarà scrollabile orizzontalmente
                            child: Text(
                              widget.progetto.nome,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: const Color(0Xff167485),
                              ),
                            ),
                          ),
                        ),
                      ),
                      //è stato usato un widget colonna in modo tale da visualizzare in alto
                      //l'icona del calendario e in basso la data della scadenza
                      Column(
                        children: [
                          const Icon(
                            Icons.calendar_month, 
                            size: 20,
                            color:Color(0XFF0E4C56),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.progetto.scadenza,
                            style: GoogleFonts.inter(fontSize: 13),
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

  //al click sul task viene chiamata la funzione del db per cambiare lo stato del task
  void _changeStateTask(Task task) {
    setState(() {  
      DatabaseHelper.instance.toggleStateTask(task);
    });
  }
}

//è il widget che si occupa della visualizzazione delle task non completate del progetto
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