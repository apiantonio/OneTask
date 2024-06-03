import 'package:OneTask/widgets/searchbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Questo widget rappresengta l'appabar dell'applicazione
/// deve obbligatoriamente implementare PreferredSizedWidget altrimenti non si potrebbe passare allo Scaffold come appbar
class OTAppBar extends StatefulWidget implements PreferredSizeWidget{
  //di default se non passato tabbar non viene visualizzata
  const OTAppBar(
    {super.key,
    this.title, // Titolo da inserire nella appbar
    this.withTabbar = false, // flag per indicare se mostrare o meno la TabBar
    this.tabController, // TabController se presente mostra un tabController
    this.withSearchbar = true, // flag che indica se mostrare o meno la searchabr
    this.sourcePage, // stringa che indica lapagina in cui è applicat l'appbar
  });

  final String? title; // Parametro titolo che è opzionale
  final bool withTabbar; // il parametro passato risulta opzionale, serve per capire se serva o meno il tabbar per quella schermata
  final TabController? tabController;
  final bool withSearchbar; 
  final String? sourcePage;

  @override
  State<OTAppBar> createState() => _OTAppBarState();
  
  // override necessario per PreferredSizeWidget
  @override
  Size get preferredSize => Size.fromHeight(withTabbar ? 120 : 56); 
}

class _OTAppBarState extends State<OTAppBar> {

  //quando implementiamo PreferredSizeWidget mi serve questo override per stabilire l'alteza dell'appBar
  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(
        color: Color(0XFFEB701D), // Colore dell'icona dell'hamburger
        size: 35, 
      ),
      backgroundColor: const Color(0Xff167485),   //rappresenta il colore di sfondo dell'appbar
      title: Text(
        widget.title ?? 'OneTask',   //il titolo sarà pari a OneTask o a quanto passato dalle pagine che la richiamano
        //per settare lo stile utilizziamo un google font opportunamente importato come package
        style: GoogleFonts.inter(
          fontSize: 25, 
          fontWeight: FontWeight.bold,    //per lo spessore del testo
          color: const Color(0XFFEFECE9),   //del colore OX sono obbligatorie, FF indica l'opacità
        ),
      ),
      actions: [  //gli passo un array di widget, in particolare di IconButton
        if (widget.withSearchbar) 
          IconButton(
            onPressed: (() {
              // metodo che mostra la barra di ricerca
              showSearch(
                context: context, 
                // delega la costruzione ad un widget figlio
                delegate: SearchBarDelegate(sourcePage: widget.sourcePage)
              );
            }), 
            icon: const Icon(Icons.search),
            tooltip: 'Cerca',   //il tooltip viene visualizzato solo se si apre l'app su browser
          )
      ],
      //aggiunge ai piedi dell'appbar il tabbar solo se il booleano tabbar è true
      bottom: widget.withTabbar
        ? TabBar(
            controller: widget.tabController,
            dividerColor: Colors.transparent,     //non c'è alcuna divisione tra i due tabs
            labelColor: const Color(0XFFEFECE9),    //rappresenta il colore del testo selezionato
            unselectedLabelColor: const Color(0XFFEFECE9).withOpacity(0.5),   //rappresenta il colore del testo non selezionato
            tabs: [
              Tab(icon: Icon(Icons.assignment, color:const Color(0XFFEFECE9).withOpacity(0.8)), text: 'I miei progetti'),
              Tab(icon: Icon(Icons.people, color:const Color(0XFFEFECE9).withOpacity(0.8)), text: 'I miei team'),
            ]
          ) 
        : null,
    );
  }
}