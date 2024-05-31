import 'package:OneTask/screens/statistiche.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:OneTask/screens/add_user.dart';
import '../screens/projects_and_teams.dart';
import '../main.dart';

class OTDrawer extends StatefulWidget {
  const OTDrawer({super.key});

  @override
  State<OTDrawer> createState() => _OTDrawerState();
}

class _OTDrawerState extends State<OTDrawer> {
  int isSelected = 0;   //variabile che uso per far cambiare il colore all'icona se siamo su quella pagina

  @override
  Widget build(BuildContext context){
    return Drawer(
      backgroundColor: const Color(0XFFCFCCC3),   //colore di sfondo del drawer
      child: ListView(
        //rimuovere il padding da questa ListView
        padding: EdgeInsets.zero,
        children: [
          //il drawer header è la sezione in alto del drawer
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0Xff167485),
            ),
            child: Text(
              'OneTask menu', 
              style:GoogleFonts.inter(
                fontSize: 25, 
                fontWeight: FontWeight.bold,    //per lo spessore del testo
                color: const Color(0XFFEFECE9),   //del colore OX sono obbligatorie, FF indica l'opacità
              ),
            ),
          ),
          
          //ciascun listTile contiene le voci che sono presenti nel menu ad hamburger
          ListTile(
            leading: Icon(Icons.home, color: (isSelected == 0) ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Home', 
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            //al click sulla sezione di interesse ti porta alla pagina relativa
            onTap: () {
              setState(() {
                isSelected = 0;
              });
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const OTDashboard())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.group_work, color: (isSelected == 1) ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Progetti e Team',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              setState(() {
                isSelected = 1;
              });
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProjectTeam())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.bar_chart, color: (isSelected == 2) ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Statistiche',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {  
              setState(() {
                isSelected = 2;
              });
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const Statistiche())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.person_add, color: (isSelected == 3) ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Nuovo Utente',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () { 
              setState(() {
                isSelected = 3;
              });
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => AddUser())
              );
            },
          ),      
        ],
      ),
    );
  }
}