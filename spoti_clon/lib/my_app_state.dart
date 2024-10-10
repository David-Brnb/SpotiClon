import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'mp3_miner.dart'; // Tu clase para manejar minería

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var selectedDirectory = ""; 
  List<Map<String, dynamic>> minedSongs = [];
  double miningProgress = 0.0;
  bool isMining = false;
  bool hasError = false;
  String errorMessage = "";

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var songs = <WordPair>[];

  void toggleSong() {
    if (songs.contains(current)) {
      songs.remove(current);
    } else {
      songs.add(current);
    }
    notifyListeners();
  }

  Future<void> selectFolderAndMine() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      selectedDirectory = directoryPath;
      notifyListeners();
      startMining(directoryPath);
    }
  }

  Future<void> startMining(String directoryPath) async {
    isMining = true;
    minedSongs.clear();
    hasError = false;
    notifyListeners();

    try {
      final miner = Mp3Miner();
      minedSongs = await miner.mineDirectory(directoryPath, (progress) {
        miningProgress = progress;
        notifyListeners();
      });

      if (minedSongs.isEmpty) {
        errorMessage = "No se encontraron archivos MP3.";
        hasError = true;
      }
    } catch (e) {
      errorMessage = "Error durante la minería: $e";
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

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.inversePrimary,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }

}