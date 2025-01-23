import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/verdura_controller.dart';
import 'view/verdura_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para inicializar plugins
  final verduraController = VerduraController();
  await verduraController.loadFromFile(); // Cargar datos desde el archivo

  runApp(
    ChangeNotifierProvider(
      create: (_) => verduraController,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VerduraView(),
    );
  }
}
