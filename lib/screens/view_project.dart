import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../model/progetto.dart';

/*da completare MARCO MANCINO, solo prova per vedere utilizzo della navigazione*/
class ViewProject extends StatelessWidget {
  const ViewProject({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: OTAppBar(title: 'Visualizza progetto'),
      body: Text('Vedi progetto'),
    );
  }
}