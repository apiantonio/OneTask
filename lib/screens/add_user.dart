import 'package:OneTask/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:OneTask/services/database_helper.dart'; 
import 'package:OneTask/widgets/add_user_form.dart';
import 'package:OneTask/widgets/appbar.dart';

/// Pagina per la creazione di un nuovo utente
class AddUser extends StatelessWidget {
  final dbHelper = DatabaseHelper.instance;

  AddUser({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0XFFE8E5E0),   //il colore di background di questa pagina
      appBar: OTAppBar(title: 'Nuovo Utente'),    //nell'appbar questo sarà il testo visualizzato
      drawer: OTDrawer(),
      body: SingleChildScrollView( // Permette allo schermo di scorrere se il form è troppo grande per lo schermo
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          child: AddUserForm(), // Aggiungo il widget addUserForm che rappresenta il form per aggiungere un nuovo utente
        ),
      ),
    );
  }
}
