import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';

//rappresenta una classe di utilità di appoggio per rappresentare i singoli utenti
class UserItem extends StatefulWidget {
  final Utente utente;  
  final Function(Utente) onSelect;
  final Function(Utente) onDeselect;
  const UserItem({super.key, required this.utente, required this.onSelect, required this.onDeselect});

  @override
  UserItemState createState() => UserItemState();
}

class UserItemState extends State<UserItem> {
  bool isSelected = false; // Stato iniziale, nessun utente selezionato

  late Utente utente;
  late Function(Utente) onSelect;
  late Function(Utente) onDeselect;
  bool aggiunta = false;    //una variabile in cui salvo se l'aggiunta è andata a buon fine
  
  @override
  void initState(){
    super.initState();
    utente = widget.utente;
    onSelect = widget.onSelect;
    onDeselect = widget.onDeselect;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //azione quando premi sulla riga
      onTap: () { 
        setState(() {
          isSelected = !isSelected; // Cambia lo stato di selezione quando viene premuto
          //in base al valore del booleano si decide quale metodo invocare (aggiunta/cancellazione)
          if(isSelected){
            aggiunta = onSelect(utente);
          }else{
            onDeselect(utente);
          }
        });
      },  
      //per arrotondare i bordi
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: (isSelected & aggiunta) ? Colors.pink : Colors.blue.shade50,  //la riga si colora solo se puoi ancora aggiungere
      //il testo di ogni singolo componente all'interno della lista di utenti - formato mat/cognome/nome
      title: Text(
        "${utente.matricola} ${utente.cognome} ${utente.nome}",
      ),
    );
  }

}