import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/team_dashboard_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    
          return Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Team',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                teams.isEmpty 
                  ? Padding(
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
