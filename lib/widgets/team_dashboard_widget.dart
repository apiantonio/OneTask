import 'package:OneTask/model/utente.dart';
import 'package:OneTask/screens/view_team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// utilità
class InfoTeamDashboard {
  Utente manager;
  int count;

  InfoTeamDashboard({
    required this.manager,
    required this.count,
  });
}

// visualizza i team nelal dashboard
class TeamDashboardWidget extends StatelessWidget {
  final String teamName;
  const TeamDashboardWidget({super.key, required this.teamName});

  @override
  Widget build(BuildContext context){
    return FutureBuilder<InfoTeamDashboard>(
      future: _dettagliTeam(teamName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(
            'Errore nel caricamento info del team',
            style: GoogleFonts.inter(
              fontSize: 18,
            )
          ));
        } else {
          InfoTeamDashboard info = snapshot.data!;
          
          return Card(
            color:const Color.fromARGB(255, 243, 243, 243), // Colore di sfondo,
            child: ListTile(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => ViewTeam(teamName: teamName))
              ),
              //come leading abbiamo il container che incapsula una riga con dentro
              //l'icona della persona e il numero di componenti del team
              leading: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0XFFDDD7D1), // Colore di sfondo
                  border: Border.all(
                    color:const Color(0Xff167485), // Colore del bordo
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
                    Text(
                      info.count.toString(), 
                      style: GoogleFonts.inter(
                        fontSize: 13,
                      ),
                    )
                  ]
                ),
              ),
              //come title del listTile invece abbiamo un widget Column che contiene 
              //nella parte alta il nome del team, in basso la matricola dell'utente manager
              title: Column(
                children: [
                  Text(
                    teamName,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: const Color(0XFF0E4C56),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Manager: ${info.manager.matricola}',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                    )
                  )
                ]
              ),
            ),
          );
        }
      }
    );
  }

  Future<InfoTeamDashboard> _dettagliTeam(String teamName) async {
    final db = DatabaseHelper.instance;
    final manager = await db.getTeamManager(teamName);
    final numUsers = await db.countUtentiTeam(teamName);

    return InfoTeamDashboard(manager: manager!, count: numUsers);
  }

}