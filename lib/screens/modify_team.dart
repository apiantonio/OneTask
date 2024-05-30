import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../model/team.dart';

/*da completare FRANCESCO RAGO, solo prova per vedere utilizzo della navigazione*/
class ModifyTeam extends StatelessWidget {
  final String teamName;
  const ModifyTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: OTAppBar(title: 'Modifica team'),
      body: const Text('Modifica team'),
    );
  }
}