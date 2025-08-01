import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import 'package:OneTask/model/utente.dart';

// Questo widget rappresenterà il form per l'inserimento di un utente
class AddUserForm extends StatefulWidget{
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
              decoration: const InputDecoration(
                // aggiungo il bordo al campo di testo
                border: OutlineInputBorder(),
                // icona interna al box di testi
                prefixIcon: Icon(Icons.person),
                hintText: 'Inserisci nome utente',
                labelText: 'Nome',
                // imposta una dimensione al box di testo
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci un nome';
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                  hintText: 'Inserisci cognome utente',
                  labelText: 'Cognome',
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Per favore inserisci un cognome';
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bookmark_add),
                hintText: 'Inserisci la matricola dell\'utente',
                labelText: 'Matricola',
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
              child: const Text('Inserisci utente'),
            ),
          ],
        ),
      ),
    );
  }
  
  // questa funzione deve essere async e dunque il suo codice non può essere messo direttamente nell'onPressed del pulsante
  void _addUtenteToDatabase() async {
    // Crea il nuovo utente con i valori inseriti nel form
    Utente newUtente = Utente(
      matricola: _matricolaController.text,
      nome: _nomeController.text,
      cognome: _cognomeController.text,
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