import 'package:OneTask/model/team.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/utente.dart';
import '../services/database_helper.dart';

class TeamItem extends StatelessWidget {
  final Team team;  
  final Function(Team) viewSingleTeam;
  final Function(Team) updateTeam;
  
  const TeamItem({
    super.key, 
    required this.team, 
    required this.viewSingleTeam, 
    required this.updateTeam
  });

  @override
  Widget build(BuildContext context){
    return ListTile(    //una sola riga della lista
        onTap: () {viewSingleTeam(team);},   //azione quando premi sul team
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: const Color(0XFFEFECE9),  //sfondo della riga
        //container in alto a sx che mostra quante persone ci sono nel team
        leading: MemberCounter(nomeTeam: team.nome,),
        title: Column(
          children: [
            Text(
              team.nome,
              softWrap: true,   //se non c'è abbastanza spazio manda a capo
              style: GoogleFonts.inter(
                fontSize: 23,
                color: const Color(0XFF0E4C56),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.bold,
              ),
            ),
            //uso un future builder per poter ottenere il manager di ciascun Team
            FutureBuilder<Utente?>(
              future: DatabaseHelper.instance.getTeamManager(team.nome),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                else 
                  if(snapshot.hasError){
                    return const Text('Errore caricamento infoTeam dal db');
                  }else{
                    //se non da problemi crea/restituisci l'utente
                    Utente? manager = snapshot.data;
                    return Text(
                      'Manager: ${manager !=null ? manager.matricola : 'Nessuno'}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                      ),
                    );
                  }
              }
            ),
          ]
        ),

        trailing: IconButton(   //icona a destra
          iconSize: 20,
          icon: const Icon(Icons.edit),
          color: const Color(0XFFEB701D),
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
        color: const Color(0XFFDDD7D1), // Colore di sfondo
        border: Border.all(
          color: const Color(0Xff167485), // Colore del bordo
          width: 1.0, // settare la larghezza del bordo
        ),
        borderRadius: BorderRadius.circular(30.0), //per arrotondare i bordi
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.person, 
            size: 20,
            color: Color(0Xff167485),
          ),
          //utilizzando questo future builder posso ricavare dal db il numero di utenti contenuto in ciascun team
          FutureBuilder<int>(
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
                    int count = snapshot.data!;
                    return Text(
                      count.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 13,
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