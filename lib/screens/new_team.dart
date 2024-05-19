import 'package:OneTask/model/partecipazione.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../services/database_helper.dart';
import '../widgets/user_item.dart';

class NewTeam extends StatelessWidget {
  const NewTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: OTAppBar(title: 'NuovoTeam'),
        body: const NewTeamForm(),
    );
  }
}

//rappresenta il nostro form
class NewTeamForm extends StatefulWidget {
  const NewTeamForm({super.key});

  @override
  NewTeamFormState createState() {
    return NewTeamFormState();
  }
}

/*work in progress*/ 
class NewTeamFormState extends State<NewTeamForm> {
  final _formKey = GlobalKey<FormState>();
  var listUtentiFuture = DatabaseHelper.instance.getUtentiNot2Team();
  //var listUtentiFuture = DatabaseHelper.instance.getAllUtenti();
  final List<Utente> userTeamList = []; 

  Utente? selected;   //serve a specificare quale utente è selezionato come responsabile

  final TextEditingController _nomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        //per settare una distanza fissa dai bordi dello schermo
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
          children: [
            ElevatedButton(
              onPressed: () {
              // .validate() ritorna true se il form è valido, altrimenti false
                if (_formKey.currentState!.validate()) {
                  //controlla che il team sia composto da almeno 2 utenti
                  if(userTeamList.length < 2){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Servono almeno 2 persone nel team')),
                    );
                  }else{
                    //se rispetta il vincolo min utenti, check se è stato selezionato un responsabile
                    if(selected == null){
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Perfavore, seleziona un responsabile per il tuo team')),
                      );
                    }else{
                      // aggiungi il team al db
                      _addNewTeam();
                    }
                  }
                }
              },
              child: const Text('Aggiungi Team'),
              ),
              /*campo aggiunta nome team*/
              TextFormField(
                controller: _nomeController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Per favore, inserisci un nome al team.";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Inserisci il nome del team',
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Scegli un responsabile',
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                //un widget che si aggiorna con i valori nella lista
                child: ListView.builder(
                  itemCount: userTeamList.length,
                  //per visualizzare singolarmente i valori
                  itemBuilder: (context, index) {
                    //si salva l'utente al dato indice in una variabile
                    final utente = userTeamList[index];
                    //RadioListTile mi restituisce un RadioButton 
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
                'Scegli i partecipanti',   
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                //margin: EdgeInsets.only(bottom: 20),
                height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<List<Utente>?>(
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
                          return ListView(
                              physics: const NeverScrollableScrollPhysics(),
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
                  ),
        ],
      ),
    ),
    );
  }

  //metodo di utilità che restituisce un booleano per validare il numero max di utenti nel team
  bool _addUtente(Utente utente) {
    //nel team è possibile inserire al massimo 6 persone
    if(userTeamList.length < 6){
      setState(() {
        userTeamList.add(utente);
      });
      return true;
    }else{
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
  
  void _addNewTeam() async {
    final db = DatabaseHelper.instance; 
    final nomeTeam = _nomeController.text;

    await db.selectTeamByNome(nomeTeam)
    .then((teamPresente) {
      if(teamPresente != null) {
        // team con lo stesso nome già presente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inserisci un nome non già assegnato ad un altro team!')),
        );
      } else {
          // inserisco il Team nella tabella Team
        db.insertTeam(Team(nome: nomeTeam));
        // ora inserisco i componenti del team nella tabella partecipazione
        userTeamList.forEach((utente) => db.insertPartecipazione(
          Partecipazione(
            utente: utente.matricola,
            team: nomeTeam,
            ruolo: utente == selected // se selected == true allora l'utente è il manager del team
          )
        ));
        // Una volta inseriti mostriamo una SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Team creato!')),  
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
