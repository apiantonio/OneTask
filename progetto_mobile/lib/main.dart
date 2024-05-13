import 'package:flutter/material.dart';
import 'package:test_db_sqlite/screens/new_project.dart';
import './widgets/appbar.dart';
import './widgets/drawer.dart';

void main() {
  runApp(const OTDashboard());  
}

class OTDashboard extends StatelessWidget {
  const OTDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Dashboard';

    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false, //così non si vede la striscia in alto a dx di debug
      home: Scaffold(
        appBar: OTAppBar(),
        drawer: OTDrawer(),
        body: Column(
          children: [
            Builder(
              builder: (context) => FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const NewProject()));
                },
                child: const Icon(Icons.create_new_folder),
                tooltip: 'Nuovo progetto',
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                /*da fare per la pagina nuovo team*/
              },
              child: const Icon(Icons.group),
              tooltip: 'Nuovo team',
            )
          ],
        ),
      ),
    );
  }
}