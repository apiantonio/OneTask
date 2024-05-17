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
  //final listUtentiFuture = DatabaseHelper.instance.getUtentiNot2Team();
  final listUtentiFuture = DatabaseHelper.instance.getAllUtenti();
  final List<Utente> userTeamList = []; 
  Utente? selected;   //serve a specificare quale utente è selezionato come responsabile

  TextEditingController _nomeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        //per settare una distanza fissa dai bordi dello schermo
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        //mettere Column in Padding perchè quest'ultimo non accetta children ma un solo child
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
          children: [
            ElevatedButton(
              onPressed: () {
              // .validate() ritorna true se il form è valido, altrimenti false
                if (_formKey.currentState!.validate()) {
                  // aggiungo il tam al DB
                  _addNewTeam();
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

              const SizedBox(
                height: 5,
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

              const Text(
                'Scegli i partecipanti',   
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Container(
                //margin: EdgeInsets.only(bottom: 20),
                height: MediaQuery.of(context).size.height,
                  child: FutureBuilder<List<Utente>?>(
                      future: listUtentiFuture,
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        else if(snapshot.hasError){
                          return Text('Errore caricamento utenti dal db');
                        }else{
                          //se non da problemi crea/restituisci la lista di utenti
                          List<Utente> Utenti = snapshot.data ?? [];
                          return ListView(
                              children: Utenti.map((Utente) =>
                                Container(
                                  margin: EdgeInsets.only(bottom: 8.0),
                                  child: UserItem(
                                    utente: Utente,
                                    onSelect: _addUtente,
                                    onDeselect: _removeUtente
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

  void _addUtente(Utente utente) {
    setState(() {
      userTeamList.add(utente);
    });
  }

  void _removeUtente(Utente utente) {
    setState(() {
      userTeamList.remove(utente);
    });
  }
  
  void _addNewTeam() {
    final db =  DatabaseHelper.instance; 
    final nomeTeam = _nomeController.text;
    // inserisco il Team nella tabella Team
    db.insertTeam(Team(nome: nomeTeam));
    // ora inserisco i componenti del team nella tabella partecipazione
    userTeamList.forEach((utente) => db.insertPartecipazione(Partecipazione(utente: utente.matricola, team: nomeTeam)));
    // Una volta inseriti mostriamo una SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Team creato!')),
    );
}
}
