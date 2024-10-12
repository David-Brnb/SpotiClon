import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spoti_clon/my_sql_connection.dart';
import 'my_app_state.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  // Controlador para el campo de texto de búsqueda
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializa la creación de tablas en la base de datos cuando se carga la página
    MySQLDatabase.createTables();
  }

  @override
  Widget build(BuildContext context) {
    // Accede al estado global de la aplicación para obtener y manejar la lógica de minería de canciones
    var appState = context.watch<MyAppState>();

    // Obtiene la canción actual y el estado de minería desde el estado global
    var pair = appState.current;
    var isMining = appState.isMining;
    var miningProgress = appState.miningProgress;
    var minedSongs = appState.minedSongs;
    var hasError = appState.hasError;
    var errorMessage = appState.errorMessage;

    // Determina el ícono adecuado según si la canción actual ha sido marcada como favorita o no
    IconData icon;
    if (appState.songs.contains(pair)) {
      icon = Icons.music_note;
    } else {
      icon = Icons.music_note_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Componente para mostrar la canción actual
          BigCard(pair: pair),
          const SizedBox(height: 10),

          // Botones de "Like" y "Next" para interactuar con la canción actual
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Marca o desmarca la canción actual como favorita
                  appState.toggleSong();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Obtiene la siguiente canción
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Botón para seleccionar una carpeta y comenzar la minería de canciones
          ElevatedButton(
            onPressed: () {
              appState.selectFolderAndMine();
            },
            child: const Text('Select Folder and Start Mining'),
          ),

          // Indicador de progreso, muestra el estado de la minería si está en proceso
          if (isMining) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 400, // Ancho de la barra de progreso
              child: LinearProgressIndicator(value: miningProgress),
            ),
            const SizedBox(height: 10),
            Text('Mining in progress... ${(miningProgress * 100).toStringAsFixed(0)}%'),
          ]
          // Muestra un mensaje de error si la minería falla
          else if (hasError) ...[
            const SizedBox(height: 20),
            Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
          ]
          // Muestra el resultado cuando la minería termina con éxito
          else if (minedSongs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Mining completed! Found ${minedSongs.length} songs.'),
          ],
        ],
      ),
    );
  }
}
