import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/delete_team_action_button.dart';
import '../widgets/team_details.dart';

/// Pagina per la visualizzazione di un team
class ViewTeam extends StatelessWidget {
  final String teamName;

  const ViewTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Visualizza Team', withSearchbar: false),
      body: TeamDetails(teamName: teamName),
      backgroundColor: const Color(0XFFE8E5E0),
      floatingActionButton: DeleteTeamActionButton(teamName: teamName),
    );
  }
}
