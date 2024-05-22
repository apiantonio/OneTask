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
  final List<Utente> utentiTeamPreModifica = [];
  late Utente responsabile;
  Utente? selected;

  final TextEditingController _nomeController = TextEditingController();

  // Future<void> _loadProjectData() async {
  //   Team? team = await DatabaseHelper.instance.selectTeamByNome(widget.teamName);
  //   if (team != null) {
  //     List<Utente>? users = await DatabaseHelper.instance.selectUtentiByTeam(widget.teamName);
  //     setState(() {
  //       _nomeController.text = team!.nome;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    // oggetto Team del team da modificare
    Team? team = await DatabaseHelper.instance.selectTeamByNome(widget.teamName);
    if (team != null) {
      // lista di utenti del team
      List<Utente>? users = await DatabaseHelper.instance.selectUtentiByTeam(widget.teamName);
      // Utente respo
      responsabile = await DatabaseHelper.instance.getTeamManager(team);
      // List<Partecipazione?>? parts = []; 
      // users?.map((u) async => 
      //   parts.add(await DatabaseHelper.instance.selectPartecipazioneByUtenteAndTeam(u.matricola, widget.teamName)
      // ));
      setState(() {
        _nomeController.text = team.nome;
        userTeamList.addAll(users ?? []);
        utentiTeamPreModifica.addAll(users ?? []);
      });
    }
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
                        const SnackBar(content: Text('Servono almeno 2 persone nel team')),
                      );
                    } else {
                      if (selected == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Per favore, seleziona un responsabile per il tuo team')),
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
                      selected: utente.matricola == responsabile.matricola,
                      groupValue: selected,
                      onChanged: (Utente? value) => setState(() {
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
                      children: utenti.map((utente) => Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: UserItem(
                          utente: utente,
                          onSelect: _addUtente,
                          onDeselect: _removeUtente,
                        ),
                      )).toList(),
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
    final newNomeTeam = _nomeController.text;

    // se il nome inserito è diverso da quello già presente
    if (newNomeTeam != widget.teamName) {
     await db.selectTeamByNome(newNomeTeam)
      .then((teamPresente) async {
        if (teamPresente != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserisci un nome non già assegnato ad un altro team!')),
          );
        } else {
          // aggiorno il Team nella tabella Team
          db.updateTeam(widget.teamName, Team(nome: newNomeTeam));
        }
      });
    }
    
    // aggiorno i componenti del team nella tabella partecipazione
    for(var utente in userTeamList) {
      // se un utente è stato rimosso dagli utenti del Team allora cancello la partecipazione
      if (!utentiTeamPreModifica.contains(utente)) {
        await db.deletePartecipazione(Partecipazione(utente: utente.matricola, team: widget.teamName));
      }
      // qui gestisco il caso in cui l'utente non è stato rimosso dal team ma il team è stato modificato
      Partecipazione? oldPart = await db.selectPartecipazioneByUtenteAndTeam(utente.matricola, widget.teamName);
      Partecipazione newPart = Partecipazione(
        utente: utente.matricola,
        team: newNomeTeam,
        ruolo: utente == selected // se selected == true allora l'utente è il manager del team
      );
      db.updatePartecipazione(oldPart, newPart);
    }
    // Una volta inseriti mostriamo una SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team Modificato!')),
    );
    // deseleziono gli utenti
    setState(() {
      selected = null;
      // infine ricalcolo quali sono gli utenti mostrabili poiché potrebbero essere cambiati
      // dato che ora potrebbero partecipare a due team
      listUtentiFuture = db.getUtentiNot2Team();
    });
  }
}
