import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';

class UserItem extends StatelessWidget {
  final Utente utente;  
  const UserItem({Key? key, required this.utente});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {},   //azione quando premi sulla riga
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: Colors.blue.shade50,  //sfondo della riga
      title: Text(
        utente.matricola.toString() + " " + utente.cognome + " " + utente.nome,
      ),
    );
  }

}