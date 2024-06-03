import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/edit_project_form.dart';

/// Pagina per la modifica di un progetto
class ModifyProject extends StatelessWidget {
  final String projectName;

  const ModifyProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Modifica Progetto', withSearchbar: false),
      body: EditProjectForm(projectName: projectName),
      backgroundColor: const Color(0XFFE8E5E0),
    );
  }
}
