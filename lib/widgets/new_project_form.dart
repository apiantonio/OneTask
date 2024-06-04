import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/task_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Form per la creazione di un nuovo progetto
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
  final TextEditingController _dateController = TextEditingController(); // controller per la data
  final TextEditingController _nomeController = TextEditingController(); // controller per il nome del progetto
  final TextEditingController _descrizioneController = TextEditingController(); // controller per la descrizione del progetto
  final TextEditingController _teamController = TextEditingController(); // controller per il menu a tendina per selezionare il team

  List<String> _nomiTeams = []; // Lista per memorizzare i nomi dei team
  String _labelDropdownMenu = 'Seleziona Team'; // testo nel menu a tendina per selezionare il team che varia a seconda che ci siano o meno dei team
  List<Task> _tasks = []; // lista di tasks del progetto
  String? _validaTeamText; // stringa per evidenziare l'obbligatorietà di selezionare un team (se disponibile) per il progetto

  @override
  void initState() {
    super.initState();
    _getNomiTeams(); // Leggi i nomi dei team dal db quando il form viene aperto
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          //mettere Column in Padding perchè quest'ultimo non accetta children ma un solo child
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
            children: [
              ElevatedButton(
                onPressed: () {
                  // .validate() ritorna true se il form è valido, altrimenti false
                  if (_formKey.currentState!.validate()) {
                    // Se è valido, aggiungo il progetto al db
                    _addProgettoToDatabase();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff167485),
                  elevation: 5,
                ),
                child: Text(
                  'Aggiungi progetto',
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
                  if (value == null || value.isEmpty || value.trim().isEmpty) {
                    return "Per favore, inserisci un nome al progetto.";
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
                  labelText: 'Inserisci il nome del progetto',
                  labelStyle: GoogleFonts.inter(
                    fontSize: 16,
                    color:Colors.black54,  
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _descrizioneController,
                maxLength: 250, //massimo 250 parole
                maxLines: null, //quando termina lo spazio continua a capo
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  //rappresenta la decorazione del bordo normalmente, quando selezionato ed in caso di errori
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFF0E4C56), width: 1.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                  ),
                  hintText: 'Inserisci descrizione del progetto...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                  )
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Team',
                softWrap: true, //se non c'è abbastanza spazio manda a capo
                style: GoogleFonts.inter(
                  fontSize: 28,
                  color:const Color(0Xff167485),  
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              //DropDownMenu per selezionare uno tra i team presenti nel db
              DropdownMenu(
                enableFilter: true, // permette di cercare il nome del team e di filtrarli in base a ciò che è scritto
                enabled: _nomiTeams.isNotEmpty, // il menù è disattivato se non ci sono team nel db
                leadingIcon: const Icon(Icons.people, color: Color(0XFFEB701D)), // icoa a sinistra del testo
                label: Text(_labelDropdownMenu), // testo dentro il menu di base, varia seconda che ci siano o meno team
                // helperText: 'Seleziona il team che lavorerà al progetto', // piccolo testo sotto al menu
                width: MediaQuery.of(context).size.width*0.69, // dimensione del menu
                controller: _teamController, // controller
                requestFocusOnTap: true, // permette di scrivere all'interno del menu per cercare gli elementi
                dropdownMenuEntries: _nomiTeams
                  .map((nomeTeam) => // elementi del menu a tendina (i nomi dei team)
                    DropdownMenuEntry<String>(
                      value: nomeTeam,
                      label: nomeTeam,
                      style: MenuItemButton.styleFrom(
                        foregroundColor: Colors.black54,
                      ),
                    )).toList(),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,     //dice che deve esserci un riempimento, non trasparente
                  fillColor:Color.fromARGB(255, 214, 209, 204),   //imposta il colore di riempimento della sezione
                  //imposto il colore del bordo quando è selezionato, normalmente o quando si verificano errori
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
                    _teamController.text = value!;
                    _validaTeamText = null; // se il team è selezionato allora tutt ok
                  });
                },
              ),
              if (_validaTeamText != null) // se non è selezionato un team mostra testo di errore
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _validaTeamText!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                //larghezza la metà dello schermo per garantire responsività
                width: MediaQuery.of(context).size.width * 0.69,
                child: TextFormField(
                  readOnly: true,   //vieto in questo modo che l'utente possa inserire caratteri indesiderati se non la data
                  controller: _dateController, // Associa il controller al campo di testo della data
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Per favore, inserisci una scadenza al progetto.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Aggiungi scadenza...',
                    filled: true, //il campo avrà un colore di sfondo
                    fillColor:Color.fromARGB(255, 214, 209, 204),   //imposta il colore di riempimento della sezione
                    prefixIcon: Icon(Icons.calendar_today, color: Color(0Xff167485)), //aggiunge l'icona nel campo prima del testo
                    //imposto il colore del bordo quando è selezionato, normalmente o quando si verificano errori
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0XFF0E4C56)),
                    ),
                    enabledBorder: InputBorder.none,
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0XFF0E4C56)),
                    ),                 
                    labelStyle: TextStyle(
                      color: Color(0XFFEB701D),
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
              TaskApp(
                onTasksChanged: (newTasks) {
                  // callback per ottenere le task inserite
                  setState(() {
                    _tasks = newTasks;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getNomiTeams() async {
    // prendo tutti i team del db
    List<Team> teams = await DatabaseHelper.instance.getAllTeams();

    setState(() {
      // salvo i nomi di tutti i team
      _nomiTeams = teams.map((team) => team.nome).toList();
      if (_nomiTeams.isEmpty) {
        _labelDropdownMenu = 'Non ci sono team disponibili!';
      }
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0XFFEB701D),   //cerchietto attorno al numero selezionato
              surface: Colors.white,    //colore di sfondo
              onSurface:Color(0XFF0E4C56),   //colore dei numeri
            ),
            //dialogBackgroundColor:const Color.fromARGB(255, 214, 209, 204),   //colore di sfondo del calendario
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toString().split(" ")[0];
      });
    }
  }

  // metodo chiamato quando si preme il pulsante di invio dati del form
  void _addProgettoToDatabase() async {
    // se non è stato selezionato un team mostra un errore
    if (_teamController.text.isEmpty) {
      setState(() {
        _validaTeamText = 'Per favore, seleziona un team.';
      });
      return;
    } else if (!_nomiTeams.contains(_teamController.text)) {
      // se è sttao inserito il nome di un team non valido
      setState(() {
         _validaTeamText = 'Per favore, inserisci il nome di un team valido.';
      });
      return;
    }

    // nome del progetto pulito dagli spazio
    final nomeControllerText = _nomeController.text.trim();

    // controllo che non esista già un Progetto con lo stesso nome nel db
    await DatabaseHelper.instance
        .selectProgettoByNome(nomeControllerText)
        .then((progettoPresente) async {
      // se esiste già un progetto con lo stesso nome
      if (progettoPresente != null) {
        // il progetto NON può essere inserito nella tabella, mostro un messaggio di errore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserisci un nome del progetto non già usato!')),
        );
      } else {
        // se il nome del progetto è nuovo
        // creo un nuovo progetto con i dati inseriti
        // nota che i campi 'stato', 'completato' e 'motivazioneFallimento' assumeranno i valori di default
        // rispettivamente 'attivo', false e NULL
        Progetto newProgetto = Progetto(
          nome: nomeControllerText,
          team: _teamController.text,
          scadenza: _dateController.text,
          descrizione: _descrizioneController.text.trim(),
        );

        // associa il progetto alle tasks
        for (var task in _tasks) {
          task.progetto = newProgetto.nome;
        }

        final db = DatabaseHelper.instance;

        // inserisco il progetto nel db
        await db.insertProgetto(newProgetto)
          .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Progetto memorizzato!')),
              )
          );

        // inserisco le tasks nel db
        Future.wait(_tasks.map((task) => db.insertTask(task)))
          .whenComplete(() => setState(() {
                _tasks.clear();
              })
          );

        // svuoto i campi del form e aggiorno lo stato
        setState(() {
          _nomeController.clear();
          _descrizioneController.clear();
          _dateController.clear();
          _teamController.clear();
        });
      }
    });
  }
}
