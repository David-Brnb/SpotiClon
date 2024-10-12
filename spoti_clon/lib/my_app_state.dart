import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'mp3_miner.dart'; // Clase para manejar la minería de archivos MP3

class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Palabra generada aleatoriamente
  var selectedDirectory = ""; // Almacena el directorio seleccionado por el usuario
  List<Map<String, dynamic>> minedSongs = []; // Lista de canciones minadas
  double miningProgress = 0.0; // Progreso de la minería
  bool isMining = false; // Indica si la minería está en curso
  bool hasError = false; // Indica si ocurrió un error durante la minería
  String errorMessage = ""; // Mensaje de error en caso de que ocurra

  // Genera un nuevo par de palabras aleatorias
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var songs = <WordPair>[]; // Lista de canciones seleccionadas

  // Alterna la selección de una canción
  void toggleSong() {
    if (songs.contains(current)) {
      songs.remove(current);
    } else {
      songs.add(current);
    }
    notifyListeners();
  }

  // Permite al usuario seleccionar una carpeta y comienza la minería de archivos MP3
  Future<void> selectFolderAndMine() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      selectedDirectory = directoryPath;
      notifyListeners();
      startMining(directoryPath); // Inicia el proceso de minería
    }
  }

  // Inicia el proceso de minería de archivos MP3 en el directorio seleccionado
  Future<void> startMining(String directoryPath) async {
    isMining = true;
    minedSongs.clear(); // Limpia las canciones minadas previamente
    hasError = false;
    notifyListeners();

    try {
      final miner = Mp3Miner();
      minedSongs = await miner.mineDirectory(directoryPath, (progress) {
        miningProgress = progress; // Actualiza el progreso de la minería
        notifyListeners();
      });

      // Verifica si no se encontraron archivos MP3
      if (minedSongs.isEmpty) {
        errorMessage = "No se encontraron archivos MP3.";
        hasError = true;
      }
    } catch (e) {
      errorMessage = "Error durante la minería: $e"; // Manejo de errores
      hasError = true;
    }

    isMining = false;
    notifyListeners();
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair; // Par de palabras aleatorias para mostrar

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimary, // Estilo del texto de la tarjeta
    );

    // Retorna una tarjeta con el título de la aplicación
    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          "Spoti-Clon",
          style: style,
          semanticsLabel: "SpotiClon", // Etiqueta semántica
        ),
      ),
    );
  }
}
