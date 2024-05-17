import 'package:OneTask/model/progetto.dart';
import 'package:OneTask/services/database_helper.dart';
import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/task_section.dart';

// Nuova classe per modificare un progetto esistente
class EditProject extends StatelessWidget {
  final Progetto progetto;

  const EditProject({super.key, required this.progetto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OTAppBar(title: 'Modifica Progetto'),
      body: EditProjectForm(progetto: progetto),
    );
  }
}

// Form per la modifica del progetto
class EditProjectForm extends StatefulWidget {
  final Progetto progetto;

  const EditProjectForm({super.key, required this.progetto});

  @override
  EditProjectFormState createState() {
    return EditProjectFormState();
  }
}

class EditProjectFormState extends State<EditProjectForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _nomeController;
  late TextEditingController _descrizioneController;
  TextEditingController _attivitaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inizializzazione dei controller con i dati del progetto esistente
    _dateController = TextEditingController(text: widget.progetto.scadenza);
    _nomeController = TextEditingController(text: widget.progetto.nome);
    _descrizioneController =
        TextEditingController(text: widget.progetto.descrizione);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateProgettoInDatabase();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Sto processando i dati...')),
                    );
                  }
                },
                child: const Text('Aggiorna progetto'),
              ),
              TextFormField(
                controller: _nomeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Per favore, inserisci un nome al progetto.";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Inserisci il nome del progetto',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descrizioneController,
                maxLength: 250,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Inserisci descrizione del progetto...',
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Team',
                softWrap: true,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //TODO: dovremo usare un dropDownMenu per selezionare i team scelti da db o file json

              const SizedBox(height: 5),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _dateController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Per favore, inserisci una scadenza al progetto.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Aggiungi scadenza...',
                    filled: true,
                    prefixIcon: Icon(Icons.calendar_today),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onTap: () {
                    _selectDate();
                  },
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Cosa vuoi fare?',
                softWrap: true,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TaskApp(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));

    if (_picked != null) {
      setState(() {
        _dateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  void _updateProgettoInDatabase() async {
    // Creazione del progetto aggiornato mantenendo l'ID esistente
    Progetto updatedProgetto = Progetto(
      id: widget.progetto.id, // Preserving the ID to update the correct record
      nome: _nomeController.text,
      team: 'TODO',
      scadenza: _dateController.text,
      descrizione: _descrizioneController.text,
    );

    // Aggiornamento del progetto nel database
    await DatabaseHelper.instance.updateProgetto(updatedProgetto);

    // Svuoto i campi del form
    _nomeController.clear();
    _dateController.clear();
    _descrizioneController.clear();
    _attivitaController.clear();

    // Notifica l'utente che l'aggiornamento è avvenuto con successo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progetto aggiornato con successo!')),
    );

    // Torna alla pagina precedente
    Navigator.pop(context);
  }
}
