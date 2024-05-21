import 'package:OneTask/screens/modify_project.dart';
import 'package:OneTask/screens/modify_team.dart';
import 'package:OneTask/screens/view_project.dart';
import 'package:OneTask/widgets/search_tile.dart';
import 'package:flutter/material.dart';
import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/screens/view_team.dart';
import 'package:OneTask/services/database_helper.dart';

class SearchBarDelegate extends SearchDelegate {
  
  // hint text nella barra di ricerca
  @override
  String get searchFieldLabel => 'Cerca team o progetto'; 


  // pulsante per cancellare il testo
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
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
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
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
        .where((progetto) =>
            progetto?.nome.toLowerCase().contains(query.toLowerCase()) ?? false)
        .map((progetto) => {'nome': progetto?.nome, 'type': 'Progetto'})
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
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('Non ci sono team o progetti al momento.'));
        }

        final results = snapshot.data as List<Map<String, dynamic>>;

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            var result = results[index];

            // credo delle funzioni di callback che saranno associate agli eventi di tap e modifica
            VoidCallback onTapElem = () => {}; // funzione associata al tap sull'elemento della lista
            VoidCallback onPressedModify = () => {}; // funziona associata al tap sulla matita per modificare
            String nomeElem = result['nome'];
            // se è un Team porta alle pagine del Team
            if(result['type'] == 'Team') {               
              onTapElem = () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ViewTeam())
              );
              onPressedModify = () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ModifyTeam())
              );
            } else if(result['type'] == 'Progetto') { // altrimenti per progetto
              onTapElem = () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) =>  ViewProject(projectName: nomeElem))
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
    return FutureBuilder(
      future: _searchResults(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
          return Center(child: Text('Nessun risultato trovato.'));
        }

        final results = snapshot.data as List<Map<String, dynamic>>;

         return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];

            VoidCallback onTapElem = () => {}; // funzione associata al tap sull'elemento della lista
            VoidCallback onPressedModify = () => {}; // funziona associata al tap sulla matita per modificare
            String nomeElem = result['nome'];
            // se è un Team porta alle pagine del Team
            if(result['type'] == 'Team') {               
              onTapElem = () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ViewTeam())
              );
              onPressedModify = () => Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const ModifyTeam())
              );
            } else if(result['type'] == 'Progetto') { // altrimenti per progetto
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

}

