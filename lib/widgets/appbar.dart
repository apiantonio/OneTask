import 'package:flutter/material.dart';

//deve obbligatoriamente implementare PreferredSizedWidget altrimenti non potrei passarla allo Scaffold come appbar
class OTAppBar extends StatelessWidget implements PreferredSizeWidget{
  //di default se non passato tabbar non viene visualizzata
  OTAppBar({Key? key, String? this.title, this.tabbar = false, TabController? this.controller}) : super(key: key);

  final String? title; // Parametro titolo che è opzionale
  //il parametro passato risulta opzionale, serve per capire se serva o meno il tabbar per quella schermata
  final bool tabbar;
  final TabController? controller;
  //quando implementiamo PreferredSizeWidget mi serve questo override per stabilire l'alteza dell'appBar
  @override
  Size get preferredSize => Size.fromHeight(tabbar ? 120 : 56);

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
      bottom: tabbar ? TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(icon: Icon(Icons.assignment), text: 'I miei progetti'),
          Tab(icon: Icon(Icons.people), text: 'I miei team'),
        ]
      ) : null,
    );
  }
}