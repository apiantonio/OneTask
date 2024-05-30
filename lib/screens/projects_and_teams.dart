import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/screens/new_project.dart';
import 'package:OneTask/screens/new_team.dart';
import 'package:flutter/material.dart';
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
          child: FutureBuilder<List<Team>?>(
            future: listTeamFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              else 
                if(snapshot.hasError){
                  return const Text('Errore caricamento team dal db');
                }else{
                  //se non da problemi crea/restituisci la lista di teams
                  List<Team> teams = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                    itemCount: teams.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                    Team team = teams[index];
                    return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
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
        Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: Align(
              alignment: Alignment.bottomRight, 
              child: FloatingActionButton(      
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewTeam())
                  ).then((value) => setState(() {
                    listTeamFuture = DatabaseHelper.instance.getAllTeams();
                  }));
                },
                tooltip: 'Nuovo team',
                child: const Icon(Icons.group, size: 20),
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
      listTeamFuture = DatabaseHelper.instance.getAllTeams();
    }));
  }

  void _onEditTeam(team){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ModifyTeam(teamName: team.nome,))
    ).then((value) => setState(() {
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
          FutureBuilder<List<Progetto>?>(
            future: listProjectFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              else 
                if(snapshot.hasError){
                  return const Text('Errore caricamento progetti dal db');
                }else{
                  //se non da problemi crea/restituisci la lista di teams
                  List<Progetto> projects = snapshot.data ?? [];
                  //devo obbligatoriamente usare questo e non ListView altrimenti darebbe problemi con singleChildScrollView
                  return ListView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      Progetto project = projects[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
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
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16), 
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(      
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewProject())
                  ).then((value) => setState(() {
                    listProjectFuture = DatabaseHelper.instance.getAllProgetti();
                  }));
                },
                tooltip: 'Nuovo progetto',
                child: const Icon(Icons.create_new_folder, size: 20),
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
      listProjectFuture = DatabaseHelper.instance.getAllProgetti();
    }));
  }

  void _onEditProject(project){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ModifyProject(projectName: project.nome,))
    ).then((value) => setState(() {
      listProjectFuture = DatabaseHelper.instance.getAllProgetti();
    }));
  }
}