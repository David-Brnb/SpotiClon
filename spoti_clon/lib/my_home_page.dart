import 'package:flutter/material.dart';
import 'performers_page.dart';
import 'songs_page.dart'; // Archivo separado para manejar la lógica de la página de canciones
import 'albums_page.dart'; // Archivo separado para manejar la lógica de la página de álbumes
import 'generator_page.dart'; // Archivo separado para manejar la lógica de la página de inicio
import 'persons_page.dart';
import 'my_sql_connection.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  bool isRailExpanded = false; // Variable para controlar el estado del NavigationRail

  @override
  void initState() {
    super.initState();
    
    // Aquí llamas a la función que crea las tablas solo la primera vez
    MySQLDatabase.createTables(); // Asegúrate de tener la clase y método correctos
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const SongsPage();
        break;
      case 2:
        page = const AlbumsPage();
        break;
      case 3:
        page = const PerformersPage();
        break;
      case 4:
        page = const PersonsPage();
        break;
      case 5:
        page = const AlbumsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Controlar si se debe expandir el NavigationRail basado en el tamaño o el botón
      bool shouldExpand = isRailExpanded;
      bool shouldShowButton = constraints.maxWidth >= 650;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            SafeArea(
              child: Column(
                children: [
                  if(shouldShowButton)
                    IconButton(
                      icon: Icon(isRailExpanded ? Icons.arrow_back : Icons.menu),
                      onPressed: () {
                        setState(() {
                          isRailExpanded = !isRailExpanded; // Alternar el estado
                        });
                      },
                    ),
                  Expanded(
                    child: NavigationRail(
                      extended: shouldExpand,
                      minExtendedWidth: shouldExpand ? constraints.maxWidth / 4.16 : null,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.music_note),
                          label: Text('Songs'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.album),
                          label: Text('Albums'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.mic_external_on_rounded),
                          label: Text('Performers'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.person),
                          label: Text('Persons'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.group),
                          label: Text('Gruops'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: page,
            ),
          ],
        ),
      );
    });
  }
}
