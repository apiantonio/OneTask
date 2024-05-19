import 'package:OneTask/model/progetto.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

//enumerazione per selezionare lo stato dei progetti, mi serve per filtrarli nella vista di tutti i progetti
enum Stato{ attivo, sospeso, archiviato}

//si tratta del widget che mi serve a filtrare i progetti
class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  //in questo modo per prima cosa indichiamo quali progetti di default possiamo vedere
  //di default solo quelli attivi
  Set<Stato> selection = <Stato>{Stato.attivo};

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Stato>(
      segments: const <ButtonSegment<Stato>>[
        ButtonSegment<Stato>(value: Stato.attivo, label: Text('Attivo'), icon: Icon(Icons.visibility)),
        ButtonSegment<Stato>(value: Stato.sospeso, label: Text('Sospeso'), icon: Icon(Icons.visibility_off)),
        ButtonSegment<Stato>(value: Stato.archiviato, label: Text('Archiviato'), icon: Icon(Icons.archive)),
      ],
      selected: selection,
      onSelectionChanged: (Set<Stato> newSelection) {
        setState(() {
          selection = newSelection;
        });
      },
      multiSelectionEnabled: true,
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const MultipleChoice(),

          const SizedBox(
            height: 20,
          ),

          Expanded(
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
          ),
        ]
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