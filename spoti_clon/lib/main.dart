import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_home_page.dart'; // Importar la página principal
import 'my_app_state.dart'; // Importar el archivo que maneja el estado de la app

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(), // Estado global
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true, // Activar Material Design 3
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey), // Definir el color principal
          scaffoldBackgroundColor: const Color(0xFF006CB4), // Color de fondo de las páginas
          navigationRailTheme: const NavigationRailThemeData(
            backgroundColor: Colors.white, // Color de fondo del NavigationRail
            selectedIconTheme: IconThemeData(color: Colors.white), // Color del texto seleccionado
          ),
        ),
        home: const MyHomePage(), // Página principal
        debugShowCheckedModeBanner: false, // Ocultar el banner de debug
      ),
    );
  }
}
