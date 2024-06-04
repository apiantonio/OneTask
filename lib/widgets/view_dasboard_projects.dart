import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'project_dashboard_widget.dart';

/// Widget che visualizza la sezione della dashboard relativa ai progetti 
class ViewDasboardProjects extends StatefulWidget {
  const ViewDasboardProjects({super.key});

  @override
  State<ViewDasboardProjects> createState() => _ViewDasboardProjectsState();
}

class _ViewDasboardProjectsState extends State<ViewDasboardProjects> {
  //numero di progetti visualizzati di default
  int _numProgettiVisualizzati = 5;

  @override
  void initState() {
    super.initState();
    _loadNumPreference();
  }

  Future<void> _loadNumPreference() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _numProgettiVisualizzati = prefs.getInt('numProgetti') ?? 5;
    });
  } 

  Future<void> _updateNumPreference(int numProgetti) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('numProgetti', numProgetti);
    
    setState(() {
      _numProgettiVisualizzati = numProgetti;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Progetto>?>(
      future: DatabaseHelper.instance.getProgettiByState('attivo'), // i progetti attivi
      //future: DatabaseHelper.instance.getAllProgetti(),
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError){
          //print('Errore caricamento progetti dal db: ${snapshot.error}'); 
          return const Text('Errore caricamento progetti dal db');
        } else {  
          // team composti da più utenti
          List<Progetto> projects = snapshot.data ?? [];

          //si tratta del container che contiene tutti i progetti
          return Container(
            padding: const EdgeInsets.all(8.0),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 252, 187, 143),
              borderRadius: BorderRadius.circular(8.0),   //per far in modo che il container abbia i bordi arrotondati
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 5,    //quanto deve essere sfocato il bordo
                ),
              ],
            ),
            child: Column(
              children: [
                Row( 
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //nel widget padding abbiamo il testo 'Progetti attivi'
                    Padding(
                      //in questo modo setto un padding solo dal bordo sinistro
                      padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                      child: Text(
                        'Progetti attivi',
                        style: GoogleFonts.inter(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color:const Color.fromARGB(255, 28, 98, 103),
                        ),
                      ),
                    ),
                    //in questa riga invece abbiamo il valore corrispondente al numero di progetti
                    //visualizzati al momento e il menu a 3 pallini per cambiare la scelta
                    Row(
                      children: [
                        Text(
                          '$_numProgettiVisualizzati',
                          style: GoogleFonts.inter(
                            fontSize: 18, 
                            fontWeight: FontWeight.w700,
                            color:const Color.fromARGB(255, 28, 98, 103),
                          ),
                        ),
                        //questo popmenu button è costituito da 3 item per impostare quanti
                        //progetti visualizzare nella sezione apposita della
                        PopupMenuButton<int>(
                          color: const Color(0XFFE8E5E0),   //in questo modo posso cambiare il colore del menu a tendina
                          onSelected: (value) {
                            _updateNumPreference(value);
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 5,
                              child: Text(
                                'Mostra 5 progetti',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0XFF0E4C56),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 10,
                              child: Text(
                                'Mostra 10 progetti',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0XFF0E4C56),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            PopupMenuItem(
                              value: 20,
                              child: Text(
                                'Mostra 20 progetti',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0XFF0E4C56),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ), 
                //con il codice seguente abbiamo gestito la condizione in cui non ci siano progetti registrati nel db
                projects.isEmpty 
                  ? SizedBox( 
                    //nel caso in cui non ci siano progetti un messaggio di testo avvisa di ciò
                    height: 100,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Nessun progetto attivo presente al momento!',
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0Xff167485),
                            ),
                          ),
                        ),
                      )
                    )
                  //in caso contrario vengono visualizzati i progetti
                  : SizedBox(
                    height: 280,
                    child: ListView.builder( // se ci sono progetti mostra una lista orizzontale
                      scrollDirection: Axis.horizontal, // lista orizzontale dei progetti
                      shrinkWrap: true,     //il listView si ridimensiona in base al contenuto, evita problemi di layout
                      itemCount: projects.length < _numProgettiVisualizzati ? projects.length : _numProgettiVisualizzati, // se ci sono meno progetti di quelli selezionati da visualizzare allora renderizza solo quelli che ci sono
                      itemBuilder: (context, index) {
                        Progetto project = projects[index];
                        return Container(
                          width: 300, // Larghezza fissa per ogni elemento, regola secondo necessità
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(horizontal: 8.0), // Spazio tra gli elementi
                          child: ProjectDashboardWidget(progetto: project),
                        );
                      }
                    ),
                  )  
              ],
            ),
          );
        }
      }
    );
  }
}

