import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import './screens/new_project.dart';
import './widgets/appbar.dart';
import './widgets/drawer.dart';
import './screens/new_team.dart';


void main() async {
  runApp(const OTDashboard()); 
  DatabaseHelper.instance.populateDatabase(); 
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
        // body: TODO
        floatingActionButton: Column(
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
        ),
      ),
    );
  }
}