import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../model/team.dart';
import 'package:OneTask/model/utente.dart';
import '../widgets/user_item.dart';
//import 'package:OneTask/model/partecipazione.dart';
class ModifyTeam extends StatelessWidget {
  final String teamName;
  const ModifyTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Modifica team'),
      //body: EditTeamForm(teamName: teamName),
    );
  }
}

/*
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
  final TextEditingController _nomeController = TextEditingController();
  TextEditingController _respController = TextEditingController();
  //lista che conterrà gli utenti del team
  final List<Utente> userTeamList = [];
  //lista che contiene tutti gli utenti sia quelli già nel team che quelli che non partecipano ancora a 2 team
  late Future<List<Utente>?> listUtentiFuture;

  @override
  void initState() {
    super.initState();
    _loadTeamData();
    listUtentiFuture = DatabaseHelper.instance.getUtentiModifyTeam(widget.teamName);
  }

  Future<void> _loadTeamData() async {
    Team? team = await DatabaseHelper.instance.selectTeamByNome(widget.teamName);
    if (team != null) {
      List<Utente> users = await DatabaseHelper.instance.selectUtentiByTeam(widget.teamName);
      setState(() {
        _nomeController.text = team.nome;
        userTeamList.addAll(users);
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
                        const SnackBar(
                            content: Text('Servono almeno 2 persone nel team')),
                      );
                    } else {
                        //_addModifiedTeam();
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
              const SizedBox(height: 15),
              FutureBuilder<Utente>(
                future: DatabaseHelper.instance.getTeamManager(widget.teamName), 
                builder:  (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  else if(snapshot.hasError){
                    return const Text('Errore caricamento utenti dal db');
                  }else{
                    Utente responsabile = snapshot.data!;
                    _respController = TextEditingController(text: responsabile.infoUtente());
                    return DropdownMenu(
                      enabled: userTeamList.isNotEmpty, // il menù è disattivato se non ci sono persone
                      leadingIcon:const Icon(Icons.person), // icoa a sinistra del testo
                      label: const Text('Seleziona responsabile'), // testo dentro il menu di base, varia seconda che ci siano o meno utenti
                      width: MediaQuery.of(context).size.width * 0.69, // dimensione del menu
                      controller: _respController, // controller
                      requestFocusOnTap: true, // permette di scrivere all'interno del menu per cercare gli elementi
                      dropdownMenuEntries: userTeamList
                        .map(
                            (utente) => // elementi del menu a tendina (i nomi dei team)
                                DropdownMenuEntry<Utente>(
                                  value: utente,
                                  label: utente.infoUtente(),
                                  style: MenuItemButton.styleFrom(
                                    foregroundColor: Colors.blue[700],
                                  ),
                                ))
                        .toList(),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        labelStyle: TextStyle(
                          color: Colors.blue,
                        ),
                      ),
                      onSelected: (Utente? utente) {
                        setState(() {
                          _respController.text = utente!.infoUtente();
                          //_validaTeamText = null; // se il team è selezionato allora tutt ok
                        });
                      },
                    );
                    /*if (_validaTeamText != null) // se non è selezionato un team mostra testo di errore
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _validaTeamText!,
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),*/
                  }
                }
              ),
              const SizedBox(height: 15),
              const Text(
                'Partecipanti',
                softWrap: true,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: ListView.builder(
                  itemCount: userTeamList.length,
                  itemBuilder: (context, index) {
                    final utente = userTeamList[index];
                    return ListTile(
                      title:Text(utente.infoUtente()),
                      leading: IconButton(
                        icon: const Icon(Icons.remove), 
                        onPressed: () => _removeUtente(utente),
                      ),
                    );
                  }
                ),
              ),
              const Text(
                'Aggiungi partecipanti',
                softWrap: true,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              FutureBuilder<List<Utente>?>(
                future: listUtentiFuture,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  else if(snapshot.hasError){
                    return const Text('Errore caricamento utenti dal db');
                  }else{
                    //se non da problemi crea/restituisci la lista di utenti
                    List<Utente> utenti = snapshot.data ?? [];
                    return Column(
                      children: utenti.map((utente) =>
                        Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: UserItem(
                            utente: utente,
                            onSelect: _addUtente,
                            onDeselect: _removeUtente,
                          ),
                        ),
                      ).toList(),
                    );
                  }
                }
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _addUtente(Utente utente) {
    // nel team è possibile inserire al massimo 6 persone
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

  // metodo di utilità per eliminare gli utenti al click
  void _removeUtente(Utente utente) {
    setState(() {
      userTeamList.remove(utente);
      listUtentiFuture = DatabaseHelper.instance.getUtentiModifyTeam(widget.teamName);
    });
  }

  void _addModifiedTeam() async {
    final db = DatabaseHelper.instance;
    final newNomeTeam = _nomeController.text;

    // se il nome inserito è diverso da quello già presente
    if (newNomeTeam != widget.teamName) {
      await db.selectTeamByNome(newNomeTeam).then((teamPresente) async {
        if (teamPresente != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Inserisci un nome non già assegnato ad un altro team!')),
          );
        } else {
          // aggiorno il Team nella tabella Team
          db.updateTeam(widget.teamName, Team(nome: newNomeTeam));
        }
      });
    }

    // aggiorno i componenti del team nella tabella partecipazione
    for (var utente in userTeamList) {
      // Se un utente è stato rimosso dagli utenti del Team allora cancello la partecipazione
      if (!utentiTeamPreModifica.contains(utente)) {
        await db.deletePartecipazione(Partecipazione(utente: utente.matricola, team: widget.teamName));
      }

      // Qui gestisco il caso in cui l'utente non è stato rimosso dal team ma il team è stato modificato
      Partecipazione? oldPart = await db.selectPartecipazioneByUtenteAndTeam(
          utente.matricola, widget.teamName);

      // Crea una nuova partecipazione con il nuovo nome del team
      Partecipazione newPart = Partecipazione(
        utente: utente.matricola,
        team: newNomeTeam,
        ruolo: utente ==
            selected // se selected == true allora l'utente è il manager del team
      );

      if (oldPart != null) {
        // Aggiorna la partecipazione esistente
        await db.updatePartecipazione(oldPart, newPart);
      } else {
        // Aggiungi una nuova partecipazione per gli utenti nuovi
        await db.insertPartecipazione(newPart);
      }
    }

    // Aggiungi i nuovi utenti al team
    for (var utente in utentiTeamPreModifica) {
      if (!userTeamList.contains(utente)) {
        Partecipazione newPart = Partecipazione(
          utente: utente.matricola,
          team: newNomeTeam,
          ruolo: false //  l'utente appena inserito non è il manager del team
        );
        await db.insertPartecipazione(newPart);
      }
    }

    // Una volta inseriti mostriamo una SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team Modificato!')),
    );

    // deseleziono gli utenti
    setState(() {
      // infine ricalcolo quali sono gli utenti mostrabili poiché potrebbero essere cambiati
      // dato che ora potrebbero partecipare a due team
      utentiNonInTeamFuture = db.getUtentiNonInTeam(newNomeTeam);
    });
  }
}*/
