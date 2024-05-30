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
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          //mu serve column perchè padding accetta solo un figlio
          child: Column(
            children: [
              //la prima riga contiene a sx NomeProgetto (top) e team che se ne occupa (bottom)
              //stato del progetto a dx
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          'Team: ${project.team}',
                        ),
                      ]
                    ),
                  ),
                  Icon(   //icona in alto a destra
                    Icons.circle,
                    color: _colorIcon(project.stato),   
                    size: 35, 
                  )
                ]
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //un container per la data di scadenza del progetto
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white, // Colore di sfondo
                      border: Border.all(
                        color: Colors.grey, // Colore del bordo
                        width: 1.0, // settare la larghezza del bordo
                      ),
                      borderRadius: BorderRadius.circular(30.0), //per arrotondare i bordi
                    ),
                    child: Row(
                      children: [
                        const Icon(   //icona dell'orologio
                          Icons.access_time,    
                        ),
                        Text(
                          project.scadenza,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        )
                      ],
                    )
                  ),
                  project.completato == null ?
                    //in basso a dx anche il bottone per modificare il progetto
                    IconButton(   //icona a destra
                      iconSize: 16,
                      icon: const Icon(Icons.edit),
                      color: Colors.black,
                      onPressed: () {updateProject(project);},   //cosa fare quando premi sul bottone a destra
                    )
                  : const SizedBox()
                ]
              ),
            ]
          ),
        ),
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