import 'package:OneTask/model/team.dart';
import 'package:flutter/material.dart';
import '../model/utente.dart';
import '../services/database_helper.dart';

class TeamItem extends StatelessWidget {
  final Team team;  
  final viewSingleTeam;
  final updateTeam;
  const TeamItem({super.key, required this.team, required this.viewSingleTeam, required this.updateTeam});

  @override
  Widget build(BuildContext context){
    var manager = DatabaseHelper.instance.getTeamManager(team);

    return ListTile(    //una sola riga della lista
        onTap: () {viewSingleTeam(team);},   //azione quando premi sul team
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.blue.shade50,  //sfondo della riga
        //container in alto a sx che mostra quante persone ci sono nel team
        leading: MemberCounter(nomeTeam: team.nome,),
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

class MemberCounter extends StatelessWidget{
  final String nomeTeam;
  const MemberCounter({super.key, required this.nomeTeam});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white, // Colore di sfondo
        border: Border.all(
          color: Colors.grey, // Colore del bordo
          width: 1.0, // settare la larghezza del bordo
      ),
        borderRadius: BorderRadius.circular(10.0), //per arrotondare i bordi
      ),
      child: Row(
        children: [
          const Icon(Icons.person),
          FutureBuilder<int?>(
              future: DatabaseHelper.instance.countUtentiTeam(nomeTeam),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                else 
                  if(snapshot.hasError){
                    return const Text('Errore caricamento team dal db');
                  }else{
                    //se non da problemi crea/restituisci numUtenti
                    int count = snapshot.data ?? 0;
                    return Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    );
                  }
              }
          ),
        ],
      ),
    );
  }
  
}