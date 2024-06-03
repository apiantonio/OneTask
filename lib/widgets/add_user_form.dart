import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_helper.dart';
import 'package:OneTask/model/utente.dart';

/// Questo widget rappresenterà il form per l'inserimento di un nuovo utente
class AddUserForm extends StatefulWidget{
  const AddUserForm({super.key});

  @override
  AddUserFormState createState() => AddUserFormState();
}

class AddUserFormState extends State<AddUserForm> {
  // chiave identificativa del form utile per la validazione
  final _formKey = GlobalKey<FormState>();
  
  // controller devi vari campi del form
  final TextEditingController _matricolaController = TextEditingController();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _cognomeController = TextEditingController();
  // regex per controllare la validità del nome/cognome inserito
  // possono contenere solo lettere e apostrofi
  final RegExp nomCognomeRegex = RegExp(r"^[a-zA-ZàèéìòùÀÈÉÌÒÙ' ]+$");

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        // padding a tutti gli elementi del form
        padding: const EdgeInsets.all(16), 
        // i vari elementi saranno in colonna
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // textfield per il nome
            TextFormField(
              controller: _nomeController,
              // aggiugno dello stile
              decoration: InputDecoration(
                // aggiungo il bordo al campo di testo
                border: const OutlineInputBorder(),
                //i 3 bordi a seguire sono necessari per settare lo stile normalmente, se selezionato e in caso di errore
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0Xff167485), width: 1.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                ),
                // icona interna al box di testi
                prefixIcon: const Icon(Icons.person, color: Color(0XFF0E4C56)),
                hintText: 'Inserisci nome utente',
                labelText: 'Nome',
                //serve a settare lo stile del label
                labelStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color:Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                    fontWeight: FontWeight.w400,
                ),
                // imposta una dimensione al box di testo
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci un nome';
                } else if (!nomCognomeRegex.hasMatch(value)){
                  return 'Per favore inserisci un nome valido';
                }
                return null;
              },
            ),
            // Box vuoto per lasciare spazio
            const SizedBox(height: 12),
            // textfield per il cognome
            TextFormField(
                controller: _cognomeController,
                // stesso stile del precedente
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0Xff167485), width: 1.0),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                  ),
                  prefixIcon: const Icon(Icons.account_circle_outlined, color: Color(0XFF0E4C56)),
                  hintText: 'Inserisci cognome utente',
                  labelText: 'Cognome',
                  labelStyle: GoogleFonts.inter(
                      fontSize: 15,
                      color:Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                      fontWeight: FontWeight.w400,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci un cognome';
                } else if (!nomCognomeRegex.hasMatch(value)){
                  return 'Per favore inserisci un nome valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            // textfield per la matricola
            TextFormField(
              controller: _matricolaController,
              maxLength: 5, // la lunghezza del campo è di 5 cifre
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                //rappresenta la decorazione del bordo normalmente, quando selezionato ed in caso di errori
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0Xff167485), width: 1.0),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                ),
                errorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0XFFEB701D), width: 2.0),
                ),
                prefixIcon: const Icon(Icons.bookmark_add, color: Color(0XFF0E4C56)),
                hintText: 'Inserisci la matricola dell\'utente',
                labelText: 'Matricola',
                labelStyle: GoogleFonts.inter(
                    fontSize: 15,
                    color:Colors.black,   //del colore OX sono obbligatorie, FF indica l'opacità
                    fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci una matricola';
                } 
                if (value.length != 5) {
                  return 'La matricola deve essere di 5 cifre';
                }
                if (!RegExp(r'^[0-9]{5}$').hasMatch(value)) {
                  return 'La matricola deve contenere solo cifre numeriche';
                }
                return null;
              },
            ),
            // pulsante alla fine del form
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Se il form è valido, aggiungi l'utente al database
                  _addUtenteToDatabase();
                }
              },
              //serve a personalizzare lo stile del bottone
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0Xff167485),
                elevation: 5,
              ),
              child: Text(
                'Aggiungi utente',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0XFFEFECE9),   //del colore OX sono obbligatorie, FF indica l'opacità
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// questa funzione deve essere async e dunque il suo codice non può essere messo direttamente nell'onPressed del pulsante
  void _addUtenteToDatabase() async {
    // Crea il nuovo utente con i valori inseriti nel form
    Utente newUtente = Utente(
      matricola: _matricolaController.text.trim(),
      nome: _nomeController.text.trim(),
      cognome: _cognomeController.text.trim(),
    );

    // Controlla se la matricola c'è già nel db 
    Utente? utentePresente = await DatabaseHelper.instance.selectUtenteByMatricola(newUtente.matricola);
    
    if (utentePresente != null) {
      // Mostra un messaggio di errore se la matricola esiste già
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci una matricola non già associata ad un utente!')),
      );
    } else {
      // Usa il DatabaseHelper per inserire l'utente nel database
      await DatabaseHelper.instance.insertUtente(newUtente);

      // Mostra uno Snackbar per confermare l'aggiunta dell'utente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utente aggiunto!')),
      );

      // Svuota i campi del form
      _matricolaController.clear();
      _nomeController.clear();
      _cognomeController.clear();
    }
  }
}