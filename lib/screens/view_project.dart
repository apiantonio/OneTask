import 'package:flutter/material.dart';
import '../widgets/appbar.dart';
import '../widgets/delete_project_floating_button.dart';
import '../widgets/project_details.dart';

/// Pagina per la visualizzazione di un progetto
class ViewProject extends StatelessWidget {
  final String projectName;

  const ViewProject({super.key, required this.projectName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const OTAppBar(title: 'Visualizza Progetto', withSearchbar: false),
      body: ProjectDetails(projectName: projectName),
      backgroundColor: const Color(0XFFE8E5E0),
      floatingActionButton: DeleteProjectFloatingButton(projectName: projectName),
    );
  }
}
