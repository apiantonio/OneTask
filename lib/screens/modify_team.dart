import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/edit_team_form.dart';

/// Pagina per la modifica di un team
class ModifyTeam extends StatelessWidget {
  final String teamName;
  const ModifyTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFE8E5E0),
      appBar: const OTAppBar(title: 'Modifica team', withSearchbar: false),
      body: EditTeamForm(teamName: teamName),
    );
  }
}
