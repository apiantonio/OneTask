import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/task_section.dart';

class ViewProject extends StatelessWidget {
  final String projectName;

  const ViewProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(
        title: 'Visualizza Progetto',
      ),
      body: ProjectDetails(projectName: projectName),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.delete),
        onPressed: () async {
          bool? confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Conferma Eliminazione'),
                content: Text('Sei sicuro di voler eliminare questo progetto?'),
                actions: [
                  TextButton(
                    child: Text('Annulla'),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: Text('Elimina'),
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

  const ProjectDetails({super.key, required this.projectName});

  @override
  ProjectDetailsState createState() {
    return ProjectDetailsState();
  }
}

class ProjectDetailsState extends State<ProjectDetails> {
  Progetto? _progetto;
  List<Task>? _tasks;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    Progetto? progetto =
        await DatabaseHelper.instance.selectProgettoByNome(widget.projectName);
    List<Task>? tasks =
        await DatabaseHelper.instance.getTasksByProject(widget.projectName);
    setState(() {
      _progetto = progetto;
      _tasks = tasks;
    });
  }

//perchè non funfa?
  Future<void> _updateTaskCompletion(Task task, bool? value) async {
    if (value != null) {
      task.completato = value;
      await DatabaseHelper.instance.updateTask(task);
      setState(() {
        // Aggiorna la UI
      });
    }
  }

//da valure se va bene
  Color _getProjectStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sospeso':
        return Colors.orange;
      case 'archiviato':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_progetto == null || _tasks == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _progetto!.nome,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.circle,
                color: _getProjectStatusColor(_progetto!.stato),
                size: 12,
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Descrizione: ${_progetto!.descrizione}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Team: ${_progetto!.team}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            'Scadenza: ${_progetto!.scadenza}',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Text(
            'Tasks:',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ..._tasks!.map((task) {
            return CheckboxListTile(
              title: Text(task.attivita),
              value: task.completato,
              onChanged: (bool? value) {
                _updateTaskCompletion(task, value);
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}
