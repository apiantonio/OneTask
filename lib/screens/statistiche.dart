import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/appbar.dart';
import 'package:OneTask/widgets/drawer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/indicator.dart';

/// Classe che rappresenta la pagina di statistiche
class Statistiche extends StatefulWidget {
  const Statistiche({super.key});

  @override
  StatisticheState createState() => StatisticheState();
}

class StatisticheState extends State<Statistiche> {
  late Future<List<Progetto>> progetti; // lista dei progetti presenti nel DB
  late Future<int> numCompletati;
  late Future<int> numFalliti;

  @override
  void initState() {
    super.initState();
    progetti = DatabaseHelper.instance.getAllProgetti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(),
      drawer: const OTDrawer(),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Progetto>>( // il future builder si baserà sui progetti 
          future: progetti,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Errore nel caricamento dei dati'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Nessun progetto disponibile'));
            }

            List<Progetto> progetti = snapshot.data!;

            return Padding( 
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Statistiche progetti',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      color: const Color(0XFF0E4C56),   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      // Expanded con dentro Align con dentro AspectRatio sono necessari per posizionare correttamente il PieChart
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: AspectRatio(
                            aspectRatio: 1.5, 
                            child: PieChart(
                              PieChartData(
                                // spazio al centro
                                centerSpaceRadius: 20,
                                sections: _sezioni(progetti),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // colonna contente la legenda del grafico
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Indicator(color: Colors.green,text: 'Attivi'),
                          SizedBox(
                            height: 4,
                          ),
                          Indicator(color: Colors.orange,text: 'Sospesi'),
                          SizedBox(
                            height: 4,
                          ),
                          Indicator(color: Colors.red,text: 'Archiviati'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  FutureBuilder<DatiStatistiche>(
                    future: _fetchDatiStatistiche(), 
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Errore nel caricamento dei dettagli progetti'));
                      } else {
                        final datiStat = snapshot.data!;
                        final percComp = (datiStat.completati/datiStat.totale)*100;
                        final percFall = (datiStat.falliti/datiStat.totale)*100;
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progetti completati:',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: const Color(0XFF0E4C56),   //del colore OX sono obbligatorie, FF indica l'opacità
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$percComp%',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 15,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progetti falliti:',
                                  softWrap: true,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    color: const Color(0XFF0E4C56),   //del colore OX sono obbligatorie, FF indica l'opacità
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$percFall%',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ],
                        );
                      }
                    }
                  )
                ]
              ),
            );
          }
        ),
      ),
    );
  }
  
  // questo metodo restituisce le sezioni da rappresentare nel grafico a torta,
  // prende in input la lista di progetti calcolata in precedenza
  List<PieChartSectionData> _sezioni(List<Progetto> progetti) {
    // dati da rappresentare
    Map<String, double> percentualiProgetti = _calcolaDati(progetti);

    // stili
    const radius = 60.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

    return [
      PieChartSectionData(
        color: Colors.green,
        value: percentualiProgetti['attivi'],
        title: '${percentualiProgetti['attivi']!.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
      PieChartSectionData(
        color: Colors.orange,
        value: percentualiProgetti['sospesi'],
        title: '${percentualiProgetti['sospesi']!.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
      PieChartSectionData(
        color: Colors.red,
        value: percentualiProgetti['archiviati'],
        title: '${percentualiProgetti['archiviati']!.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      ),
    ];
  }
  
  // questo metodo si occupa di calcolare le percentuali da rappresentare nel grafico
  // reatituisce una mappa in cui le chiavi sono gli stati dei progetti e i valori sono le percentuali
  // dei progetti in quello stato
  Map<String, double> _calcolaDati(List<Progetto> progetti)  {
    // numero dei progetti
    final int numProgetti = progetti.length;
    
    // se ci sono progetti nel DB allora calcolo i dati
    if(numProgetti > 0) {
      // calcolo il numero di progetti in ogni stato
      final int numAttivi = progetti.where((p) => p.stato == 'attivo').toList().length;
      final int numSospesi = progetti.where((p) => p.stato == 'sospeso').toList().length;
      final int numArchiviati = progetti.where((p) => p.stato == 'archiviato').toList().length;

      // calcola le percentuali
      final double percAttivi = (numAttivi / numProgetti)*100;
      final double percSospesi = (numSospesi / numProgetti)*100;
      final double percArchiviati = (numArchiviati / numProgetti)*100;

      // restituisco una mappa con i dati calcolati
      return {
        'attivi': percAttivi,
        'sospesi': percSospesi,
        'archiviati': percArchiviati,
      };
    
    } else {
      // Se non ci sono provetti nel DB allora tutti 0  
      return {
        'attivi': 0.0,
        'sospesi': 0.0,
        'archiviati': 0.0,
      };
    }
  } 
}

Future<DatiStatistiche> _fetchDatiStatistiche() async {
  final numCompletati = await DatabaseHelper.instance.getNumProgettiCompletati();
  final numFalliti = await DatabaseHelper.instance.getNumProgettiFalliti();
  final progetti = await DatabaseHelper.instance.getAllProgetti();

  return DatiStatistiche(completati: numCompletati, falliti: numFalliti, totale: progetti.length);
}

//classe di utilità per le statistiche, non per i grafici
class DatiStatistiche {
  final int completati;
  final int falliti;
  final int totale;

  DatiStatistiche({
    required this.completati,
    required this.falliti,
    required this.totale
  });

}