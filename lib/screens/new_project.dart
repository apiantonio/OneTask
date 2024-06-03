import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/new_project_form.dart';

/// Pagina per la creazione di un nuovo progetto
class NewProject extends StatelessWidget {
  const NewProject({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: OTAppBar(title: 'Nuovo Progetto', withSearchbar: false),
      body: NewProjectForm(),
      backgroundColor: Color(0XFFE8E5E0),
    );
  }
}

