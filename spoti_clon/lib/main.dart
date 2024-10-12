import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_home_page.dart'; // Página principal de la app
import 'my_app_state.dart'; // Maneja el estado global de la app

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Proporciona el estado global de la app utilizando el patrón ChangeNotifier
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        // Define el tema principal de la aplicación
        theme: ThemeData(
          useMaterial3: true, // Habilita Material Design 3
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey), // Color principal basado en un color semilla
          scaffoldBackgroundColor: const Color(0xFF006CB4), // Color de fondo de las páginas
          navigationRailTheme: const NavigationRailThemeData(
            backgroundColor: Colors.white, // Color de fondo del NavigationRail
            selectedIconTheme: IconThemeData(color: Colors.white), // Color de los iconos seleccionados
          ),
        ),
        home: const MyHomePage(), // Página principal de la aplicación
        debugShowCheckedModeBanner: false, // Oculta el banner de modo debug
      ),
    );
  }
}
