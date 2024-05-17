import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';
import './view_team.dart';
import './modify_team.dart';
import '../widgets/team_item.dart';
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
          children: [
            Center(
              //inserire progetti dal db
              child: Text("Contenuti i miei progetti"),
            ),
            Center(
              //inserire team dal db
              child: const TeamView(),
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
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: FutureBuilder<List<Team>?>(
        future: listTeamFuture,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          else 
            if(snapshot.hasError){
              return Text('Errore caricamento team dal db');
            }else{
              //se non da problemi crea/restituisci la lista di teams
              List<Team> Teams = snapshot.data ?? [];
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                children: Teams.map((Team) =>
                  Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: TeamItem(
                      team: Team,
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
      MaterialPageRoute(builder: (context) => ViewTeam())
    );
  }

  void _onEditTeam(team){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ModifyTeam())
    );
  }
}