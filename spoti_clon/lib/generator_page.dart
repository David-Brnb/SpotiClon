import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'my_app_state.dart'; // Asegúrate de tener la lógica de estado en este archivo

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var isMining = appState.isMining;
    var miningProgress = appState.miningProgress;
    var minedSongs = appState.minedSongs;
    var hasError = appState.hasError;
    var errorMessage = appState.errorMessage;

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
          BigCard(pair: pair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleSong();
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              appState.selectFolderAndMine(); // Seleccionar carpeta y empezar minería
            },
            child: const Text('Select Folder and Start Mining'),
          ),
          if (isMining) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: 400, // Ajusta el ancho de la barra de progreso
              child: LinearProgressIndicator(value: miningProgress),
            ),
            const SizedBox(height: 10),
            Text('Mining in progress... ${(miningProgress * 100).toStringAsFixed(0)}%'),
          ] else if (hasError) ...[
            const SizedBox(height: 20),
            Text('Error: $errorMessage', style: const TextStyle(color: Colors.red)),
          ] else if (minedSongs.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Mining completed! Found ${minedSongs.length} songs.'),
            
          ],
        ],
      ),
    );
  }
}
