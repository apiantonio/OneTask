import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/drawer.dart';
import '../widgets/project_view.dart';
import '../widgets/team_view.dart';

/// Pagina per visualizzare e modificare progetti e teams
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
        appBar: OTAppBar(title: 'Progetti e team', withTabbar: true, tabController: _tabController, sourcePage: 'Progetti e teams'),
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

