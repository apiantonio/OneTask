import 'package:OneTask/model/progetto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProjectItem extends StatelessWidget {
  final Progetto project;  
  final void Function(Progetto) viewSingleProject;
  final void Function(Progetto) updateProject;
  
  const ProjectItem({
    super.key, 
    required this.project,
    required this.viewSingleProject, 
    required this.updateProject
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(    //una sola riga della lista
        onTap: () {viewSingleProject(project);},   //azione quando premi sul team
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        tileColor: const Color(0XFFEFECE9),  //sfondo della riga
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
                          style: GoogleFonts.inter(
                            fontSize: 23,
                            color: const Color(0XFF0E4C56),   //del colore OX sono obbligatorie, FF indica l'opacità
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3,),
                        Text(
                          'Team: ${project.team}',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                          ),
                        ),
                      ]
                    ),
                  ),
                  //si tratta di un'icona, visualizzata in alto a destra, il cui colore simboleggia lo stato del progetto
                  Icon(   
                    Icons.circle,
                    color: _colorIcon(project.stato),   
                    size: 35, 
                  )
                ]
              ),
              const SizedBox(height: 5,),
              //la seconda riga invece presenta sulla sinistra la data di scadenza del progetto, 
              //a destra l'icona per consentirne la modifica
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //un container per la data di scadenza del progetto
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: const Color(0XFFDDD7D1), // Colore di sfondo
                      border: Border.all(
                        color: const Color(0Xff167485), // Colore del bordo
                        width: 1.0, // settare la larghezza del bordo
                      ),
                      borderRadius: BorderRadius.circular(30.0), //per arrotondare i bordi
                    ),
                    //all'interno del container abbiamo a sx l'icona del calendario e a dx la data di scadenza
                    child: Row(
                      children: [
                        const Icon(   //icona dell'orologio
                          Icons.calendar_today, 
                          color: Color(0Xff167485),  
                          size: 15,
                        ),
                        Text(
                          project.scadenza,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                          ),
                        )
                      ],
                    )
                  ),
                  //se il progetto non è stato archiviato allora sarà presente il bottone per la modifica
                  project.completato == null ?
                    //in basso a dx anche il bottone per modificare il progetto
                    IconButton(   
                      iconSize: 20,
                      icon: const Icon(Icons.edit),
                      color: const Color(0XFFEB701D),
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

  //metodo per stabilire il colore del bottone sulla base dello stato del progetto
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