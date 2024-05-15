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
  final listUtentiFuture = DatabaseHelper.instance.getAllUtenti();

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
                  // Se è valido, mostriamo una SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sto processando i dati...')),
                  );
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
                  child: FutureBuilder<List<Utente>>(
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
                                  )
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
}
