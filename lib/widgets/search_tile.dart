import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final VoidCallback onTapElem; // funzione associata al tap sull'elemento della lista
  final VoidCallback onPressedModify; // funziona associata al tap sulla matita per modificare
  final Map<String, dynamic> result; // mappa passata dalla searchbar che contiene nome e tipo di un progetto o team

  SearchTile({
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: Colors.blue.shade100,
      //subtitle: Text(result['type']),
      onTap: onTapElem,
      // conentuo del tile
      title: Padding( 
        padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
        // tutto il contenuto è costitutio dal simbolo, il nome del team/progetto, l'icoa di una matita
        // tutto è contenuto in una riga, all'interno di questa è resente una riga ed un'iconButto per la modifica
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // riga interna
            Row(
              children: [
                // questo container rappresenta il cerchio che contiene il simbolo T o P
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 1, vertical: 3),
                  alignment: Alignment.center,
                  width: 28, // Larghezza del container
                  height: 28, // Altezza del container
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(14), // arrotondo i bordi per ottenere un cerchio
                  ),
                  // all'interno del cerchio inserisco il simbolo
                  child: Text(
                    simbolo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 22), // spazio tra l'icona e il nome
                // testo per il nome del progetto/team
                Text(
                  result['nome'],
                  softWrap: true,   // Se non c'è abbastanza spazio manda a capo
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            // pulsante per la modifica
            IconButton(
              iconSize: 20,
              icon: const Icon(Icons.edit),
              color: Colors.black,
              onPressed: onPressedModify,
            ),
          ],
        ),
      ),
    );
  }
}
