import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../model/team.dart';

/*da completare FRANCESCO RAGO, solo prova per vedere utilizzo della navigazione*/
class ModifyTeam extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: OTAppBar(title: 'Modifica progetto'),
      body: Text('Modifica team'),
    );
  }
}