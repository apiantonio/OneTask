import 'package:OneTask/screens/statistiche.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:OneTask/screens/add_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/dashboard.dart';
import '../screens/projects_and_teams.dart';

/// Drawer dell'appbar dell'applicazioeìne attraverso cui è possibile navigare in altre pagine
class OTDrawer extends StatefulWidget {
  const OTDrawer({super.key});

  @override
  State<OTDrawer> createState() => _OTDrawerState();
}

class _OTDrawerState extends State<OTDrawer> {
  String _selectedTile = 'Home';   //variabile che uso per far cambiare il colore all'icona se siamo su quella pagina

  @override
  void initState() {
    super.initState();
    _initSelectedTile(); // inizialmente la sezione selezionata è la Home
  }

  // metodo per inizializzare la sezione del drawer
  Future<void> _initSelectedTile() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _selectedTile = prefs.getString('selectedTileDrawer') ?? 'Home';
    });
  }
  
  // metodo che aggiorna la shared preference quando cambia la sezione del drawer selezionata
  Future<void> _updateSelectedTile(String selectedTile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedTileDrawer', selectedTile);

    setState(() {
      _selectedTile = selectedTile;
    });
  }

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
            leading: Icon(Icons.home, color: (_selectedTile == 'Home') ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
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
              _updateSelectedTile('Home');
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const OTDashboard())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.group_work, color: (_selectedTile == 'Progetti e Team') ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Progetti e Team',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {
              _updateSelectedTile('Progetti e Team');
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ProjectTeam())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.bar_chart, color: (_selectedTile == 'Statistiche') ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Statistiche',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () {  
              _updateSelectedTile('Statistiche');
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const Statistiche())
              );
            },
          ),

          ListTile(
            leading: Icon(Icons.person_add, color: (_selectedTile == 'Nuovo Utente') ? const Color(0XFFEB701D) : const Color(0XFF0E4C56)),
            title: Text(
              'Nuovo Utente',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color(0XFF125F6C),   //del colore OX sono obbligatorie, FF indica l'opacità
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () { 
              _updateSelectedTile('Nuovo Utente');
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