//import 'package:OneTask/services/database_helper.dart';
import 'package:OneTask/widgets/floating_buttons_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './widgets/appbar.dart';
import './widgets/drawer.dart';
import 'screens/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Imposta il valore predefinito 'Home' come sezione selezionata del Drawer ad ogni avvio dell'app
  await prefs.setString('selectedTileDrawer', 'Home');
  runApp(const OTDashboard());
  //DatabaseHelper.instance.populateDatabase();
}

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
