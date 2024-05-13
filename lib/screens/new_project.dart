import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/todo_section.dart';

class NewProject extends StatelessWidget {
  const NewProject({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Nuovo progetto';

    return Scaffold(
        appBar: OTAppBar(title: 'Nuovo Progetto'),
        body: const NewProjectForm(),
    );
  }
}

// Rappresenta il nostro form
class NewProjectForm extends StatefulWidget {
  const NewProjectForm({super.key});

  @override
  NewProjectFormState createState() {
    return NewProjectFormState();
  }
}

// Lo State memorizza le informazioni del form.
class NewProjectFormState extends State<NewProjectForm> {
  // Creiamo una chiave globale che identifica univocamente
  // il widget del Form e permette di fare la validazione.
  // NB: questa è una GlobalKey<FormState>, FormState è una
  // classe che rappresenta lo State di un Form generico
  final _formKey = GlobalKey<FormState>();
  //il controller che mi serve per la data
  TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // La key è necessaria per creare il Form
    return Form(
      key: _formKey,
      //mi serve un componente scrollabile altrimenti non possovedere tutti gli elementi nella pagina
      child: SingleChildScrollView(
        child: Padding(
          //per settare una distanza fissa dai bordi dello schermo
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          //mettere Column in Padding perchè quest'ultimo non accetta children ma un solo child
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Allinea a sinistra, di default è centrale
            children: [
              ElevatedButton(
                onPressed: () {
                // .validate() ritorna true se il form è valido, altrimenti false
                if (_formKey.currentState!.validate()) {
                  // Se è valido, mostriamo una SnackBar
                  // Tipicamente qui faremo una chiamata ad un server o
                  // qualche task di update (es, scriviamo su un db)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sto processando i dati...')),
                  );
                }
              },
              child: const Text('Aggiungi progetto'),
              ),

              TextFormField(
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Per favore, inserisci un nome al progetto.";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Inserisci il nome del progetto',
                ),
              ),

              SizedBox(
                height: 20,
              ),

              TextField(
                maxLength: 250,   //massimo 250 parole
                maxLines: null,   //quando termina lo spazio continua a capo
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Inserisci descrizione del progetto...',
                ),
              ),

              SizedBox(
                height: 5,
              ),

              Text(
                'Team',
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //dovremo usare un dropDownMenu per selezionare i team scelti da db o file json

              SizedBox(
                height: 5,
              ),

              Container(
                //larghezza la metà dello schermo per garantire responsività
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextFormField(
                  controller: _dateController, // Associa il controller al campo di testo della data
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "Per favore, inserisci una scadenza al progetto.";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Aggiungi scadenza...',
                    filled: true, //il campo avrà un colore di sfondo
                    prefixIcon: Icon(Icons.calendar_today), //aggiunge l'icona nel campo prima del testo
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

              SizedBox(
                height: 15,
              ),

              Text(
                'Cosa vuoi fare?',
                softWrap: true,   //se non c'è abbastanza spazio manda a capo
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              TodoApp(),
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
}

