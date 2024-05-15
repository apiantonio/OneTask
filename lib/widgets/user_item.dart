import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';

class UserItem extends StatefulWidget {
  final Utente utente;  
  const UserItem({Key? key, required this.utente});

  @override
  _UserItemState createState() => _UserItemState(utente: utente);
}

class _UserItemState extends State<UserItem> {
  bool isSelected = false; // Stato di selezione

  final Utente utente;
  _UserItemState({required this.utente});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () { 
        setState(() {
          isSelected = !isSelected; // Cambia lo stato di selezione quando viene premuto
        });
      },   //azione quando premi sulla riga
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: isSelected ? Colors.pink : Colors.blue.shade50,  //sfondo della riga
      title: Text(
        utente.matricola.toString() + " " + utente.cognome + " " + utente.nome,
      ),
    );
  }

}