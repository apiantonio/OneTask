import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/new_team_form.dart';

/// Pagina per la creazione di un nuovo team
class NewTeam extends StatelessWidget {
  const NewTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: OTAppBar(title: 'NuovoTeam', withSearchbar: false),
        body: NewTeamForm(),
        backgroundColor:Color(0XFFE8E5E0),
    );
  }
}

