import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'mp3_miner.dart'; // Importar el minero

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var selectedDirectory; // Variable para almacenar la ruta seleccionada
  List<Map<String, dynamic>> minedSongs = []; // Canciones minadas
  double miningProgress = 0.0; // Progreso del minado
  bool isMining = false; // Indicar si se está minando
  bool hasError = false; // Para mostrar errores si ocurre algo
  String errorMessage = ""; // Mensaje de error

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

  // Método para seleccionar la carpeta y empezar el minado
  Future<void> selectFolderAndMine() async {
    String? directoryPath = await FilePicker.platform.getDirectoryPath();

    if (directoryPath != null) {
      selectedDirectory = directoryPath;
      notifyListeners();
      startMining(directoryPath); // Iniciar minería después de seleccionar la carpeta
    } else {
      print("No se seleccionó ninguna carpeta");
    }
  }

  // Método para iniciar la minería
  Future<void> startMining(String directoryPath) async {
    isMining = true;
    minedSongs.clear(); // Limpiar las canciones anteriores
    hasError = false; // Reiniciar el estado de error
    notifyListeners();

    try {
      final miner = Mp3Miner(); // Crear instancia del minero
      print("Empezando minería en $directoryPath");

      minedSongs = await miner.mineDirectory(directoryPath, (progress) {
        miningProgress = progress;
        print("Progreso de minería: ${progress * 100}%"); // Mostrar progreso en la consola
        notifyListeners(); // Actualizar la interfaz con el progreso
      });

      if (minedSongs.isEmpty) {
        // Si no se encontraron canciones
        errorMessage = "No se encontraron archivos MP3 en la carpeta seleccionada.";
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

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = SongsPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constrainst) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constrainst.maxWidth >= 750,
                minExtendedWidth: constrainst.maxWidth / 4.16,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.music_note),
                    label: Text('Songs'),
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
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class SongsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var songs = appState.songs;

    if (songs.isEmpty) {
      return Center(
        child: Text('No songs yet'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${songs.length} songs: '),
        ),
        for (var pair in songs)
          ListTile(
            leading: Icon(Icons.music_note),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var selectedDirectory = appState.selectedDirectory;
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
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleSong();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              appState.selectFolderAndMine(); // Seleccionar carpeta y empezar minería
            },
            child: Text('Select Folder and Start Mining'),
          ),
          if (isMining) ...[
            SizedBox(height: 20),
            LinearProgressIndicator(value: miningProgress),
            SizedBox(height: 10),
            Text('Mining in progress... ${(miningProgress * 100).toStringAsFixed(0)}%'),
          ] else if (hasError) ...[
            SizedBox(height: 20),
            Text('Error: $errorMessage', style: TextStyle(color: Colors.red)),
          ] else if (minedSongs.isNotEmpty) ...[
            SizedBox(height: 20),
            Text('Mining completed! Found ${minedSongs.length} songs.'),
            Expanded(
              child: ListView.builder(
                itemCount: minedSongs.length,
                itemBuilder: (context, index) {
                  final song = minedSongs[index];
                  return ListTile(
                    title: Text(song['title']),
                    subtitle: Text(song['artist']),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
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
