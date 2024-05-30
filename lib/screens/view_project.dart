import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/task.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
class ViewProject extends StatelessWidget {
  final String projectName;

  const ViewProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(
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
                content: const Text('Sei sicuro di voler eliminare questo progetto?'),
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
              await DatabaseHelper.instance.deleteProgetto(progetto.nome);
              Navigator.of(context).pop(); // Torna alla schermata precedente
            }
          }
        },
      ),
    );
  }
}

class ProjectDetails extends StatelessWidget {
  final String projectName;

  const ProjectDetails({super.key, required this.projectName});
  
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: FutureBuilder<ProjectElements>(
        future: _fetchProjectDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Errore caricamento infoProgetto dal db');
          } else {
            //sono sicuro che mi restituisca qualcosa
            ProjectElements dataProj = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dataProj.progetto.nome,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 20),
                (dataProj.progetto.stato == 'archiviato' && dataProj.progetto.motivazioneFallimento == null) ?
                  const Text('Stato: completato',
                    style: TextStyle(fontSize: 15))
                : (dataProj.progetto.stato == 'archiviato' && dataProj.progetto.motivazioneFallimento != null) ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Stato: fallito',
                        style: TextStyle(fontSize: 15)),
                      const SizedBox(height: 20),
                      Text('Causa fallimento: ${dataProj.progetto.motivazioneFallimento}',
                        style: const TextStyle(fontSize: 15))
                    ]
                  )
                : Text('Stato: ${dataProj.progetto.stato}',
                    style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 20),
                Text('Scadenza: ${dataProj.progetto.scadenza}',
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                Text('Descrizione: ${dataProj.progetto.descrizione}',
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                Text('Team: ${dataProj.progetto.team}',
                    style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 20),
                const Text('I tuoi tasks',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                dataProj.tasks == null ? const Text('Non ci sono tasks associati al progetto')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: dataProj.tasks!
                      .map((task) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: _checkboxIcon(task),
                        title: Text(task.attivita),
                        )
                      ).toList(),
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Future<ProjectElements> _fetchProjectDetails() async{
    final db = DatabaseHelper.instance;
    final progetto = await db.selectProgettoByNome(projectName);
    final tasksProg = await db.getTasksByProject(projectName);
    if(progetto == null) {
      //è una condizione che non dovrebbe (come regola) mai accadere. Io se clicco su un progetto
      //dalla schermata progetti e team significa che quantomeno deve esistere - non vale lo stesso per i tasks
      throw Exception("Errore visualizzazione progetto: il progetto non esiste");
    } else {
      return ProjectElements(progetto: progetto, tasks: tasksProg);
    }
  }

  Icon _checkboxIcon(Task task){
    return task.completato ? const Icon(Icons.check_box) : const Icon(Icons.check_box_outline_blank);
  }
}

//classe di utilità utilizzata per salvare sia i dettagli relativi al progetto che i task associati
//post estrazione dal db
class ProjectElements {
  final Progetto progetto;
  final List<Task>? tasks;

  ProjectElements({required this.progetto, required this.tasks});
}

