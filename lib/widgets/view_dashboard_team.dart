import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/team_dashboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//rappresenta la sezione della dashboard che ti permette di visualizzare i team
class ViewDashboardTeam extends StatelessWidget {
  const ViewDashboardTeam({super.key,});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder <List<String>?>(
      future: DatabaseHelper.instance.getTeamPiuGrandi(3), // i nomi dei tre team più grandi
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError){
          return Text(
            'Errore caricamento team dal db',
            style: GoogleFonts.inter(
              fontSize: 16,
            ),
          );
        } else {  
          // team composti da più utenti
          List<String> teams = snapshot.data ?? [];
          //rappresenta il container che circonda i 3 team più grandi
          return Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 166, 200, 206),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                ),
              ],
            ),
            //in un widget Column vengono visualizzati il testo e i primi 3 team per dimensione
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Team',
                    style: GoogleFonts.inter(
                      fontSize: 24, 
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: const Color.fromARGB(255, 242, 113, 27),
                    ),
                  ),
                ),
                //con questa condizione vengono visualizzati widget diversi a seconda che ci siano o meno
                //team memorizzati nel db
                teams.isEmpty 
                  ? Padding(
                    //se non ci sono team, segnaliamo la mancanza all'utente con un blocco di testo
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                        'Nessun team presente al momento!',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0XFFEB701D),
                        ),
                      ),
                  )
                  //altrimenti in un listViewBuilder sono visualizzati i 3 team
                  : ListView.builder(
                    shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                    itemCount: teams.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      String team = teams[index];
                      return TeamDashboardWidget(teamName: team);
                    }
                  ),
              ]
            ),
          );
        }
      }
    );
  }
}
