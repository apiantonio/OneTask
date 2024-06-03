import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:flutter/widgets.dart';
import '../model/team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/task_section.dart';

class ModifyProject extends StatelessWidget {
  final String projectName;

  const ModifyProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Modifica Progetto', withSearchbar: false),
      body: EditProjectForm(projectName: projectName),
      backgroundColor: const Color(0XFFE8E5E0),
    );
  }
}

class EditProjectForm extends StatefulWidget {
  final String projectName;

  const EditProjectForm({super.key, required this.projectName});

  @override
  EditProjectFormState createState() {
    return EditProjectFormState();
  }
}

class EditProjectFormState extends State<EditProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _teamController =TextEditingController(); 
  final TextEditingController _descrizioneController = TextEditingController();
  final TextEditingController _motivazioneController = TextEditingController();
  final TextEditingController _statoController = TextEditingController();
  
  late Future<List<Task>?> _oldTasks; // lista che conterrà le task già associate al progetto da modificare
  List<Task> _tasks = []; // lista di task che mantiene tutte le task della lista rappresentata
  List<String> _nomiTeams = [];  // lista dei nomi dei teams disponibili

  //serve per indicarmi gli stati e i sottostati corrispondenti
  final List<String> _stato = [
    'attivo',
    'sospeso',
    'completato', 
    'fallito',
  ];

  final String _labelDropdownMenuT = 'Seleziona Team';
  String? _validaTeamText; 
  String? _validaStatoText; 
  late String _nomeProgettoWhenModificato; // In questa stringa andrò a inserire il nome del progetto ogni volta che questo viene modificato

  @override
  void initState() {
    super.initState();
    _loadProjectData();
    _getNomiTeams();
    _oldTasks = DatabaseHelper.instance.getTasksByProject(widget.projectName); // salvo le task già associate al progetto
    _nomeProgettoWhenModificato = widget.projectName; // inizialmente inizializzo al vecchio nome del progetto
  }

  Future<void> _loadProjectData() async {
    Progetto? progetto = await DatabaseHelper.instance.selectProgettoByNome(widget.projectName);

    if (progetto != null) {
      _tasks = await DatabaseHelper.instance.getTasksByProject(widget.projectName);

      setState(() {
        _nomeController.text = progetto.nome;
        _descrizioneController.text = progetto.descrizione ?? '';
        _dateController.text = progetto.scadenza;
        _teamController.text = progetto.team;
        if(progetto.stato == 'archiviato' && _motivazioneController.text != ''){
          _statoController.text = 'fallito';
        }else{
          if(progetto.stato == 'archiviato' && _motivazioneController.text == ''){
            _statoController.text = 'completato';
          }else{
            _statoController.text = progetto.stato;}
        }
        _motivazioneController.text = progetto.motivazioneFallimento ?? '';
      });
    }
  }

  Future<void> _getNomiTeams() async {
    // prendo tutti i team del db
    List<Team> teams = await DatabaseHelper.instance.getAllTeams();

    setState(() {
      // salvo i nomi di tutti i team
      _nomiTeams = teams.map((team) => team.nome).toList();
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _modificaProgetto();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0Xff167485),
                  elevation: 5,
                ),
                child: Text(
                  'Aggiorna progetto',
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
              const SizedBox(height: 20),
              TextFormField(
                controller: _descrizioneController,
                maxLength: 250,
                maxLines: null,
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
              const SizedBox(height: 3),
              Text(
                'Team',
                softWrap: true, //se non c'è abbastanza spazio manda a capo
                style: GoogleFonts.inter(
                  fontSize: 25,
                  color:const Color(0Xff167485),  
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              //DropDownMenu per selezionare i team scelti da db o file json
              DropdownMenu(
                enableFilter: true, // permette di cercare il nome del team e di filtrarli in base a ciò che è scritto
                enabled: _nomiTeams.isNotEmpty, // il menù è disattivato se non ci sono team nel b
                leadingIcon:
                    const Icon(Icons.people, color: Color(0XFFEB701D)), // icoa a sinistra del testo
                label: Text(_labelDropdownMenuT), // testo dentro il menu di base, varia seconda che ci siano o meno team
                // helperText: 'Seleziona il team che lavorerà al progetto', // piccolo testo sotto al menu
                width: MediaQuery.of(context).size.width *0.69, // dimensione del menu
                controller: _teamController, // controller
                requestFocusOnTap: true, // permette di scrivere all'interno del menu per cercare gli elementi
                dropdownMenuEntries: _nomiTeams.map((nomeTeam) => // elementi del menu a tendina (i nomi dei team)
                  DropdownMenuEntry<String>(
                    value: nomeTeam,
                    label: nomeTeam,
                    style: MenuItemButton.styleFrom(
                      foregroundColor:Colors.black54,
                    ),
                  )).toList(),
                inputDecorationTheme: const InputDecorationTheme(
                  filled: true,
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
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.69,
                child: TextFormField(
                  readOnly: true,   //vieto in questo modo che l'utente possa inserire caratteri indesiderati se non la data
                  controller: _dateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Per favore, inserisci una scadenza al progetto.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Aggiungi scadenza...',
                    filled: true,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Stato del progetto',
                  style: GoogleFonts.inter(
                    fontSize: 25,
                    color:const Color(0Xff167485),  
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //rappresenta il menu a tendina dal quale è possibile selezionare qual è il nuovo stato
              //del progetto
              PopupMenuButton<String>(
                //il valore iniziale è quello estratto dal db
                initialValue: _statoController.text,
                //ogni volta che viene selezionato qualcosa si aggiorna il controller
                onSelected: (String value) => {
                  setState(() {
                    _statoController.text = value;
                    _validaStatoText = null; 
                  })
                },
                //all'interno di un sizedBox rendo visibile lo stato attuale
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: ListTile(
                    title: Text(
                      _statoController.text,
                      style: GoogleFonts.inter(
                        fontSize: 16,  
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_drop_down),
                  ),
                ),
                //serve per creare l'elenco delle voci nel menu a comparsa
                itemBuilder: (BuildContext context) {
                  List<PopupMenuEntry<String>> tendina = [];
                  //iterando sulla lista di stati (di stringhe) creata in partenza 
                  for (var stato in _stato) {
                    //aggiungo le voci all'interno degli item che compongono il PopupMenuEntry
                    tendina.add(
                      PopupMenuItem<String>(
                        value: stato,
                        child: Text(
                          stato, 
                          style: GoogleFonts.inter(
                            fontSize: 15,  
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  }
                  return tendina;
                }
              ),
              if (_validaStatoText != null) // se non è selezionato uno stato o lo stato non è valido mostra testo di errore
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _validaStatoText!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _motivazioneController,
                enabled: _statoController.text == 'fallito' ? true : false,
                maxLength: 50,
                maxLines: null,
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
                  hintText: 'Inserisci motivazione del fallimento...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                  )
                ),
                validator: (value) {
                  if (_statoController.text == 'fallito' && (value == null || value.isEmpty)) {
                    return "La motivazione è obbligatoria per i progetti falliti!";
                  }
                  return null;
                },
              ),
              FutureBuilder(
                future: _oldTasks,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }else if(snapshot.hasError){
                    return const Text('Errore task progetti dal db');
                  }else{
                    List<Task>? oldTasks = snapshot.data ?? [];

                    return TaskApp(
                      oldTasks: oldTasks,
                      onTasksChanged: (newTasks) {
                        // Aggiungo le nuove task alla lista esistente di task
                        setState(() {
                          _tasks = newTasks;
                        });
                      }
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
  
  void _modificaProgetto() async {
    // se non è stato selezionato un team mostra un errore
    if (_teamController.text.isEmpty) {
      setState(() {
        _validaTeamText = 'Per favore, seleziona un team.';
      });
      return;
    }

    // errore se lo stato è completato ma le task non tutte completate
    if (_statoController.text == 'completato' && !_checkTaskCompletate()) {
      setState(() {
        _validaStatoText = 'Un progetto può essere completato solo se tutti i suoi tasks sono completati!';
      });
      return;
    }

    // nuovo nome del team inserito
    final nomeControllerProgetto = _nomeController.text.trim();

    // controllo che non esista già un Progetto con lo stesso nome nel db
    await DatabaseHelper.instance.selectProgettoByNome(nomeControllerProgetto)
      .then((progettoPresente) async {
        // se esiste già un progetto con lo stesso nome che non sia lo stesso progetto modificato
        if (progettoPresente != null && progettoPresente.nome != _nomeProgettoWhenModificato) {
          // il progetto NON può essere inserito nella tabella, mostro un messaggio di errore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserisci un nome del progetto non già usato!'))
          );
        } else {

          // salvo la modifica corrente del nome associato al progetto
          setState(() {
            _nomeProgettoWhenModificato = nomeControllerProgetto;
          });

          // salvo le stringhe necessarie per stato e completato
          String stato = (_statoController.text == 'completato'  ||  _statoController.text == 'fallito')
            ? 'archiviato' 
            : _statoController.text;

          bool? completato = _statoController.text == 'completato' 
            ? true // se lo stato è completato allora true
            : _statoController.text == 'fallito' 
              ? false // se è fallito allora false
              : null; // in tutti gli altri casi null

          // creo un nuovo progetto con i dati inseriti
          // che sarà usato per aggiornare i dati del progetto modificato
          Progetto modifiedProgetto = Progetto(
            nome: nomeControllerProgetto,
            team: _teamController.text,
            scadenza: _dateController.text,
            descrizione: _descrizioneController.text.trim(),
            stato: stato,
            completato: completato,
            motivazioneFallimento: completato == false ? _motivazioneController.text.trim() : null
          );

          // associa il progetto alle tasks
          for (var task in _tasks) {
            task.progetto = modifiedProgetto.nome;
          }

          final db = DatabaseHelper.instance;

          // aggiorno il progetto nel db
          // Prendo tutte le task associate precedentemente al progetto
          final oldTasks = await db.getTasksByProject(widget.projectName);
          if (oldTasks.isNotEmpty) {
            // elimino tutte le task associate precedentemente al progetto
            await Future.wait(oldTasks.map((oldTask) => db.deleteTask(oldTask)));
          }
          //a prescindere però da se ci sono task o meno si devono effettuare i seguenti passaggi:
          //Passo 1: aggiornare il progetto
          await db.updateProgetto(widget.projectName, modifiedProgetto);

          //Passo 2: aggiungere tutte le nuove/aggiornate task
          await Future.wait(_tasks.map((task) => db.insertTask(task)));

          //Passo 3: Scaffold che notifica del corretto aggiornamento
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Progetto modificato!')),
          );
        }

        setState(() {
         _validaStatoText = null;
        });
      }
    );
  }
  
  // metodo di utilità che restituisce true se tutte le task sono completate
  bool _checkTaskCompletate() {
    for (var task in _tasks) {
      if (task.completato == false) {
        return false;
      }
    }
    return true;
  }
}