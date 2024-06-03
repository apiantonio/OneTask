import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchTile extends StatelessWidget {
  final void Function() onTapElem; // funzione associata al tap sull'elemento della lista
  final void Function() onPressedModify; // funziona associata al tap sulla matita per modificare
  final Map<String, dynamic> result; // mappa passata dalla searchbar che contiene nome e tipo di un progetto o team

  const SearchTile({
    super.key,
    required this.onTapElem,
    required this.onPressedModify,
    required this.result
  });

  @override
  Widget build(BuildContext context) {
    // visualizza una T o una P se deve visualizzare rispettivamente un team o un progetto
    String simbolo = result['type'] == 'Team' ? 'T' : 'P';

    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),   //istruzione per consentire i bordi tondeggianti
      tileColor:const Color.fromARGB(255, 171, 197, 202),   //colore di sfondo del list Tile
      //subtitle: Text(result['type']),
      onTap: onTapElem,
      //nel container seguente abbiamo una P o una T a seconda che l'elemento 
      //sia rispettivamente progetto o team
      leading: Container(
        alignment: Alignment.center,
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color:Color.fromARGB(255, 237, 134, 60) ,
          shape: BoxShape.circle,
        ),
        child: Text(
          simbolo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      // contenuto del tile
      title: Text(
        result['nome'],
        softWrap: true,   // Se non c'è abbastanza spazio manda a capo
        style: GoogleFonts.inter(
          fontSize: 21,
          fontWeight: FontWeight.bold,
          color: const Color(0XFF0E4C56),
        ),
      ),
      // pulsante per la modifica, visibile solo se il progetto non è archiviato
      trailing: result['stato'] != 'archiviato' 
        ? IconButton(
            iconSize: 20,
            icon: const Icon(Icons.edit),
            color: const Color(0XFFEB701D),
            onPressed: onPressedModify,
          ) 
        : null  //altrimenti non viene visualizzato nulla
    );
  }
}
