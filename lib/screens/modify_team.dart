import 'package:OneTask/model/partecipazione.dart';
import 'package:OneTask/model/team.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:OneTask/model/utente.dart';
import '../widgets/user_item.dart';
class ModifyTeam extends StatelessWidget {
  final String teamName;
  const ModifyTeam({super.key, required this.teamName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFE8E5E0),
      appBar: const OTAppBar(title: 'Modifica team'),
      body: EditTeamForm(teamName: teamName),
    );
  }
}

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
  //controller per il responsabile (quest'ultimo verrà selezionato tramite un dropdownmenu button)
  final TextEditingController _respController = TextEditingController();
  final String _labelDropdownMenu = 'Seleziona Responsabile'; // testo nel menu a tendina per selezionare il responsabile che varia a seconda che ci siano o meno utenti
  String? _validaRespText; // stringa per evidenziare l'obbligatorietà di selezionare un responsabile (se disponibile) per il progetto
  //lista che conterrà gli utenti del team
  final List<Utente> userTeamList = [];
  //lista che contiene le matricole degli utenti che si ha intenzione di aggiungere al team
  final List<String> matricoleUtentiTeam = [];
  //lista che contiene tutti gli utenti che non partecipano ancora a 2 team
  late Future<List<Utente>?> listUtentiFuture;
  //stringa che mantiene il nome del team che viene aggiornato durante la sessione
  late String _nomeTeamOnEdit; 

  @override
  void initState() {
    super.initState();
    //all'inizio listUtentiFuture viene determinata usando la lista vuota di matricoleUtentiTeam
    //in loadTeamData verrà aggiornata
    listUtentiFuture = DatabaseHelper.instance.getUtentiNotInTeam(matricoleUtentiTeam, widget.teamName);
    _loadTeamData();
  }

  Future<void> _loadTeamData() async {
    List<Utente> users = await DatabaseHelper.instance.selectUtentiByTeam(widget.teamName);
    //ricavo dal db le matricole degli utenti del team
    List<String> mat = await DatabaseHelper.instance.selectMatricoleByTeam(widget.teamName);
    //ricavo dal db il nome del responsabile per quel team
    Utente responsabile = await DatabaseHelper.instance.getTeamManager(widget.teamName);
    setState(() {
      _nomeController.text = widget.teamName;
      //all'inizio il responsabile risulta uguale a quello estratto dal db
      _respController.text = responsabile.infoUtente();
      userTeamList.addAll(users);
      matricoleUtentiTeam.addAll(mat);
      //accedo al db per recuperare gli utenti che non sono in quel team
      listUtentiFuture = DatabaseHelper.instance.getUtentiNotInTeam(matricoleUtentiTeam, widget.teamName);
      _nomeTeamOnEdit = widget.teamName; // inizialemnte il nome non è modificato
    });
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
              //il primo elemento del widget è quello che mi permette di modificare il team
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    //la modifica va a buon fine purchè ci siano almeno 2 persone nel team
                    if (userTeamList.length < 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Servono almeno 2 persone nel team')),
                      );
                    } else {
                      _editTeam();
                    }
                  }
                },
                //serve a personalizzare lo stile del bottone
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(const Color(0Xff167485)),
                  elevation: MaterialStateProperty.all(4),
                ),
                child: Text(
                  'Aggiorna Team',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0XFFEFECE9),   //del colore 0X sono obbligatorie, FF indica l'opacità
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
              //DropDownMenu per selezionare gli utenti scelti da db
              DropdownMenu(
                enabled: userTeamList.isNotEmpty, // il menù è disattivato se non ci sono utenti nel team
                leadingIcon: const Icon(Icons.people), // icona a sinistra del testo
                label: userTeamList.isNotEmpty ? Text(_labelDropdownMenu) : const Text('Nessun utente nel team'), // testo dentro il menu di base, varia seconda che ci siano o meno persone nel team
                width: MediaQuery.of(context).size.width *0.69, // dimensione del menu
                controller: _respController, // controller
                requestFocusOnTap: true, // permette di scrivere all'interno del menu per cercare gli elementi
                dropdownMenuEntries: userTeamList
                  .map((utente) => // elementi del menu a tendina (i nomi dei team)
                    DropdownMenuEntry<String>(
                      value: utente.infoUtente(),
                      label: utente.infoUtente(),
                      style: MenuItemButton.styleFrom(
                        foregroundColor: Colors.blue[700],
                      ),
                    )).toList(),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.orange),
                  ),
                  labelStyle: TextStyle(
                    color: Colors.blue,
                  ),
                ),
                onSelected: (String? value) {
                  setState(() {
                    _respController.text = value!;
                    _validaRespText = null; // se il manager è selezionato allora tutt ok
                  });
                },
              ),
              if (_validaRespText != null) // se non è selezionato un manager mostra testo di errore
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _validaRespText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
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
        matricoleUtentiTeam.add(utente.matricola);
      });
      return true;
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Team al completo!')),
      );
      return false;
    }
  }

  // metodo di utilità per eliminare gli utenti al click
  void _removeUtente(Utente utente) {
    setState(() {
      userTeamList.remove(utente);
      matricoleUtentiTeam.remove(utente.matricola);
      //solo nel caso in cui nel dropDown menu ci fosse l'utente che hai cancellato allora svuota la cella
      if(_respController.text == utente.infoUtente()){
        _respController.clear();
      }
      //nel momento in cui un utente viene eliminato dal team dovremmo aggiornare la lista di utenti
      //che potrebbero prendere parte al team
      listUtentiFuture = DatabaseHelper.instance.getUtentiNotInTeam(matricoleUtentiTeam, widget.teamName);
    });
  }
  
  /// metodo per aggiornare le informazioni relative al team nel database
  void _editTeam() async {
    // se non è stato selezionato un manager allora mostra messaggio di errore    
    if (_respController.text.isEmpty) {
      setState(() {
        _validaRespText = 'È necessario scegliere un responsabile del team!';
      });
      return;
    }
    // altrimenti passo a modificare il necessario nel db
    final db = DatabaseHelper.instance;
    // nome del team inserito nel campo di modifica nome
    final nomeTeamController = _nomeController.text.trim();

    // controllo che non ci sia un team con lo stesso nome già presente nel db
    await db.selectTeamByNome(nomeTeamController)
      .then((teamPresente) async {
        if (teamPresente != null && teamPresente.nome != _nomeTeamOnEdit) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            const SnackBar(content: Text('Inserisci un nome del team non già usato!'))
          );
        } else {
          // aggiorno il team
          // nota che UPDATE aggiorna a cascata le Partecipazioni
          await db.updateTeam(_nomeTeamOnEdit,  Team(nome: nomeTeamController))
            .then((value) async { 
              // ora devo aggiornare le partecipazioni associate al team,
              // poiché è possibile che siano stati rimossi utenti dal team questi saranno ancora associati come
              // 'partecipanti' al team anche con nome aggiornato, 
              // dunque è necessario cancellare le partecipazioni inconsistenti se presenti
              
              final partecipazioni = await db.selectPartecipazioniOfTeam(nomeTeamController);
              
              // elenco delle matricole degli utenti presenti in userTeamList, ovvero che saranno nel team aggiornato
              final matricoleTeamList = userTeamList.map((user) => user.matricola).toList();
              
              // filtro le partecipazioni che non sono in matricoleTeamList
              final partecipazioniDaCancellare = partecipazioni?.where((p) => !matricoleTeamList.contains(p.utente)).toList();

              // ora cancello le partecipazioni filtrate
              Future.wait(partecipazioniDaCancellare!.map((partecipazione) => db.deletePartecipazione(partecipazione)))
                .whenComplete(() async {
                  // controllo se il manager è stato cambiato
                  db.getTeamManager(nomeTeamController)
                    .then((manager) {          
                      if (!_respController.text.contains(manager.matricola)) {
                        db.updatePartecipazione(manager.matricola, false, Partecipazione(utente: manager.matricola, team: nomeTeamController));
                      } 
                    }).whenComplete(() async {
                       // aggiungo le nuove partecipazioni
                      for (var user in userTeamList) {
                        await db.insertPartecipazione(Partecipazione(utente: user.matricola, team: nomeTeamController));
                        if (_respController.text.contains(user.matricola)) {
                          await db.updatePartecipazione(user.matricola, true, Partecipazione(utente: user.matricola, team: nomeTeamController));
                        }
                      }
                    }).whenComplete(() {
                      // aggiorno la variabile di stato che mantiene il nome del team aggiornato
                      setState(() {
                        _nomeTeamOnEdit = nomeTeamController;
                      });

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Team aggiornato con successo!')),
                      );
                    });              
                });
            });
        }
      });
  }
}