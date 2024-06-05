import 'package:OneTask/model/partecipazione.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/model/utente.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/user_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Form in cui verranno inserite le informazioni per inserire un nuovo team
class NewTeamForm extends StatefulWidget {
  const NewTeamForm({super.key});

  @override
  NewTeamFormState createState() {
    return NewTeamFormState();
  }
}

class NewTeamFormState extends State<NewTeamForm> {
  final _formKey = GlobalKey<FormState>();
  var listUtentiFuture = DatabaseHelper.instance.getUtentiNot2Team();
  //var listUtentiFuture = DatabaseHelper.instance.getAllUtenti();
  final List<Utente> userTeamList = []; 

  Utente? selected;   //serve a specificare quale utente è selezionato come responsabile
  //è il controller del campo di testo in cui è possibile inserire il nome del team
  final TextEditingController _nomeController = TextEditingController();
  // controller per la scrollbar della sezione degli utenti selezionabili come responsabili del team
  final ScrollController _scrollRespController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        //uso un padding per settare una distanza fissa dai bordi dello schermo
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  } else if (selected == null) {
                    //se rispetta il vincolo min utenti, check se è stato selezionato un responsabile
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfavore, seleziona un responsabile per il tuo team')),
                    );
                  }else{
                    // aggiungi il team al db
                    _addNewTeam();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0Xff167485),
                elevation: 5,
              ),
              child: Text(
                'Aggiungi Team',
                style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0XFFEFECE9),   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.w500,
                ),
              ),
              ),
              /*campo aggiunta nome team*/
              TextFormField(
                controller: _nomeController,
                validator: (value) {
                  if(value == null || value.isEmpty || value.trim().isEmpty) {
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
                  labelText: 'Inserisci il nome del team',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color:Colors.black54,  
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Scegli un responsabile',
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color:const Color(0XFF0E4C56),  
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                //un widget che si aggiorna con i valori nella lista
                child: Scrollbar(
                  controller: _scrollRespController, // scrollbar controller da associare anche alla listview
                  thumbVisibility: true, // visibilità della scrollbar sempre true quando ce n'è bisogno
                  child: ListView.builder(
                    controller: _scrollRespController,
                    itemCount: userTeamList.length,
                    //per visualizzare singolarmente i valori
                    itemBuilder: (context, index) {
                      //si salva l'utente al dato indice in una variabile
                      final utente = userTeamList[index];
                      //RadioListTile mi restituisce un RadioButton 
                      return RadioListTile(
                        value: utente,      //qual è il valore di quel listTile
                        groupValue: selected,   //indica quale deve essere spuntato
                        //quando si clicca su un nuovo listTile, il valore di selected cambia
                        onChanged: (value) => setState(() {
                          selected = value;
                        }),
                        //a video sono mostrate le info dell'utente così come sono esposte nel metodo infoUtente
                        title: Text(
                          utente.infoUtente(),
                          style: GoogleFonts.inter(
                            fontSize: 16,  
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Scegli i partecipanti',   
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
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
                    //ciò che restituisce il futureBuilder varia a seconda che la lista sia piena o vuota
                    //se non ci sono utenti in generale o tutti gli utenti già partecipano a due team
                    //allora visualizza un messaggio testuale che notifica il problema
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
    final nomeTeam = _nomeController.text.trim();

    await db.selectTeamByNome(nomeTeam)
    .then((teamPresente) {
      if(teamPresente != null) {
        // team con lo stesso nome già presente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserisci un nome non già assegnato ad un altro team!')),
        );
      } else {
          // inserisco il Team nella tabella Team
        db.insertTeam(Team(nome: nomeTeam));
        // ora inserisco i componenti del team nella tabella partecipazione
        for (var utente in userTeamList) {
          db.insertPartecipazione(
          Partecipazione(
            utente: utente.matricola,
            team: nomeTeam,
            ruolo: utente == selected // se selected == true allora l'utente è il manager del team
          )
        );
        }
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
