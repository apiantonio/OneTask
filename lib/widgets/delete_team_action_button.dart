import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/model/team.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// FloatingActionButton per l'eliminazione di un team
class DeleteTeamActionButton extends StatelessWidget {
  const DeleteTeamActionButton({
    super.key,
    required this.teamName,
  });

  final String teamName;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color.fromARGB(255, 217, 122, 54),
      child: const Icon(
        Icons.delete,
        color: Color(0XFFE8E5E0),
      ),
      onPressed: () async {
        List<Progetto>? checkProgetti = await DatabaseHelper.instance.selectProgettiByTeam(teamName);
        if (checkProgetti.isNotEmpty) {
          if (!context.mounted) return;
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Impossibile eliminare il Team!',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    color:const Color(0XFF0E4C56),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Non è possibile eliminare il team perché è associato a uno o più progetti.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                  )
                ),
                actions: [
                  TextButton(
                    child: Text(
                      'Ok',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0Xff167485),
                        fontWeight: FontWeight.w600,
                      )  
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          );
        } else {
          if (!context.mounted) return;
          bool? confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Conferma Eliminazione',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    color:const Color(0XFF0E4C56),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content:Text(
                  'Sei sicuro di voler eliminare questo Team?',
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
            }
          );
          if (confirmDelete == true) {
              Team? team = await DatabaseHelper.instance.selectTeamByNome(teamName);
              if (team != null) {
                await DatabaseHelper.instance.deleteTeam(team);
                if (!context.mounted) return;
                Navigator.of(context).pop(); // Torna alla schermata precedente
            }
          }
        }
      }
    );
  }
}

