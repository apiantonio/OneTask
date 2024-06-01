import 'package:OneTask/screens/new_project.dart';
import 'package:OneTask/screens/new_team.dart';
import 'package:flutter/material.dart';

// questo widget rappresenta i due pulsanti floating della dashboard che 
// consentono di navigare alle pagine Nuovo team e Nuovo Progetto
class FloatingActionButtonsDashboard extends StatelessWidget {
  const FloatingActionButtonsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    //entrambi i pulsanti sono visibili nella dashboard, 
    //utilizziamo un widget Column per visualizzarli l'uno sopra l'altro
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        //si è deciso di rendere la dimensione del bottone che consente di aggiungere un team
        //inferiore rispetto a quello per creare un progetto data la primaria importanza di quest'ultimo
        Builder(
          builder: (context) => FloatingActionButton.small(
            backgroundColor: const Color(0XFF0E4C56),     //colore di sfondo del bottone
            heroTag: 'unique_tag_2',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewTeam())
              );
            },
            tooltip: 'Nuovo team',    //il tooltip risulta visibile solo dal browser
            child: const Icon(
              Icons.group, 
              size: 20,
              color: Color(0XFFEFECE9),   //per cambiare colore all'icona
            ),
          )
        ),
        const SizedBox(
          height: 10,
        ),
        Builder(
          builder: (context) => FloatingActionButton(
            //questo herotag serve perchè abbiamo due floating nello stesso subtree e senza genera eccezione
            heroTag: 'unique_tag_1',
            backgroundColor: const Color(0Xff167485),  //colore di sfondo, si è deciso di usare due colori diversi per differenziare anche visivamente i due bottoni
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewProject())
              );
            },
            tooltip: 'Nuovo progetto',
            child: const Icon(
              Icons.create_new_folder,
              size: 25,
              color: Color(0XFFEFECE9),   //per cambiare colore all'icona
            ),
          ),
        ),
      ],
    );
  }
}
