import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/task_section.dart';

class NewProject extends StatelessWidget {
  const NewProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: OTAppBar(title: 'Nuovo Progetto'),
        body: const NewProjectForm(),
    );
  }
}

// Rappresenta il nostro form
class NewProjectForm extends StatefulWidget {
  const NewProjectForm({super.key});

  @override
  NewProjectFormState createState() {
    return NewProjectFormState();
  }
}

// Lo State memorizza le informazioni del form.
class NewProjectFormState extends State<NewProjectForm> {
  // Creiamo una chiave globale che identifica univocamente
  // il widget del Form e permette di fare la validazione.
  // NB: questa è una GlobalKey<FormState>, FormState è una
  // classe che rappresenta lo State di un Form generico
  final _formKey = GlobalKey<FormState>();
  //il controller che mi serve per la data
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nomeController = TextEditingController();
  TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _attivitaController = TextEditingController();
  TextEditingController _teamController = TextEditingController();
  
  List<String> _nomiTeams = []; // Lista per memorizzare i nomi dei team

  @override
  void initState() {
    super.initState();
    _getNomiTeams(); // Leggi i nomi dei team dal db quando il form viene creato
  }

  @override
  Widget build(BuildContext context) {
    // La key è necessaria per creare il Form
    return Form(
      key: _formKey,
      //mi serve un componente scrollabile altrimenti non possovedere tutti gli elementi nella pagina
      child: SingleChildScrollView(
        child: Padding(
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
                    _addProgettoToDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sto processando i dati...')),
                    );
                    
                  }
                },
                child: const Text('Aggiungi progetto'),
              ),
              TextFormField(
                controller: _nomeController,
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Per favore, inserisci un nome al progetto.";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Inserisci il nome del progetto',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _descrizioneController,
                maxLength: 250,   //massimo 250 parole
                maxLines: null,   //quando termina lo spazio continua a capo
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Inserisci descrizione del progetto...',
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Team',   
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //DropDownMenu per selezionare i team scelti da db o file json
              Container(
                width: 100,
                height: 50,
                child: DropdownMenu(
                  hintText: 'Seleziona un team',
                  menuHeight: 50,
                  controller: _teamController,
                  dropdownMenuEntries: _nomiTeams.map
                    ((nomeTeam) => 
                      DropdownMenuEntry<String>(
                        value: nomeTeam,
                        label: nomeTeam
                    )).toList(),
                   inputDecorationTheme: InputDecorationTheme(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                //larghezza la metà dello schermo per garantire responsività
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _dateController, // Associa il controller al campo di testo della data
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "Per favore, inserisci una scadenza al progetto.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Aggiungi scadenza...',
                    filled: true, //il campo avrà un colore di sfondo
                    prefixIcon: Icon(Icons.calendar_today), //aggiunge l'icona nel campo prima del testo
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    _selectDate();
                  },
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              const Text(
                'Cosa vuoi fare?',
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TaskApp(),
            ],
          ),
        ),
      ),
    );
  }

   Future<void> _getNomiTeams() async {
    List<Team> teams = await DatabaseHelper.instance.getAllTeams();
    
    setState(() {
      _nomiTeams = teams.map((team) => team.nome).toList();
    });
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }
  
  // metodo chiamato quando si preme il pulsante di invio dati del form
  void _addProgettoToDatabase() async {
    // creo un nuovo progetto con i dati inseriti
    // nota che i campi 'stato', 'completato' e 'motivazioneFallimento' assumeranno i valori di default
    // rispettivamente 'attivo', false e NULL
    Progetto newProgetto = Progetto (
      nome: _nomeController.text,
      team: _teamController.text,
      scadenza: _dateController.text,
      descrizione: _descrizioneController.text,
    );

    /*############## TEST ##################*/
    // Stampo tutti i progetti memorizzati nel db per test
    // List<Progetto> allProgetti = await DatabaseHelper.instance.getAllProgetti();
    // allProgetti.forEach((progetto) {
    //   print('### TEST STAMPA DEI PROGETTI ###');
    //   print(progetto); // Stampo direttamente il progetto usando il metodo toString()
    // });
    //###########################

    // controllo che non esista già un Progetto con lo stesso nome nel db
    Progetto? progettoPresente = await DatabaseHelper.instance.selectProgettoByNome(newProgetto.nome);

    if(progettoPresente != null) {
      // il progetto NON può essere inserito nella tabella mostro un messaggio di errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un nome del progetto non già usato!')),
      );
    } else {
      // inserisce il progetto nel db
      await DatabaseHelper.instance.insertProgetto(newProgetto);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Progetto memorizzato!')),
      );
      
      // svuoto i campi del form
      _nomeController.clear();
      _nomeController.clear();
      _dateController.clear();
      _teamController.clear();
      _attivitaController.clear();
    }
  }
}

