import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
//import '../services/database_helper.dart';
import '../widgets/drawer.dart';

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
              child: Text("Contenuto i miei team"),
            ),
          ],
        ),
    );
  }
}
