import 'package:OneTask/screens/new_project.dart';
import 'package:OneTask/screens/new_team.dart';
import 'package:flutter/material.dart';

// questo widget rappresenta i due pulsanti floating della dashboard che 
// consentono di navigare alle pagine Nuovo team e Nuovo Progetto
class FloatingActionButtonsDashboard extends StatelessWidget {
  const FloatingActionButtonsDashboard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Builder(
          builder: (context) => FloatingActionButton(
            heroTag: 'unique_tag_2',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewTeam())
              );
            },
            tooltip: 'Nuovo team',
            child: const Icon(Icons.group),
          )
        ),
        const SizedBox(
          height: 10,
        ),
        Builder(
          builder: (context) => FloatingActionButton(
            /*questo herotag serve perchè abbiamo due floating nello stesso subtree e senza genera eccezione*/
            heroTag: 'unique_tag_1',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewProject())
              );
            },
            tooltip: 'Nuovo progetto',
            child: const Icon(Icons.create_new_folder),
          ),
        ),
      ],
    );
  }
}
