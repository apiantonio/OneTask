import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/model/utente.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget di utilità per rappresentare le informazioni di un team
class TeamDetails extends StatelessWidget {
  final String teamName;

  const TeamDetails({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    //tramite questo future builder posso estrarre tutte le info che mi servono del team
    //(compresi i progetti a cui lavora)
    return FutureBuilder<TeamDetailsData>(
      future: _fetchTeamDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('Errore nel caricamento dei dettagli del team'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Team non trovato'));
        } else {

          final data = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.team.nome,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      color: const Color(0XFF0E4C56),   //del colore 0X sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Responsabile:',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      color: const Color(0Xff167485),   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${data.manager.nome} ${data.manager.cognome}',
                    style:  GoogleFonts.inter(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Membri del Team:',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      color: const Color(0Xff167485),   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.bold,
                    ),
                  ),   
                  //questo widget column contiene tutte le persone che lavorano al team
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: data.members
                      .map((utente) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${utente.nome} ${utente.cognome}',
                          style:  GoogleFonts.inter(
                            fontSize: 17,
                          ),
                        ),
                        subtitle: Text(
                          'Matricola: ${utente.matricola}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                          ),
                        ),
                      )).toList()
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Progetti associati al team:',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      color: const Color(0Xff167485),   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.bold,
                    ),      
                  ),
                  //poichè un team potrebbe non avere al momento progetti associati 
                  //questo comportamento è stato necessario gestirlo
                  data.progetti.isEmpty 
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10), 
                        child: Text(
                          'Non ci sono progetti associati al team', 
                          style: GoogleFonts.inter(
                            fontSize: 17, 
                            color: const Color(0XFF0E4C56),
                            )
                          )
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.progetti
                          .map((progetto) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              progetto.nome,
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: const Color(0XFFEB701D),
                              ),
                            ),
                          )).toList()
                      ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  //questo metodo asincrono è utile per ottenere rapidamente tutte le info sul team:
  //info di carattere generale, chi è il manager,quali sono i progetti associati
  Future<TeamDetailsData> _fetchTeamDetails() async {
    final db = DatabaseHelper.instance;
    final team = await db.selectTeamByNome(teamName);
    if (team == null) {
      throw Exception('Team non trovato');
    }
    final manager = await db.getTeamManager(teamName);
    final members = await db.selectUtentiByTeam(teamName);
    final progetti = await db.selectProgettiByTeam(teamName);

    return TeamDetailsData(team: team, manager: manager!, members: members, progetti: progetti);
  }

}

/// classe di utilità che mi restituisce tutte le info che intendo memorizzare sul team
class TeamDetailsData {
  final Team team;
  final Utente manager;
  final List<Utente> members;
  final List<Progetto> progetti;

  TeamDetailsData({
    required this.team,
    required this.manager,
    required this.members,
    required this.progetti
  });
}
