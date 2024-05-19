import 'package:OneTask/model/progetto.dart';
import 'package:flutter/material.dart';

class ProjectItem extends StatelessWidget {
  final Progetto project;  
  final viewSingleProject;
  final updateProject;
  const ProjectItem({super.key, required this.project, required this.viewSingleProject, required this.updateProject});

  @override
  Widget build(BuildContext context) {
    return ListTile(    //una sola riga della lista
        onTap: () {viewSingleProject(project);},   //azione quando premi sul team
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: Colors.blue.shade50,  //sfondo della riga
        title: Column(
          children: [
            Text(
              project.nome,
              softWrap: true,   //se non c'è abbastanza spazio manda a capo
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              'Team:${project.team}',
            ),

            Row(
              children: [
                //un container per la data di scadenza del progetto
                Container(
                  child: Row(
                    children: [
                      const Icon(   //icona dell'orologio
                        Icons.access_time,    
                      ),
                      Text(
                        project.scadenza,
                      )
                    ],
                  )
                ),
                //in basso a dx anche il bottone per modificare il progetto
                IconButton(   //icona a destra
                  iconSize: 16,
                  icon: const Icon(Icons.edit),
                  color: Colors.black,
                  onPressed: () {updateProject(project);},   //cosa fare quando premi sul bottone a destra
                )
              ]
            ),
          ]
        ),
        
        trailing: Icon(   //icona in alto a destra
          Icons.circle,
          color: _colorIcon(project.stato),    
        )
    );
  }

  //metodo per stabilire il colore del bottone
  Color _colorIcon(String state){
    Color color;
    switch(state){
      case 'sospeso' :
        color = Colors.orange;
        break;
      case 'archiviato' :
        color = Colors.red;
        break;
      default:
        color = Colors.green;
    }
    return color;
  }
}