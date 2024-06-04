//import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // Imposta il valore predefinito 'Home' come sezione selezionata del Drawer ad ogni avvio dell'app
  await prefs.setString('selectedTileDrawer', 'Home');
  runApp(const OTDashboard());
}

