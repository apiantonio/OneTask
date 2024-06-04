import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FloatingActionButton per l'eliminazione di un progetto
class DeleteProjectFloatingButton extends StatelessWidget {
  const DeleteProjectFloatingButton({
    super.key,
    required this.projectName,
  });

  final String projectName;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(255, 217, 122, 54),
      child: const Icon(
        Icons.delete,
        color: Color(0XFFE8E5E0),
      ),
      onPressed: () async {
        bool? confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Conferma Eliminazione',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: const Color(0XFF0E4C56),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'Sei sicuro di voler eliminare questo progetto?',
                style: GoogleFonts.inter(
                  fontSize: 15,
                )                  
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Annulla', 
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0Xff167485),
                      fontWeight: FontWeight.w600,
                    )  
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: Text(
                    'Elimina',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: const Color(0XFFEB701D),
                      fontWeight: FontWeight.w600,
                    )  
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );
        if (confirmDelete == true) {
          Progetto? progetto = await DatabaseHelper.instance.selectProgettoByNome(projectName);
          if (progetto != null) {
            await DatabaseHelper.instance.deleteProgetto(progetto.nome);
            Navigator.of(context).pop(); // Torna alla schermata precedente
          }
        }
      },
    );
  }
}
