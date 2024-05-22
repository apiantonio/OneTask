import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../model/team.dart';
import 'package:OneTask/model/utente.dart';
import '../widgets/user_item.dart';
import 'package:OneTask/model/partecipazione.dart';

/*da completare FRANCESCO RAGO, solo prova per vedere utilizzo della navigazione*/
class ModifyTeam extends StatelessWidget {
  final String teamName;
  const ModifyTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Modifica team'),
      body: EditTeamForm(teamName: teamName),
    );
  }
}

//form
class EditTeamForm extends StatefulWidget {
  final String teamName;
  const EditTeamForm({super.key, required this.teamName});

  @override
  EditTeamFormState createState() {
    return EditTeamFormState();
  }
}

class EditTeamFormState extends State<EditTeamForm> {
  final _formKey = GlobalKey<FormState>();
  var listUtentiFuture = DatabaseHelper.instance.getUtentiNot2Team();
  final List<Utente> userTeamList = [];

  Utente? selected;

  final TextEditingController _nomeController = TextEditingController();

  /* Future<void> _loadProjectData() async {
    Team? team =
        await DatabaseHelper.instance.selectTeamByNome(widget.teamName);
    if (Team != null) {
      List<Utente>? users =
          await DatabaseHelper.instance.selectUtentiByTeam(widget.teamName);
      setState(() {
        _nomeController.text = team!.nome;
      });
    }
  }*/

  Future<List<Utente>> _getUtenti() async {
    List<Utente>? users =
        await DatabaseHelper.instance.selectUtentiByTeam(widget.teamName);
    return users ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (userTeamList.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Servono almeno 2 persone nel team')),
                      );
                    } else {
                      if (selected == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Per favore, seleziona un responsabile per il tuo team')),
                        );
                      } else {
                        _addModifiedTeam();
                      }
                    }
                  }
                },
                child: const Text('Modifica Team'),
              ),
              TextFormField(
                controller: _nomeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Per favore, inserisci un nome al team.";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Modifica il nome del team',
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Modifica il Responsabile',
                softWrap: true,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ListView.builder(
                  itemCount: userTeamList.length,
                  itemBuilder: (context, index) {
                    final utente = userTeamList[index];
                    return RadioListTile(
                      value: utente,
                      groupValue: selected,
                      onChanged: (value) => setState(() {
                        selected = value;
                      }),
                      title: Text(utente.infoUtente()),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Modifica i partecipanti',
                softWrap: true,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              FutureBuilder<List<Utente>?>(
                future: listUtentiFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Errore caricamento utenti dal db');
                  } else {
                    List<Utente> utenti = snapshot.data ?? [];
                    return Column(
                      children: utenti
                          .map(
                            (utente) => Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: UserItem(
                                utente: utente,
                                onSelect: _addUtente,
                                onDeselect: _removeUtente,
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _addUtente(Utente utente) {
    //nel team è possibile inserire al massimo 6 persone
    if (userTeamList.length < 6) {
      setState(() {
        userTeamList.add(utente);
      });
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team al completo!')),
      );
      return false;
    }
  }

  //metodo di utilità per eliminare gi utenti al click
  void _removeUtente(Utente utente) {
    setState(() {
      userTeamList.remove(utente);
    });
  }

  void _addModifiedTeam() async {
    final db = DatabaseHelper.instance;
    final nomeTeam = _nomeController.text;

    await db.selectTeamByNome(nomeTeam).then((teamPresente) {
      if (teamPresente != null) {
        // team con lo stesso nome già presente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Inserisci un nome non già assegnato ad un altro team!')),
        );
      } else {
        // inserisco il Team nella tabella Team
        db.updateTeam(Team(nome: nomeTeam));
        // ora inserisco i componenti del team nella tabella partecipazione
        userTeamList.forEach((utente) => db.updatePartecipazione(Partecipazione(
            utente: utente.matricola,
            team: nomeTeam,
            ruolo: utente ==
                selected // se selected == true allora l'utente è il manager del team
            )));
        // Una volta inseriti mostriamo una SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team Modificato!')),
        );
        // ripulisco il campo del nome del team
        _nomeController.clear();
        // deseleziono gli utenti
        setState(() {
          userTeamList.clear();
          selected = null;
        });
        // infine ricalcolo quali sono gli utenti mostrabili poiché potrebbero essere cambiati
        // dato che ora potrebbero partecipare a due team
        listUtentiFuture = db.getUtentiNot2Team();
      }
    });
  }
}
