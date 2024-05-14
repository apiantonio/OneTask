import 'package:flutter/material.dart';
import '../widgets/appbar.dart';

class NewTeam extends StatelessWidget {
  const NewTeam({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: OTAppBar(title: 'NuovoTeam'),
        body: const NewTeamForm(),
    );
  }
}

//rappresenta il nostro form
class NewTeamForm extends StatefulWidget {
  const NewTeamForm({super.key});

  @override
  NewTeamFormState createState() {
    return NewTeamFormState();
  }
}

class NewTeamFormState extends State<NewTeamForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
  }
}