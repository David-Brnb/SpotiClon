import 'package:flutter/material.dart';
import 'package:spoti_clon/groups_page.dart';
import 'performers_page.dart';
import 'songs_page.dart'; // Lógica de la página de canciones
import 'albums_page.dart'; // Lógica de la página de álbumes
import 'generator_page.dart'; // Lógica de la página de inicio
import 'persons_page.dart';
import 'my_sql_connection.dart'; // Manejo de la conexión y creación de tablas en la base de datos

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Índice de la página seleccionada en el NavigationRail
  bool isRailExpanded = false; // Controla si el NavigationRail está expandido o colapsado

  @override
  void initState() {
    super.initState();
    
    // Llama a la función para crear las tablas en la base de datos al iniciar la app
    MySQLDatabase.createTables();
  }

  @override
  Widget build(BuildContext context) {
    // Determina qué página mostrar según el índice seleccionado
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage(); // Página de inicio
        break;
      case 1:
        page = const SongsPage(); // Página de canciones
        break;
      case 2:
        page = const AlbumsPage(); // Página de álbumes
        break;
      case 3:
        page = const PerformersPage(); // Página de intérpretes
        break;
      case 4:
        page = const PersonsPage(); // Página de personas
        break;
      case 5:
        page = const GroupsPage(); // Página de grupos
        break;
      default:
        throw UnimplementedError('No hay widget para el índice $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Determina si debe expandir el NavigationRail según el tamaño de la pantalla o la interacción del usuario
      bool shouldExpand = isRailExpanded;
      bool shouldShowButton = constraints.maxWidth >= 650;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Row(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Muestra el botón para expandir o colapsar el NavigationRail si el ancho es suficiente
                  if (shouldShowButton)
                    IconButton(
                      icon: Icon(isRailExpanded ? Icons.arrow_back : Icons.menu),
                      onPressed: () {
                        setState(() {
                          isRailExpanded = !isRailExpanded; // Alterna entre expandido y colapsado
                        });
                      },
                    ),
                  // NavigationRail que permite la navegación entre las diferentes páginas
                  Expanded(
                    child: NavigationRail(
                      extended: shouldExpand, // Expande o colapsa el rail según el estado
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
                          label: Text('Groups'),
                        ),
                      ],
                      selectedIndex: selectedIndex, // Controla qué página está seleccionada
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value; // Cambia la página al seleccionar un destino
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Muestra la página seleccionada ocupando el resto del espacio disponible
            Expanded(
              child: page,
            ),
          ],
        ),
      );
    });
  }
}
