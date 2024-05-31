import 'package:OneTask/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  Size get preferredSize => Size.fromHeight(tabbar ? 120 : 56); //l'altezza dell'appbar cambia a seconda che ci sia o meno la tabbar

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Color(0XFFEB701D), // Colore dell'icona dell'hamburger
        size: 35, 
      ),
      backgroundColor: const Color(0Xff167485),   //rappresenta il colore di sfondo dell'appbar
      title: Text(
        title ?? 'OneTask',   //il titolo sarà pari a OneTask o a quanto passato dalle pagine che la richiamano
        //per settare lo stile utilizziamo un google font opportunamente importato come package
        style: GoogleFonts.inter(
          fontSize: 25, 
          fontWeight: FontWeight.bold,    //per lo spessore del testo
          color: const Color(0XFFEFECE9),   //del colore OX sono obbligatorie, FF indica l'opacità
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
          tooltip: 'Cerca',   //il tooltip viene visualizzato solo se si apre l'app su browser
        ),
      ],
      //aggiunge ai piedi dell'appbar il tabbar solo se il booleano tabbar è true
      bottom: tabbar ? TabBar(
        controller: controller,
        dividerColor: Colors.transparent,     //non c'è alcuna divisione tra i due tabs
        labelColor: const Color(0XFFEFECE9),    //rappresenta il colore del testo selezionato
        unselectedLabelColor: const Color(0XFFEFECE9).withOpacity(0.5),   //rappresenta il colore del testo non selezionato
        tabs: [
          Tab(icon: Icon(Icons.assignment, color:const Color(0XFFEFECE9).withOpacity(0.8)), text: 'I miei progetti'),
          Tab(icon: Icon(Icons.people, color:const Color(0XFFEFECE9).withOpacity(0.8)), text: 'I miei team'),
        ]
      ) : null,
    );
  }
}