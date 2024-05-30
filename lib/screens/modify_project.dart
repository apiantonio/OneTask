import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import '../model/team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/task_section.dart';

class ModifyProject extends StatelessWidget {
  final String projectName;

  const ModifyProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Modifica Progetto'),
      body: EditProjectForm(projectName: projectName),
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
      _tasks = await DatabaseHelper.instance.getTasksByProject(widget.projectName) ?? [];

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
    // if (!_isDataLoaded) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    
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
                  child: const Text('Aggiorna progetto'),
                ),
                TextFormField(
                  controller: _nomeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Per favore, inserisci un nome al progetto.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Inserisci il nome del progetto',
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descrizioneController,
                  maxLength: 250,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Inserisci descrizione del progetto...',
                  ),
                ),
                const SizedBox(height: 20),
                //DropDownMenu per selezionare i team scelti da db o file json
                DropdownMenu(
                  enableFilter: true, // permette di cercare il nome del team e di filtrarli in base a ciò che è scritto
                  enabled: _nomiTeams.isNotEmpty, // il menù è disattivato se non ci sono team nel b
                  leadingIcon:
                      const Icon(Icons.people), // icoa a sinistra del testo
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
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: TextFormField(
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
                      prefixIcon: Icon(Icons.calendar_today),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Stato del progetto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _statoController.text,
                  onSelected: (String value) => {
                    setState(() {
                      _statoController.text = value;
                      _validaStatoText = null; 
                    })
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: ListTile(
                      title: Text(_statoController.text),
                      trailing: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  itemBuilder: (BuildContext context) {
                    List<PopupMenuEntry<String>> tendina = [];
                    for (var stato in _stato) {
                      tendina.add(
                        PopupMenuItem<String>(
                          value: stato,
                          child: Text(stato, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    }
                    return tendina;
                  }
                ),
                if (_validaStatoText != null) // se non è selezionato un team mostra testo di errore
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _validaStatoText!,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _motivazioneController,
                  enabled: _statoController.text == 'fallito' ? true : false,
                  maxLength: 50,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Inserisci motivazione del fallimento...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "La motivazione è obbligatoria per i progetti falliti!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Cosa vuoi fare?',
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
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

    // controllo che non esista già un Progetto con lo stesso nome nel db
    await DatabaseHelper.instance
    .selectProgettoByNome(_nomeController.text)
    .then((progettoPresente) async {
      // se esiste già un progetto con lo stesso nome che non sia lo stesso progetto modificato
      if (progettoPresente?.nome != _nomeProgettoWhenModificato && progettoPresente != null) {
        // il progetto NON può essere inserito nella tabella, mostro un messaggio di errore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inserisci un nome del progetto non già usato!')));
      } else {

        // salvo la modifica corrente del nome associato al progetto
        setState(() {
          _nomeProgettoWhenModificato = _nomeController.text;
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
          nome: _nomeController.text,
          team: _teamController.text,
          scadenza: _dateController.text,
          descrizione: _descrizioneController.text,
          stato: stato,
          completato: completato,
          motivazioneFallimento: completato == false ? _motivazioneController.text : null
        );

        // associa il progetto alle tasks
        for (var task in _tasks) {
          task.progetto = modifiedProgetto.nome;
        }

        final db = DatabaseHelper.instance;

        // aggiorno il progetto nel db
        // prima elimino tutte le task associate precedentemente al progetto
        db.getTasksByProject(widget.projectName)
        .then((oldTasks) {
          if (oldTasks != null) {
            Future.wait(oldTasks.map((oldTask) => db.deleteTask(oldTask)))
            .whenComplete(() {
              // aggiorno il progetto   
              db.updateProgetto(widget.projectName, modifiedProgetto)
              .whenComplete(() {
                // infine aggiungo tutte le nuove/aggiornate task
                Future.wait(_tasks.map((task) => db.insertTask(task)))
                .whenComplete(() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progetto modificato!')),
                  );
                });
              });
            });
          }
        });

      }
    });

  }
}