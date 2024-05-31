import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/team_dashboard_widget.dart';
import 'package:flutter/material.dart';

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
          return const Text('Errore caricamento team dal db');
        } else {  
          // team composti da più utenti
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
    );
  }
}
