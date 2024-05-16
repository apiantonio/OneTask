import 'package:flutter/material.dart';
import 'package:OneTask/model/progetto.dart';
import '../widgets/appbar.dart'; // Assicurati di importare la tua appbar personalizzata

class ViewProject extends StatelessWidget {
  final Progetto progetto;

  const ViewProject({super.key, required this.progetto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Visualizza Progetto'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                progetto.nome,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Descrizione:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                progetto.descrizione,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Team:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                progetto
                    .team, // Assumendo che 'team' sia una stringa, altrimenti aggiusta di conseguenza
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Scadenza:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                progetto.scadenza,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Aggiungi ulteriori campi se necessario
              ElevatedButton(
                onPressed: () {
                  // Naviga alla schermata di modifica
                  Navigator.pushNamed(
                    context,
                    '/editProject',
                    arguments: progetto,
                  );
                },
                child: Text('Modifica Progetto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
