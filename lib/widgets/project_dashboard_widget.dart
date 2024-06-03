import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dashboard_tasks.dart';

/// Widget che rappresenta un singolo progetto nella dashboard
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

