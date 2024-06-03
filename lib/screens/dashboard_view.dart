import 'package:flutter/material.dart';
import '../widgets/view_dasboard_projects.dart';
import '../widgets/view_dashboard_team.dart';

/// Corpo della dashboard dell'applicazione
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    //la paggina è contenuta interamente in un componente scrollabile
    return const SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        //è possibile immaginare la schermata in sottosezioni: una sezione relativa ai progetti, un sizedbox, 
        //ed una relativa ai team
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
          children: [
            ViewDasboardProjects(),
            SizedBox(height: 20), // Spazio tra le sezioni
            ViewDashboardTeam(),
          ]
        ),
      ),
    );
  }
}
 
