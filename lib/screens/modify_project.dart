import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/task_item.dart';
import '../widgets/task_section.dart';

class ModifyProject extends StatelessWidget {
  final String projectName;

  const ModifyProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Modifica Progetto'),
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
  final TextEditingController _descrizioneController = TextEditingController();
  TextEditingController _motivazioneController = TextEditingController();
  String? _selectedTeam;
  String _selectedStato = 'attivo';
  String? _archivedStatus;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    Progetto? progetto =
        await DatabaseHelper.instance.selectProgettoByNome(widget.projectName);
    if (progetto != null) {
      List<Task> tasks =
          await DatabaseHelper.instance.getTasksByProject(widget.projectName);
      setState(() {
        _nomeController.text = progetto.nome;
        _descrizioneController.text = progetto.descrizione ?? '';
        _dateController.text = progetto.scadenza;
        _selectedTeam = progetto.team;
        _selectedStato = progetto.stato;
        _motivazioneController.text = progetto.motivazioneFallimento ?? '';
        _tasks = tasks;
        if (_selectedStato == 'archiviato') {
          _archivedStatus = progetto.motivazioneFallimento != null ? 'fallito' : 'finito';
        }
      });
    }
  }

  Future<List<String>> _getTeams() async {
    final teams = await DatabaseHelper.instance.getAllTeams();
    return teams.map((team) => team.nome).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _getTeams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore nel caricamento dei team'));
        } else {
          final teams = snapshot.data!;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateProgettoInDatabase();
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
                    DropdownButtonFormField<String>(
                      value: _selectedTeam,
                      items: teams.map((String team) {
                        return DropdownMenuItem<String>(
                          value: team,
                          child: Text(team),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTeam = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Seleziona un team',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per favore, seleziona un team.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedStato,
                      items: ['attivo', 'archiviato', 'sospeso']
                          .map((String stato) {
                        return DropdownMenuItem<String>(
                          value: stato,
                          child: Text(stato),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStato = newValue!;
                          if (_selectedStato != 'archiviato') {
                            _archivedStatus = null;
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Seleziona lo stato del progetto',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Per favore, seleziona uno stato.';
                        }
                        return null;
                      },
                    ),
                    if (_selectedStato == 'archiviato') ...[
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _archivedStatus,
                        items: ['fallito', 'finito'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _archivedStatus = newValue;
                          });
                        },
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'Seleziona il tipo di archiviazione',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Per favore, seleziona un tipo di archiviazione.';
                          }
                          return null;
                        },
                      ),
                      if (_archivedStatus == 'fallito') ...[
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _motivazioneController,
                          maxLength: 250,
                          maxLines: null,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Inserisci motivazione del fallimento...',
                          ),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'Cosa vuoi fare?',
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TaskApp(
                      onTasksChanged: (newTasks) {
                        // callback per ottenere le task inserite
                        setState(() {
                          _tasks = newTasks;
                        });
                      },
                    ),
                    Column(
                      children: _tasks.isNotEmpty
                          ? _tasks
                              .map((task) => Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: TaskItem(
                                      task: task,
                                      onChangeTask: (updatedTask) {
                                        setState(() {
                                          task.completato = !task.completato;
                                        });
                                      },
                                      onDeleteTask: (taskToDelete) {
                                        setState(() {
                                          _tasks.remove(taskToDelete);
                                        });
                                      },
                                    ),
                                  ))
                              .toList()
                          : [const Text('Nessun task disponibile')],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  void _updateProgettoInDatabase() async {
    Progetto? progettoPresente =
        await DatabaseHelper.instance.selectProgettoByNome(widget.projectName);

    bool? completato = progettoPresente?.completato;

    // Imposta il campo completato in base allo stato del progetto
    if (_selectedStato == 'archiviato') {
      completato = true;
    }

    Progetto updatedProgetto = Progetto(
      nome: _nomeController.text,
      team: _selectedTeam ?? '',
      scadenza: _dateController.text,
      stato: _selectedStato,
      descrizione: _descrizioneController.text,
      completato: completato, // Usa la variabile `completato` impostata sopra
      motivazioneFallimento: _archivedStatus == 'fallito' ? _motivazioneController.text : null,
    );

    if (progettoPresente != null && progettoPresente.nome != updatedProgetto.nome) {
      await DatabaseHelper.instance.deleteProgetto(progettoPresente);
    }

    await DatabaseHelper.instance.insertProgetto(updatedProgetto);

    // Associa il progetto alle tasks
    for (var task in _tasks) {
      task.progetto = updatedProgetto.nome;

      if (task.id != null) {
        // Aggiorna la task se ha un id (presumibilmente esiste già nel database)
        await DatabaseHelper.instance.updateTask(task, task);
      } else {
        // Inserisci la task se non ha un id
        await DatabaseHelper.instance.insertTask(task);
      }
    }

    setState(() {
      _tasks.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progetto aggiornato con successo!')),
    );
  }
}
