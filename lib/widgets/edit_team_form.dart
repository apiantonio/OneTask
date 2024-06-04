import 'package:OneTask/model/partecipazione.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/model/utente.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/user_mod_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';

/// Form per la modifica di un team
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
  // controller per la scrollbar dei parteipanti
  final ScrollController _scrollController = ScrollController();

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
    Utente? responsabile = await DatabaseHelper.instance.getTeamManager(widget.teamName);
    setState(() {
      _nomeController.text = widget.teamName;
      //all'inizio il responsabile risulta uguale a quello estratto dal db
      _respController.text = responsabile?.infoUtente() ?? '';
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
                decoration: InputDecoration(
                  border: const UnderlineInputBorder(),
                  //rappresenta la decorazione del bordo normalmente, quando selezionato ed in caso di errori
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0Xff167485), width: 1.0),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                  ),
                  labelText: 'Modifica il nome del team',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color:Colors.black54,  
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              //DropDownMenu per selezionare gli utenti scelti da db
              DropdownMenu(
                enabled: userTeamList.isNotEmpty, // il menù è disattivato se non ci sono utenti nel team
                leadingIcon: const Icon(Icons.people,color: Color(0XFFEB701D)), // icona a sinistra del testo
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
                        foregroundColor:Colors.black54,
                      ),
                    )).toList(),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
                  fillColor: Color.fromARGB(255, 214, 209, 204),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D)),
                  ),
                  enabledBorder: InputBorder.none,
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D)),
                  ),                 
                  labelStyle: TextStyle(
                    color: Color(0XFF0E4C56),
                  ),
                ),
                onSelected: (String? value) {
                  setState(() {
                    _respController.text = value!;
                    _validaRespText = null; // se il manager è selezionato allora tutto ok
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
              Text(
                'Partecipanti',
                softWrap: true,
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color:const Color(0XFF0E4C56),  
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Scrollbar(
                  controller: _scrollController, // scrollbar controller da associare qui e alla listview
                  thumbVisibility: true, // visibilità della scrollbar sempre true quando ce n'è bisogno
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: userTeamList.length,
                    itemBuilder: (context, index) {
                      final utente = userTeamList[index];
                      return ListTile(
                        title: Text(utente.infoUtente()),
                        leading: IconButton(
                          icon: const Icon(Icons.remove, color: Color(0XFFEB701D)), 
                          onPressed: () => _removeUtente(utente),
                        ),
                      );
                    }
                  ),
                ),
              ),
              Text(
                'Aggiungi partecipanti',
                softWrap: true,
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color:const Color(0XFF0E4C56),  
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 5,
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
                    return utenti.isEmpty ? 
                    Text(
                      'Nessun utente disponibile', 
                      style: GoogleFonts.inter(
                        fontSize: 17, 
                        color: const Color(0XFF0E4C56),
                      ),
                    )
                    //altrimenti in un widget Column saranno visualizzati i diversi utenti
                    : Column(
                        children: utenti.map((utente) =>
                          Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: UserModItem(
                              utente: utente,
                              onSelect: _addUtente,
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
      if(userTeamList.contains(utente)){
        return false;
      }else{
        setState(() {
          userTeamList.add(utente);
          matricoleUtentiTeam.add(utente.matricola);
          //nel momento in cui un utente viene aggiunto al team dovremmo aggiornare la lista di utenti
          //che potrebbero prendere parte al team
          listUtentiFuture = DatabaseHelper.instance.getUtentiNotInTeam(matricoleUtentiTeam, widget.teamName);
        });
        return true;
      }
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
  Future<void> _editTeam() async {
    // se non è stato selezionato un manager allora mostra messaggio di errore    
    if (_respController.text.isEmpty) {
      setState(() {
        _validaRespText = 'È necessario scegliere un responsabile del team!';
      });
      return;
    } 
    // controllo se c'è almeno un utente che coincide con il responsabile ottenuto
    if (!userTeamList.any((utente) => utente.infoUtente() == _respController.text.trim())) {
      setState(() {
        _validaRespText = 'Per favore scegli un responsabile valido.';
      });
      return;
    }

    final db = DatabaseHelper.instance;
    final nomeTeamController = _nomeController.text.trim();

    // controllo che non ci sia un team con lo stesso nome già presente nel db
    final teamPresente = await db.selectTeamByNome(nomeTeamController);
    if (teamPresente != null && teamPresente.nome != _nomeTeamOnEdit) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text('Inserisci un nome del team non già usato!'))
      );
      return;
    }

    // aggiorno il team
    await db.updateTeam(_nomeTeamOnEdit, Team(nome: nomeTeamController));

    // gestisco le partecipazioni
    await _gestisciPartecipazioni(db, nomeTeamController);

    // aggiorno la variabile di stato che mantiene il nome del team aggiornato
    setState(() {
      _nomeTeamOnEdit = nomeTeamController;
    });

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(content: Text('Team aggiornato con successo!')),
    );
  }

  // metodo di utilità per gestire le partecipazioni dopo la modifica del team
  _gestisciPartecipazioni(DatabaseHelper db, String nomeTeamController) async {
    // ottengo le partecipazioni attuali
    final partecipazioni = await db.selectPartecipazioniOfTeam(nomeTeamController) ?? [];
    
    // elenco delle matricole degli utenti presenti in userTeamList
    final matricoleTeamList = userTeamList.map((user) => user.matricola).toList();
    
    // filtro le partecipazioni che non sono in matricoleTeamList
    final partecipazioniDaCancellare = partecipazioni.where((p) => !matricoleTeamList.contains(p.utente)).toList();

    // cancello le partecipazioni filtrate
    await Future.wait(partecipazioniDaCancellare.map((partecipazione) => db.deletePartecipazione(partecipazione)));

    // controllo se il manager è stato cambiato
    final manager = await db.getTeamManager(nomeTeamController);
    if (manager != null && !_respController.text.contains(manager.matricola)) {
      final managerPart = await db.selectPartecipazioneByUtenteAndTeam(manager.matricola, nomeTeamController);
      if (managerPart != null) {
        await db.updatePartecipazione(manager.matricola, false, managerPart);
      }
    }

    // aggiungo le nuove partecipazioni
    for (var user in userTeamList) {
      await db.insertPartecipazione(Partecipazione(utente: user.matricola, team: nomeTeamController));
      if (_respController.text.contains(user.matricola)) {
        await db.updatePartecipazione(user.matricola, true, Partecipazione(utente: user.matricola, team: nomeTeamController));
      }
    }
  }
}