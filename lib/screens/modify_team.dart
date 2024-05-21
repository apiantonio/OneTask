import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../model/team.dart';

/*da completare FRANCESCO RAGO, solo prova per vedere utilizzo della navigazione*/
class ModifyTeam extends StatelessWidget {
  const ModifyTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Modifica team'),
      body: const Text('Modifica team'),
    );
  }
}
