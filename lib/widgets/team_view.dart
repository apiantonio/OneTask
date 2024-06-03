import 'package:OneTask/model/team.dart';
import 'package:OneTask/screens/modify_team.dart';
import 'package:OneTask/screens/new_team.dart';
import 'package:OneTask/screens/view_team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/team_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pagina visualizzabile al tocco sul tab dei progetti nella pagina Progetti e Teams
class TeamView extends StatefulWidget{
  const TeamView({super.key});

  @override
  TeamViewState createState() {
    return TeamViewState();
  }
}

class TeamViewState extends State<TeamView> {
  var listTeamFuture = DatabaseHelper.instance.getAllTeams();

  @override 
  Widget build(BuildContext context){
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          //utilizzo un FutureBuilder per accedere ai team memorizzati nel db
          child: FutureBuilder<List<Team>?>(
            future: listTeamFuture,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              else 
                if(snapshot.hasError){
                  return Text(
                    'Errore caricamento team dal db',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }else{
                  //se non da problemi crea/restituisci la lista di teams
                  List<Team> teams = snapshot.data ?? [];
                  return ListView.builder(
                    shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                    itemCount: teams.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                    Team team = teams[index]; //salvo il valore corrente di team in una variabile Team
                    return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        //per ciascun team della lista viene creato un apposito widget per gestirne la visualizzazione/modifica
                        child: TeamItem(
                          team: team,
                          viewSingleTeam: _onTapTeam,
                          updateTeam: _onEditTeam,
                        ),
                      );
                    }
                  );
                }
              }
          ),
        ),
        //questo widget contiene il floating button che riporta alla pagina per creare un nuovo team
        Padding(
          //il padding mi serve per far discostare il bottone dall'estremità inferiore
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: Align(
              //l'allineamento sarà in basso a destra
              alignment: Alignment.bottomRight, 
              child: FloatingActionButton(   
                backgroundColor: const Color(0XFF0E4C56),   
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewTeam())
                  ).then((value) => setState(() {
                    //nel momento in cui ritorna dalla pagina di creazione di un nuovo team aggiorna la lista di team
                    //contenuti nel db per visualizzarne i nuovi
                    listTeamFuture = DatabaseHelper.instance.getAllTeams();
                  }));
                },
                tooltip: 'Nuovo team',
                child: const Icon(
                  Icons.group, 
                  size: 25,
                  color: Color(0XFFEFECE9),   //per cambiare colore all'icona
                ),
              ),
            ),
          ),
      ]
    );
  }

  void _onTapTeam(team){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewTeam(teamName: team.nome)
      )
    ).then((value) => setState(() {
      //nel momento in cui ritorna dalla pagina di visualizzazione di un team (visto che potresti cancellarlo) 
      //aggiorna la lista di team contenuti nel db 
      listTeamFuture = DatabaseHelper.instance.getAllTeams();
    }));
  }

  void _onEditTeam(team){
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => ModifyTeam(teamName: team.nome,))
    ).then((value) => setState(() {
      //nel momento in cui ritorna dalla pagina di modifica di un team 
      //aggiorna la lista di team contenuti nel db 
      listTeamFuture = DatabaseHelper.instance.getAllTeams();
    }));
  }
}
