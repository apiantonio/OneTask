import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../widgets/appbar.dart';

class ViewTeam extends StatelessWidget {
  final String teamName;

  ViewTeam({Key? key, required this.teamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Visualizza Team'),
      body: TeamDetails(teamName: teamName),
    );
  }
}

class TeamDetails extends StatelessWidget {
  final String teamName;

  const TeamDetails({Key? key, required this.teamName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeamDetailsData>(
      future: _fetchTeamDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Errore nel caricamento dei dettagli del team'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('Team non trovato'));
        } else {
          final data = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.team.nome}',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Text('Responsabile:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${data.manager.nome} ${data.manager.cognome}',
                      style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  Text('Membri del Team:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...data.members.map((utente) => ListTile(
                        title: Text('${utente.nome} ${utente.cognome}'),
                        subtitle: Text('Matricola: ${utente.matricola}'),
                      )),
                  SizedBox(height: 16),
                  Text('Progetti associati al team:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ...data.progetti.map((progetto) => ListTile(
                        title: Text(progetto.nome),
                      )),
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

    if (manager == null || members == null || progetti == null) {
      throw Exception('Errore nel caricamento dei dati del team');
    }

    return TeamDetailsData(
        team: team, manager: manager, members: members, progetti: progetti);
  }
}

class TeamDetailsData {
  final Team team;
  final Utente manager;
  final List<Utente> members;
  final List<Progetto> progetti;

  TeamDetailsData(
      {required this.team,
      required this.manager,
      required this.members,
      required this.progetti});
}
