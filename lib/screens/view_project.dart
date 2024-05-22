import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';

class ViewProject extends StatelessWidget {
  final String projectName;

  ViewProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(
        title: 'Visualizza Progetto',
      ),
      body: ProjectDetails(projectName: projectName),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.delete),
        onPressed: () async {
          bool? confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Conferma Eliminazione'),
                content: const Text(
                    'Sei sicuro di voler eliminare questo progetto?'),
                actions: [
                  TextButton(
                    child: const Text('Annulla'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text('Elimina'),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                ],
              );
            },
          );
          if (confirmDelete == true) {
            Progetto? progetto =
                await DatabaseHelper.instance.selectProgettoByNome(projectName);
            if (progetto != null) {
              await DatabaseHelper.instance.deleteProgetto(progetto);
              Navigator.of(context).pop(); // Torna alla schermata precedente
            }
          }
        },
      ),
    );
  }
}

class ProjectDetails extends StatefulWidget {
  final String projectName;

  ProjectDetails({super.key, required this.projectName});

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  late Future<Progetto?> _futureProgetto;
  late Future<List<Task>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _futureProgetto =
        DatabaseHelper.instance.selectProgettoByNome(widget.projectName);
    _futureTasks =
        DatabaseHelper.instance.getTasksByProject(widget.projectName);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: FutureBuilder<Progetto?>(
        future: _futureProgetto,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Errore caricamento infoProgetto dal db');
          } else {
            Progetto? progetto = snapshot.data;
            if (progetto != null) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(progetto.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 20),
                  Text('Stato: ${progetto.stato}',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  Text('Scadenza: ${progetto.scadenza}',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  Text('Descrizione: ${progetto.descrizione}',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  Text('Team: ${progetto.team}',
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 20),
                  const Text('I tuoi tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  FutureBuilder<List<Task>>(
                    future: _futureTasks,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text(
                            'Errore caricamento tasks del progetto dal db');
                      } else {
                        List<Task> tasks = snapshot.data ?? [];
                        return Column(
                          children: tasks.map((task) {
                            return TaskItem(
                              task: task,
                              onChanged: (bool? value) {
                                setState(() {
                                  task.completato = value ?? false;
                                  DatabaseHelper.instance
                                      .updateTaskVecchio(task);
                                });
                              },
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              );
            } else {
              return const Text('Progetto non trovato');
            }
          }
        },
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;

  TaskItem({required this.task, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(task.attivita),
      value: task.completato,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
