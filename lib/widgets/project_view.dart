import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/screens/modify_project.dart';
import 'package:OneTask/screens/new_project.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/project_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pagina visualizzabile al tocco sul tab dei progetti nella pagina Progetti e Teams
class ProjectView extends StatefulWidget {
  const ProjectView({super.key});

  @override
  ProjectViewState createState() {
    return ProjectViewState();
  }
}

class ProjectViewState extends State<ProjectView> {
  var listProjectFuture = DatabaseHelper.instance.getAllProgetti();

  @override 
  Widget build(BuildContext context){
    return Stack(
      children: [
        SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: 
          //utilizzo un FutureBuilder per accedere ai progetti memorizzati nel db
          FutureBuilder<List<Progetto>?>(
            future: listProjectFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if(snapshot.hasError) {
                return Text(
                  'Errore caricamento progetti dal db',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                    fontWeight: FontWeight.w500,
                  ),
                );
              } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                return Center(
                  child: Text(
                    'Nessun progetto presente al momento.\nCreane qualcuno per visualizzarli!',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0Xff167485),
                    ),
                  ),
                );
              }
              //se non da problemi crea/restituisci la lista di progetti
              List<Progetto> projects = snapshot.data!;
              //devo obbligatoriamente usare questo e non ListView altrimenti darebbe problemi con singleChildScrollView
              return ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  Progetto project = projects[index];   //salvo il valore corrente di team in una variabile Progetto
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    //per ciascun progetto della lista viene creato un apposito widget per gestirne la visualizzazione/modifica
                    child: ProjectItem(
                      project: project,
                      viewSingleProject: _onTapProject,
                      updateProject: _onEditProject,
                    ),
                  );
                }
              );
            }
          ),
        ),
        //questo widget contiene il floating button che riporta alla pagina per creare un nuovo team
        Padding(
          //il padding serve per far discostare il bottone dall'estremità inferiore
          padding: const EdgeInsets.only(right: 16, bottom: 16), 
          child: Align(
            //il bottone verrà posizionato in basso a destra
            alignment: Alignment.bottomRight,
            child: FloatingActionButton( 
                backgroundColor: const Color(0Xff167485),     
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewProject())
                  ).then((value) => setState(() {
                    //nel momento in cui ritorna dalla pagina di creazione di un nuovo progetto aggiorna la lista di progetti
                    //contenuti nel db per visualizzarne i nuovi
                    listProjectFuture = DatabaseHelper.instance.getAllProgetti();
                  }));
                },
                tooltip: 'Nuovo progetto',
                child: const Icon(
                  Icons.create_new_folder, 
                  size: 25,
                  color: Color(0XFFEFECE9),   //per cambiare colore all'icona
                ),
            ),
          ),
        ),
      ],
    );
  }

  void _onTapProject(project){
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => ViewProject(projectName: project.nome)
      ) 
    ).then((value) => setState(() {
      //nel momento in cui ritorna dalla pagina di visualizzazione di un progetto (visto che potresti cancellarlo) 
      //aggiorna la lista di progetti contenuti nel db 
      listProjectFuture = DatabaseHelper.instance.getAllProgetti();
    }));
  }

  void _onEditProject(project){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ModifyProject(projectName: project.nome,))
    ).then((value) => setState(() {
      //nel momento in cui ritorna dalla pagina di modifica di un progetto
      //aggiorna la lista di progetti contenuti nel db 
      listProjectFuture = DatabaseHelper.instance.getAllProgetti();
    }));
  }
}