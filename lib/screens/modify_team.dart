import 'package:flutter/material.dart';
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
                        //_addModifiedTeam();
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
                    color: const Color(0XFFEFECE9),   //del colore OX sono obbligatorie, FF indica l'opacità
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
              /*********************CODICE PROVA******************************/
              //DropDownMenu per selezionare i team scelti da db o file json
              DropdownMenu(
                enabled: userTeamList.isNotEmpty, // il menù è disattivato se non ci sono utenti nel team
                leadingIcon: const Icon(Icons.people), // icona a sinistra del testo
                label: userTeamList.isNotEmpty ? Text(_labelDropdownMenu) : const Text('Nessun utente nel team'), // testo dentro il menu di base, varia seconda che ci siano o meno persone nel team
                width: MediaQuery.of(context).size.width *0.69, // dimensione del menu
                controller: _respController, // controller
                requestFocusOnTap: true, // permette di scrivere all'interno del menu per cercare gli elementi
                dropdownMenuEntries: userTeamList
                  .map(
                    (utente) => // elementi del menu a tendina (i nomi dei team)
                        DropdownMenuEntry<String>(
                          value: utente.infoUtente(),
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
                onSelected: (String? value) {
                  setState(() {
                    _respController.text = value!;
                    _validaRespText = null; // se il team è selezionato allora tutt ok
                  });
                },
              ),
              if (_validaRespText != null) // se non è selezionato un team mostra testo di errore
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _validaRespText!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              /**********************FINE COD PROVA*****************************/
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

}