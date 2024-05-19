import 'package:OneTask/model/team.dart';
import 'package:flutter/material.dart';
import '../model/utente.dart';
import '../services/database_helper.dart';

class TeamItem extends StatelessWidget {
  final Team team;  
  final viewSingleTeam;
  final updateTeam;
  const TeamItem({Key? key, required this.team, required this.viewSingleTeam, required this.updateTeam});

  @override
  Widget build(BuildContext context) {
    var manager = DatabaseHelper.instance.getTeamManager(team);

    return ListTile(    //una sola riga della lista
        onTap: () {viewSingleTeam(team);},   //azione quando premi sul team
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.blue.shade50,  //sfondo della riga
        title: Column(
          children: [
            Text(
              team.nome,
              softWrap: true,   //se non c'è abbastanza spazio manda a capo
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            FutureBuilder<Utente?>(
              future: manager,
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                else 
                  if(snapshot.hasError){
                    return const Text('Errore caricamento team dal db');
                  }else{
                    //se non da problemi crea/restituisci l'utente
                    Utente? manager = snapshot.data;
                    return Text(
                      'Responsabile: ${manager !=null ? manager.nome + manager.cognome : 'Nessuno'}',
                    );
                  }
              }
            ),
          ]
        ),
        
        trailing: IconButton(   //icona a destra
          iconSize: 16,
          icon: const Icon(Icons.edit),
          color: Colors.black,
          onPressed: () {updateTeam(team);},   //cosa fare quando premi sul bottone a destra
        )
    );
  }
}