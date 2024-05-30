import 'package:OneTask/widgets/searchbar.dart';
import 'package:flutter/material.dart';

//deve obbligatoriamente implementare PreferredSizedWidget altrimenti non potrei passarla allo Scaffold come appbar
class OTAppBar extends StatelessWidget implements PreferredSizeWidget{
  //di default se non passato tabbar non viene visualizzata
  const OTAppBar({super.key, this.title, this.tabbar = false, this.controller});

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
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [      //gli passo un array di widget, in particolare di IconButton
        IconButton(
          onPressed: (() {
            // metodo che mostra la barra di ricerca
            showSearch(
              context: context, 
              // delega la costruzione ad un widget figlio
              delegate: SearchBarDelegate()
            );
          }), 
          icon: const Icon(Icons.search),
          tooltip: 'Cerca',
        ),

        IconButton(
          onPressed: (() {
            //TODOs
          }), 
          icon: const Icon(Icons.notifications),
          tooltip: 'Vai alle notifiche',
        ),
      ],
      bottom: tabbar ? TabBar(
        controller: controller,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.assignment), text: 'I miei progetti'),
          Tab(icon: Icon(Icons.people), text: 'I miei team'),
        ]
      ) : null,
    );
  }
}