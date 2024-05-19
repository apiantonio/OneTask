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
        drawer: OTDrawer(),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ProjectView(),
            TeamView(),
          ],
        ),
        // Floating Buttons in basso a destra
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Builder(
              builder: (context) => FloatingActionButton.small(
                
                heroTag: 'unique_tag_2',
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewTeam())
                  );
                },
                tooltip: 'Nuovo team',
                child: const Icon(Icons.group, size: 20),
              )
            ),
            const SizedBox(
              height: 10,
            ),
            Builder(
              builder: (context) => FloatingActionButton(
                /*questo herotag serve perchè abbiamo due floating nello stesso subtree e senza genera eccezione*/
                heroTag: 'unique_tag_1',
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewProject())
                  );
                },
                tooltip: 'Nuovo progetto',
                child: const Icon(Icons.create_new_folder),
              ),
            ),
            
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
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: teams.map((team) =>
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: TeamItem(
                      team: team,
                      viewSingleTeam: _onTapTeam,
                      updateTeam: _onEditTeam,
                    ),
                  ),
                ).toList(),
              );
            }
        }
      ),
    );
  }

  void _onTapTeam(team){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ViewTeam())
    );
  }

  void _onEditTeam(team){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ModifyTeam())
    );
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
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: FutureBuilder<List<Progetto>?>(
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
              return ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: projects.map((project) =>
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: ProjectItem(
                      project: project,
                      viewSingleProject: _onTapProject,
                      updateProject: _onEditProject,
                    ),
                  ),
                ).toList(),
              );
            }
        }
      ),
    );
  }

  void _onTapProject(project){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ViewProject())
    );
  }

  void _onEditProject(project){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => const ModifyProject())
    );
  }
}