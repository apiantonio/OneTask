import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      title: '<nome_app>',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nuovo utente'),
        ),
        body: addUserForm(),
      ),
   );
  }
  
}

class addUserForm extends StatefulWidget{
  @override
  _addUserFormState createState() => _addUserFormState();
}

class _addUserFormState extends State<addUserForm> {
  // chiave identificativa del form utile per la validazione
  final _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // textfield per il nome
          TextFormField(
              decoration: const InputDecoration(
              icon: Icon(Icons.person),
              hintText: 'Inserisci nome utente',
              labelText: 'Nome',
            ),
            validator: (value) {
               if (value == null || value.isEmpty) {
                return 'Per favore inserisci un nome';
              }
              return null;
            },
          ),
          // textfield per il cognome
          TextFormField(
              decoration: const InputDecoration(
              icon: Icon(Icons.account_circle_outlined),
              hintText: 'Inserisci cognome utente',
              labelText: 'Cognome',
            ),
            validator: (value) {
               if (value == null || value.isEmpty) {
                return 'Per favore inserisci un cognome';
              }
              return null;
            },
          ),
          // textfield per la matricola
          TextFormField(
              decoration: const InputDecoration(
              icon: Icon(Icons.bookmark_add),
              hintText: 'Inserisci la matricola dell\'utente',
              labelText: 'Matricola',
            ),
            validator: (value) {
               if (value == null || value.isEmpty) {
                return 'Per favore inserisci una matricola';
              }
              // VA AGGIUNTA LA LOGICA PER CONTROLLARE CHE SIA UNIVOCA
              return null;
            },
          ),
          Padding(
            // padding prima del pulsante
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 38),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // qui bisognerà aggiungere i dati al database
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Utente aggiunto!')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}