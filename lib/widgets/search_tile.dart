import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final VoidCallback onTapElem; // funzione associata al tap sull'elemento della lista
  final VoidCallback onPressedModify; // funziona associata al tap sulla matita per modificare
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: Colors.blue.shade100,
      //subtitle: Text(result['type']),
      onTap: onTapElem,
      leading: Container(
        alignment: Alignment.center,
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.blue,
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
      // conentuo del tile
      title: Text(
        result['nome'],
        softWrap: true,   // Se non c'è abbastanza spazio manda a capo
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // pulsante per la modifica
      trailing: IconButton(
        iconSize: 20,
        icon: const Icon(Icons.edit),
        color: Colors.black,
        onPressed: onPressedModify,
      ),
    );
  }
}
