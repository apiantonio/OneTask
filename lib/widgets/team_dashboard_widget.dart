import 'package:OneTask/model/utente.dart';
import 'package:OneTask/screens/view_team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';

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
          return const Center(child: Text('Errore nel caricamento info del team'));
        } else {
          InfoTeamDashboard info = snapshot.data!;
          
          return Card(
            child: ListTile(
              onTap: () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => ViewTeam(teamName: teamName))
              ),
              leading: Container(
                width: 50,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white, // Colore di sfondo
                  border: Border.all(
                    color: Colors.grey, // Colore del bordo
                    width: 1.0, // settare la larghezza del bordo
                  ),
                  borderRadius: BorderRadius.circular(30.0), //per arrotondare i bordi
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 20,),
                    Text(
                      info.count.toString(), 
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    )
                  ]
                ),
              ),
              title: Column(
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Manager: ${info.manager.nome} ${info.manager.cognome} (${info.manager.matricola})',
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