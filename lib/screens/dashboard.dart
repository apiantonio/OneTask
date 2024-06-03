import 'package:OneTask/screens/dashboard_view.dart';
import 'package:OneTask/widgets/appbar.dart';
import 'package:OneTask/widgets/drawer.dart';
import 'package:OneTask/widgets/floating_buttons_dashboard.dart';
import 'package:flutter/material.dart';

/// Pagina che rappresenta la dashboard dell'applicazione
class OTDashboard extends StatelessWidget {
  const OTDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Dashboard';

    return const MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false, //così non si vede la striscia in alto a dx di debug
      home: Scaffold(
        appBar: OTAppBar(sourcePage: 'Dashboard'), // appbar dell'app OneTask
        drawer: OTDrawer(), // drawer dell'app
        body: DashboardView(), // view della dashboard
        backgroundColor: Color(0XFFE8E5E0),
        floatingActionButton: FloatingActionButtonsDashboard(), // pulsanti floating per nuovo team e nuovo progetto
      ),
    );
  }
}
