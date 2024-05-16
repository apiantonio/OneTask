import 'package:flutter/material.dart';
import 'package:OneTask/screens/add_user.dart';
import '../main.dart';

class OTDrawer extends StatefulWidget {
  OTDrawer({Key? key}) : super(key: key);

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
            leading: Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const OTDashboard())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.group_work),
            title: const Text('Progetti e Team'),
            onTap: () {
              //passa a quella pagina e poi
            },
          ),

          ListTile(
            leading: Icon(Icons.bar_chart),
            title: const Text('Statistiche'),
            onTap: () {  
              //passa a quella pagina e poi
            },
          ),

          ListTile(
            leading: Icon(Icons.person_add),
            title: const Text('Nuovo Utente'),
            onTap: () { 
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AddUser())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.calendar_today),
            title: const Text('Calendario'),
            onTap: () { 
              //passa a quella pagina e poi
            },
          ),       
        ],
      ),
    );
  }
}