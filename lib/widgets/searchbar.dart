import 'package:OneTask/screens/modify_project.dart';
import 'package:OneTask/screens/modify_team.dart';
import 'package:OneTask/screens/projects_and_teams.dart';
import 'package:OneTask/screens/statistiche.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/widgets/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/screens/view_team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/dashboard.dart';

class SearchBarDelegate extends SearchDelegate {
  final String? sourcePage; // stringa che indica in che pagina è presente la searchbar
  SearchBarDelegate({required this.sourcePage});

  // hint text nella barra di ricerca
  @override
  String get searchFieldLabel => 'Cerca team o progetto';

  // pulsante per cancellare il testo
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.clear,
          color: Color(0XFFEB701D),
        ),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  // pulsante per tornare indietro
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        color:const Color(0XFFEB701D),
        progress: transitionAnimation,
      ),
      onPressed: () {
        switch (sourcePage) {
          case 'Dashboard':
            Navigator.pushReplacement( // torna indietro renderizzando una nuova dashboard
              context,
              MaterialPageRoute(builder: (context) => const OTDashboard()),
            );
            break;
          case 'Statistiche':
            Navigator.pushReplacement( // torna indietro renderizzando una nuova pagina statistiche
              context,
              MaterialPageRoute(builder: (context) => const Statistiche()),
            );
            break;
          case 'Progetti e teams':
            Navigator.pushReplacement( // torna indietro renderizzando una nuova pagina progetti e teams
              context,
              MaterialPageRoute(builder: (context) => const ProjectTeam()),
            );
            break;
          default:
            close(context, null);
        }
      },
    );
  }

  // esegue una ricerca tra team e progetti, restituisce una lista di mappe
  // contenenti coppe di tipo String, dinamic perché il value può essere stringa o Team/Progetto
  Future<List<Map<String, dynamic>>> _searchResults(String query) async {
    // prendo tutti i team e tutti i progetti dal DB
    final List<Team?> teams = await DatabaseHelper.instance.getAllTeams();
    final List<Progetto?> progetti = await DatabaseHelper.instance.getAllProgetti();

    // salvo i team il cui nome contiene la query scritta dall'utente
    final teamResults = teams
      .where((team) => team?.nome.toLowerCase().contains(query.toLowerCase()) ?? false)
      .map((team) => {'nome': team?.nome, 'type': 'Team'})
      .toList();

    // salvo i progetti il cui nome contiene la query scritta dall'utente
    final progettoResults = progetti
      .where((progetto) => progetto?.nome.toLowerCase().contains(query.toLowerCase()) ?? false)
      .map((progetto) => {'nome': progetto?.nome, 'type': 'Progetto', 'stato': progetto?.stato})
      .toList();

    return teamResults + progettoResults;
  }

  // gestisce i suggerimenti visualizzati mentre l'utente digita
  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: _searchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text(
            'Non ci sono team o progetti al momento.',
            style: GoogleFonts.inter(
              fontSize: 16,
            ),
          ));
        }

        final results = snapshot.data as List<Map<String, dynamic>>;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var result = results[index];

            // credo delle funzioni di callback che saranno associate agli eventi di tap e modifica
            void Function() onTapElem = () => {}; // funzione associata al tap sull'elemento della lista
            void Function() onPressedModify = () => {}; // funziona associata al tap sulla matita per modificare
            String nomeElem = result['nome'];
            // se è un Team porta alle pagine del Team
            if (result['type'] == 'Team') {
              onTapElem = () => Navigator.push(
                context,
                MaterialPageRoute( builder: (context) => ViewTeam(teamName: nomeElem))
              );
              onPressedModify = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModifyTeam(teamName: nomeElem))
              );
            } else if (result['type'] == 'Progetto') {
              // altrimenti per progetto
              onTapElem = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewProject(projectName: nomeElem))
              );
              onPressedModify = () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModifyProject(projectName: nomeElem))
              );
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchTile(
                onTapElem: onTapElem,
                onPressedModify: onPressedModify,
                result: result
              ),
            );
          },
        );
      },
    );
  }

  // Visualizza i risultati della ricerca
  @override
  Widget buildResults(BuildContext context) {
    return Container(
      color:const Color(0XFFE8E5E0),
      child: FutureBuilder(
        future: _searchResults(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
            return Center(child: Text(
              'Nessun risultato trovato.',
              style: GoogleFonts.inter(
                fontSize: 16,
              )),
            );
          }

          final results = snapshot.data as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];

              void Function() onTapElem = () => {}; // funzione associata al tap sull'elemento della lista
              void Function() onPressedModify = () => {}; // funziona associata al tap sulla matita per modificare
              String nomeElem = result['nome'];
              // se è un Team porta alle pagine del Team
              if (result['type'] == 'Team') {
                onTapElem = () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewTeam(teamName: nomeElem))
                );
                onPressedModify = () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifyTeam(teamName: nomeElem))
                );
              } else if (result['type'] == 'Progetto') {
                // altrimenti per progetto
                onTapElem = () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewProject(projectName: nomeElem))
                );
                onPressedModify = () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifyProject(projectName: nomeElem))
                );
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SearchTile(
                  onTapElem: onTapElem,
                  onPressedModify: onPressedModify,
                  result: result
                ),
              );
            },
          );
        },
      ),
    );
  }
}
