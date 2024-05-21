import 'package:flutter/material.dart';

class SearchTile extends StatelessWidget {
  final VoidCallback onTapElem; // funzione associata al tap sull'elemento della lista
  final VoidCallback onPressedModify; // funziona associata al tap sulla matita per modificare
  final Map<String, dynamic> result;
  
  SearchTile({super.key, required this.onTapElem, required this.onPressedModify, required this.result});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: Colors.blue.shade100,
      subtitle: Text(result['type']),
      onTap: onTapElem,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              result['name'],
              softWrap: true,   //se non c'è abbastanza spazio manda a capo
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              iconSize: 16,
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