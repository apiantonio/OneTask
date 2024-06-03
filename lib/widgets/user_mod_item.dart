import 'package:OneTask/model/utente.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Rappresenta una classe di utilità di appoggio per rappresentare i singoli utenti
class UserModItem extends StatefulWidget {
  final Utente utente;  
  final Function(Utente) onSelect;
  const UserModItem({super.key, required this.utente, required this.onSelect});

  @override
  UserModItemState createState() => UserModItemState();
}

class UserModItemState extends State<UserModItem> {
  bool isSelected = false; // Stato iniziale, nessun utente selezionato

  late Utente utente;
  late Function(Utente) onSelect;
  bool aggiunta = false;    //una variabile in cui salvo se l'aggiunta è andata a buon fine
  
  @override
  void initState(){
    super.initState();
    utente = widget.utente;
    onSelect = widget.onSelect;
  }

  @override
  Widget build(BuildContext context) {
    //viene restituito un listTile
    return ListTile(
      //azione quando premi sulla riga
      onTap: () { 
        setState(() {
          onSelect(utente);
        });
      },  
      //per arrotondare i bordi
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: const Color.fromARGB(255, 171, 197, 202),  
      //il testo di ogni singolo componente all'interno della lista di utenti - formato mat/cognome/nome
      title: Text(
        "${utente.matricola} ${utente.cognome} ${utente.nome}",
        style: GoogleFonts.inter(
          fontSize: 16,  
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

}