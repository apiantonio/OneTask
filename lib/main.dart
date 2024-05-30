import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/floating_buttons_dashboard.dart';
import 'package:flutter/material.dart';
import './widgets/appbar.dart';
import './widgets/drawer.dart';
import './model/utente.dart';

void main() async {
  runApp(const OTDashboard());
  await DatabaseHelper.instance.populateDatabase();
}

class OTDashboard extends StatelessWidget {
  const OTDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Dashboard';

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner:
          false, //così non si vede la striscia in alto a dx di debug
      home: Scaffold(
        appBar: const OTAppBar(),
        drawer: OTDrawer(),
        body: const DashboardView(),
        floatingActionButton: const FloatingActionButtonsDashboard(), // pulsanti floating per nuovo team e nuovo progetto
      ),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
          children: [
            FutureBuilder <List<String>?>(
              future: DatabaseHelper.instance.getTeamPiuGrandi(), 
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                else 
                  if(snapshot.hasError){
                    return const Text('Errore caricamento team dal db');
                  }else{
                    List<String> teams = snapshot.data ?? [];
                    if(teams.isEmpty) {
                      return const Center(child: Text('Nessun team presente al momento'));
                    }else{
                      return ListView.builder(
                        shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                        itemCount: teams.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          String team = teams[index];
                          return TeamDashboardWidget(teamName: team);
                        }
                      );
                    }
                  }
              }
            )

          ]
        ),
      ),
    );
  }
  
}

class InfoTeamDashboard {
  Utente manager;
  int count;

  InfoTeamDashboard({
    required this.manager,
    required this.count,
  });
}

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
          return const Center(
              child: Text('Errore nel caricamento info del team'));
          }else{
            InfoTeamDashboard info = snapshot.data!;
            return ListTile(
              leading:Container(
                width: 60,
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
                    'Manager: ${info.manager}',
                  )
                ]
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

    return InfoTeamDashboard(manager: manager, count: numUsers);
  }

}