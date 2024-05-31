import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/screens/new_project.dart';
import 'package:OneTask/screens/new_team.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';
import './view_team.dart';
import './modify_team.dart';
import './view_project.dart';
import './modify_project.dart';
import '../widgets/team_item.dart';
import '../widgets/project_item.dart';
import '../services/database_helper.dart';
import '../model/team.dart';

class ProjectTeam extends StatefulWidget {
  const ProjectTeam({super.key});

  @override
  ProjectTeamState createState() => ProjectTeamState();
}

class ProjectTeamState extends State<ProjectTeam> with TickerProviderStateMixin{
  //late dice che tabController sarà inizializzata in seguito
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0XFFE8E5E0),
        appBar: OTAppBar(title: 'Progetti e team', tabbar: true, controller: _tabController),
        drawer: const OTDrawer(),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ProjectView(),
            TeamView(),
          ],
        ),
    );
  }
}

class TeamView extends StatefulWidget{
  const TeamView({super.key});

  @override
  TeamViewState createState() {
    return TeamViewState();
  }
}

class TeamViewState extends State<TeamView> {
  var listTeamFuture = DatabaseHelper.instance.getAllTeams();

  @override 
  Widget build(BuildContext context){
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          //utilizzo un FutureBuilder per accedere ai team memorizzati nel db
          child: FutureBuilder<List<Team>?>(
            future: listTeamFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              else 
                if(snapshot.hasError){
                  return Text(
                    'Errore caricamento team dal db',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }else{
                  //se non da problemi crea/restituisci la lista di teams
                  List<Team> teams = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                    itemCount: teams.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                    Team team = teams[index]; //salvo il valore corrente di team in una variabile Team
                    return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        //per ciascun team della lista viene creato un apposito widget per gestirne la visualizzazione/modifica
                        child: TeamItem(
                          team: team,
                          viewSingleTeam: _onTapTeam,
                          updateTeam: _onEditTeam,
                        ),
                      );
                    }
                  );
                }
              }
          ),
        ),
        //questo widget contiene il floating button che riporta alla pagina per creare un nuovo team
        Padding(
          //il padding mi serve per far discostare il bottone dall'estremità inferiore
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: Align(
              //l'allineamento sarà in basso a destra
              alignment: Alignment.bottomRight, 
              child: FloatingActionButton(   
                backgroundColor: const Color(0XFF0E4C56),   
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewTeam())
                  ).then((value) => setState(() {
                    //nel momento in cui ritorna dalla pagina di creazione di un nuovo team aggiorna la lista di team
                    //contenuti nel db per visualizzarne i nuovi
                    listTeamFuture = DatabaseHelper.instance.getAllTeams();
                  }));
                },
                tooltip: 'Nuovo team',
                child: const Icon(
                  Icons.group, 
                  size: 25,
                  color: Color(0XFFEFECE9),   //per cambiare colore all'icona
                ),
              ),
            ),
          ),
      ]
    );
  }

  void _onTapTeam(team){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewTeam(teamName: team.nome)
      )
    ).then((value) => setState(() {
      //nel momento in cui ritorna dalla pagina di visualizzazione di un team (visto che potresti cancellarlo) 
      //aggiorna la lista di team contenuti nel db 
      listTeamFuture = DatabaseHelper.instance.getAllTeams();
    }));
  }

  void _onEditTeam(team){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ModifyTeam(teamName: team.nome,))
    ).then((value) => setState(() {
      //nel momento in cui ritorna dalla pagina di modifica di un team 
      //aggiorna la lista di team contenuti nel db 
      listTeamFuture = DatabaseHelper.instance.getAllTeams();
    }));
  }
}

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
              }
              else 
                if(snapshot.hasError){
                  return Text(
                    'Errore caricamento progetti dal db',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }else{
                  //se non da problemi crea/restituisci la lista di progetti
                  List<Progetto> projects = snapshot.data ?? [];
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