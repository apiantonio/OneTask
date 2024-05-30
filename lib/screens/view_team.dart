import '../model/progetto.dart';
import '../model/team.dart';
import '../model/utente.dart';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../widgets/appbar.dart';

class ViewTeam extends StatelessWidget {
  final String teamName;

  const ViewTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Visualizza Team'),
      body: TeamDetails(teamName: teamName),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete),
        onPressed: () async {
          bool? confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Conferma Eliminazione'),
                content:
                    const Text('Sei sicuro di voler eliminare questo Team?'),
                actions: [
                  TextButton(
                    child: const Text('Annulla'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Elimina'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (confirmDelete == true) {
            Team? team =
                await DatabaseHelper.instance.selectTeamByNome(teamName);
            if (team != null) {
              await DatabaseHelper.instance.deleteTeam(team);
              Navigator.of(context).pop(true); // Torna alla schermata precedente
            }
          }
        },
      ),
    );
  }
}

class TeamDetails extends StatelessWidget {
  final String teamName;

  const TeamDetails({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
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
                  Text(data.team.nome,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Responsabile:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${data.manager.nome} ${data.manager.cognome}',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  const Text('Membri del Team:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.members
                          .map((utente) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text('${utente.nome} ${utente.cognome}'),
                                subtitle:
                                    Text('Matricola: ${utente.matricola}'),
                              ))
                          .toList()),
                  const SizedBox(height: 16),
                  const Text('Progetti associati al team:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  data.progetti == null ? const Text('Nessun progetto associato al team')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: data.progetti!
                          .map((progetto) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(progetto.nome),
                              ))
                          .toList()
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<TeamDetailsData> _fetchTeamDetails() async {
    final db = DatabaseHelper.instance;
    final team = await db.selectTeamByNome(teamName);
    if (team == null) {
      throw Exception('Team non trovato');
    }
    final manager = await db.getTeamManager(team);
    final members = await db.selectUtentiByTeam(teamName);
    final progetti = await db.selectProgettiByTeam(teamName);

    return TeamDetailsData(
        team: team, manager: manager, members: members, progetti: progetti);
  }

}

//classe di utilità che mi restituisce tutte le info che intendo memorizzare sul team
class TeamDetailsData {
  final Team team;
  final Utente manager;
  final List<Utente> members;
  final List<Progetto>? progetti;

  TeamDetailsData(
      {required this.team,
      required this.manager,
      required this.members,
      required this.progetti});
}
