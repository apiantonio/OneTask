import 'package:flutter/material.dart';

//deve obbligatoriamente implementare PreferredSizedWidget altrimenti non potrei passarla allo Scaffold come appbar
class OTAppBar extends StatelessWidget implements PreferredSizeWidget{
  OTAppBar({Key? key, String? this.title}) : super(key: key);

  final String? title; // Parametro titolo che è opzionale

  //quando implementiamo PreferredSizeWidget mi serve questo override per stabilire l'alteza dell'appBar
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.lightBlue,
      title: Text(
        title ?? 'OneTask',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [      //gli passo un array di widget, in particolare di IconButton
        IconButton(
          onPressed: (() {
            //TODO
          }), 
          icon: Icon(Icons.search),
          tooltip: 'Cerca',
        ),

        IconButton(
          onPressed: (() {
            //TODOs
          }), 
          icon: Icon(Icons.notifications),
          tooltip: 'Vai alle notifiche',
        ),
      ],
    );
  }
}