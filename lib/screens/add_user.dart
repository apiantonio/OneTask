import 'package:OneTask/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:OneTask/services/database_helper.dart'; 
import 'package:OneTask/widgets/add_user_form.dart';
import 'package:OneTask/widgets/appbar.dart';

class AddUser extends StatelessWidget {
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: OTAppBar(title: 'Nuovo Utente'),
        drawer: OTDrawer(),
        body: SingleChildScrollView( // Permette allo schermo di scorrere se il form è troppo grande per lo schermo
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Aggiungo il widget addUserForm che rappresenta il form per aggiungere un nuovo utente
                AddUserForm(), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
