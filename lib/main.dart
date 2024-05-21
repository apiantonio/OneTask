//import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/floating_buttons_dashboard.dart';
import 'package:flutter/material.dart';
import './widgets/appbar.dart';
import './widgets/drawer.dart';

void main() async {
  runApp(const OTDashboard());
  //DatabaseHelper.instance.populateDatabase();
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
        floatingActionButton: const FloatingActionButtonsDashboard(), // pulsanti floating per nuovo team e nuovo progetto
      ),
    );
  }
}
