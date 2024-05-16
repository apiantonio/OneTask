import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';

class UserItem extends StatefulWidget {
  final Utente utente;  
  final onSelect;
  final onDeselect;
  const UserItem({Key? key, required this.utente, required this.onSelect, required this.onDeselect});

  @override
  _UserItemState createState() => _UserItemState(utente: utente, onSelect: onSelect, onDeselect: onDeselect);
}

class _UserItemState extends State<UserItem> {
  bool isSelected = false; // Stato iniziale, nessun utente selezionato

  final Utente utente;
  final onSelect;
  final onDeselect;
  _UserItemState({required this.utente, required this.onSelect, required this.onDeselect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () { 
        setState(() {
          isSelected = !isSelected; // Cambia lo stato di selezione quando viene premuto
          isSelected ? onSelect(utente) : onDeselect(utente);
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