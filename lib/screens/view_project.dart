import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/tasks_list.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/appbar.dart';

/// Widget che rappresenta la visualizzazione di un progetto
class ViewProject extends StatelessWidget {
  final String projectName;

  const ViewProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Visualizza Progetto', withSearchbar: false),
      body: ProjectDetails(projectName: projectName),
      backgroundColor: const Color(0XFFE8E5E0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 217, 122, 54),
        child: const Icon(
          Icons.delete,
          color: Color(0XFFE8E5E0),
        ),
        onPressed: () async {
          bool? confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Conferma Eliminazione',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    color: const Color(0XFF0E4C56),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Sei sicuro di voler eliminare questo progetto?',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                  )                  
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'Annulla', 
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0Xff167485),
                        fontWeight: FontWeight.w600,
                      )  
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Elimina',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0XFFEB701D),
                        fontWeight: FontWeight.w600,
                      )  
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (confirmDelete == true) {
            Progetto? progetto = await DatabaseHelper.instance.selectProgettoByNome(projectName);
            if (progetto != null) {
              await DatabaseHelper.instance.deleteProgetto(progetto.nome);
              Navigator.of(context).pop(); // Torna alla schermata precedente
            }
          }
        },
      ),
    );
  }
}

class ProjectDetails extends StatelessWidget {
  final String projectName;

  const ProjectDetails({super.key, required this.projectName});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      //tramite questo future builder posso estrarre tutte le info che mi servono del progetto
      //(compresi i task associati)
      child: FutureBuilder<ProjectElements>(
        future: _fetchProjectDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Errore caricamento infoProgetto dal db');
          } else {
            //se sono arrivata qui sono sicuro che mi restituisca qualcosa
            ProjectElements dataProj = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dataProj.progetto.nome,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    color: const Color(0XFF0E4C56),   //del colore OX sono obbligatorie, FF indica l'opacità
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Stato: ',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: const Color(0XFFEB701D),
                      ),
                    ),
                  //per i progetti archiviati voglio mi dica con esattezza se sono completati
                  (dataProj.progetto.stato == 'archiviato' && dataProj.progetto.completato == true) 
                    ? Text(
                        'archiviato - completato',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                        ),
                      )
                    //se invece non sono archiviati stampa solo lo stato
                    : (dataProj.progetto.stato != 'archiviato') 
                      ? Text(
                          dataProj.progetto.stato,
                          style: GoogleFonts.inter(
                            fontSize: 17,
                          ),
                        )
                      //oppure se sono falliti (e dunque la motivazione del fallimento è necessaria)
                      //in questo caso voglio venga restituita anche la motivazione oltre che lo stato
                      : Text(
                          'archiviato - fallito',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                          ),
                        ),        
                  ]
                ),
                //se il progetto è archiviato e fallito permetto la visualizzazione della motivazione del fallimento
                (dataProj.progetto.stato == 'archiviato' && dataProj.progetto.motivazioneFallimento != null) ?
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Causa fallimento: ',
                          style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: const Color(0XFFEB701D),
                          ),
                        ),
                        Text(
                          '${dataProj.progetto.motivazioneFallimento}',
                          style: GoogleFonts.inter(
                            fontSize: 17,
                          ),
                        ),
                      ]
                    ),
                    const SizedBox(height: 16),
                  ],
                ) :
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Scadenza: ',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: const Color(0XFFEB701D),
                      ),
                    ),
                    Text(
                      dataProj.progetto.scadenza,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 16),
                //questo widget mi serve per far in modo che i suoi figli vadano a capo in caso
                //di mancanza di spazio risolvendo ipotetici causi di overflow dovuti da
                //un'eccessiva lunghezza del campo della descrizione del progetto
                Wrap(
                  children: [
                    Text(
                        'Descrizione progetto: ',
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: const Color(0XFFEB701D),
                        ),
                      ),
                      Text(
                        '${dataProj.progetto.descrizione}',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                        ),
                      ),
                  ]
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Team: ',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: const Color(0XFFEB701D),
                      ),
                    ),
                    Text(
                      dataProj.progetto.team,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                      ),
                    ),
                  ]
                ),
                const SizedBox(height: 16),
                Text(
                  'I tuoi tasks',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    color: const Color(0Xff167485),   //del colore OX sono obbligatorie, FF indica l'opacità
                    fontWeight: FontWeight.bold,
                  ),     
                ),
                //poichè un progetto potrebbe non avere al momento task associati 
                //questo comportamento è stato necessario gestirlo
                dataProj.tasks.isEmpty 
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10), 
                      child: Text(
                        'Non ci sono tasks associati al progetto', 
                        style: GoogleFonts.inter(
                          fontSize: 17, 
                          color: const Color(0XFF0E4C56),
                        )
                      )
                    )
                  : TasksList(tasks: dataProj.tasks),
              ],
            );
          }
        },
      ),
    );
  }

  //questo metodo asincrono è utile per ottenere rapidamente tutte le info sul progetto:
  //info di carattere generale e quali sono i task associati
  Future<ProjectElements> _fetchProjectDetails() async{
    final db = DatabaseHelper.instance;
    final progetto = await db.selectProgettoByNome(projectName);
    final tasksProg = await db.getTasksByProject(projectName);
    if(progetto == null) {
      //è una condizione che non dovrebbe (come regola) mai accadere. Io se clicco su un progetto
      //dalla schermata progetti e team significa che quantomeno deve esistere - non vale lo stesso per i tasks
      throw Exception("Errore visualizzazione progetto: il progetto non esiste");
    } else {
      return ProjectElements(progetto: progetto, tasks: tasksProg);
    }
  }
}

//classe di utilità utilizzata per salvare sia i dettagli relativi al progetto che i task associati
//post estrazione dal db
class ProjectElements {
  final Progetto progetto;
  final List<Task> tasks;

  ProjectElements({required this.progetto, required this.tasks});
}

