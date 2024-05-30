import 'package:OneTask/screens/statistiche.dart';
import 'package:flutter/material.dart';
import 'package:OneTask/screens/add_user.dart';
import '../screens/projects_and_teams.dart';
import '../screens/calendar.dart';
import '../main.dart';

class OTDrawer extends StatefulWidget {
  const OTDrawer({Key? key}) : super(key: key);

  @override
  State<OTDrawer> createState() => _OTDrawerState();
}

class _OTDrawerState extends State<OTDrawer> {
  @override
  Widget build(BuildContext context){
    return Drawer(
      child: ListView(
        //rimuovere il padding da questa ListView
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('OneTask menu'),
          ),
          
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const OTDashboard())
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.group_work),
            title: const Text('Progetti e Team'),
            onTap: () {
              //passa a quella pagina e poi
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProjectTeam())
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistiche'),
            onTap: () {  
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const Statistiche())
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Nuovo Utente'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AddUser())
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Calendario'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const OTCalendar())
              );
            },
          ),       
        ],
      ),
    );
  }
}