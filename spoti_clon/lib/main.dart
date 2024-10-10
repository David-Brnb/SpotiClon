import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'mp3_miner.dart'; // Importar el minero
import 'my_sql_connection.dart';

void main() {
  runApp(const MyApp());
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
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class SongManager {
  static final SongManager _instance = SongManager._internal();
  Future<List<Map<String, dynamic>>>? data;

  factory SongManager() {
    return _instance;
  }

  SongManager._internal();

  void refreshSongs() {
    data = MySQLDatabase.descargaRolas();
  }

  void refreshAlbums(){
    data = MySQLDatabase.descargaAlbums();
  }
}


class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var selectedDirectory=""; // Variable para almacenar la ruta seleccionada
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
        page = const Scaffold(
          body: Center(child: Text('Page 3')),
        );
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      // Controlar si se debe expandir el NavigationRail basado en el tamaño o el botón
      bool shouldExpand = isRailExpanded;
      bool shouldShowButton = constraints.maxWidth >= 650;

      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: Column(
                children: [
                  // Botón para abrir/cerrar el NavigationRail
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
                          icon: Icon(Icons.person),
                          label: Text('Person'),
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

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  late Future<List<Map<String, dynamic>>> futureSongs;

  @override
  void initState() {
    super.initState();
    // Descargar las canciones cuando se inicializa la página
    var songManager = SongManager();
    songManager.refreshSongs();
    futureSongs = songManager.data ?? Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureSongs, // Llamada asincrónica para obtener las canciones
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar un indicador de carga mientras se descargan las canciones
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Mostrar un mensaje de error si algo salió mal
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Mostrar un mensaje si no hay canciones
          return const Center(child: Text('No songs yet'));
        }

        // Mostrar la lista de canciones si todo está bien
        var songs = snapshot.data!;
        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('You have ${songs.length} songs: '),
            ),
            for (var song in songs)
              ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(song['title'] ?? 'Unknown Title'),
                subtitle: Text(song['artist'] ?? 'Unknown Artist'),
                onTap: () {
                  // Navigator.pop(context);
                  // Al presionar, mostramos el menú o bottom sheet
                  _showSongMenu(context, song);
                },
                
              ),
          ],
        );
      },
    );
  }

  // Función para mostrar un menú o bottom sheet al presionar una canción
  void _showSongMenu(BuildContext context, Map<String, dynamic> song) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(context); // Cerrar el menú
                  // Lógica para agregar la canción a la playlist
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context); // Cerrar el menú
                  _showDetailsDialog(context, song);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> song) {
    bool isEditing = false; // Controla si el usuario está en modo de edición

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Song Details'),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: song['title'],
                      readOnly: !isEditing, // Si no está en modo de edición, es solo lectura
                      decoration: InputDecoration(labelText: 'Title'),
                    ),
                    TextFormField(
                      initialValue: song['artist'],
                      readOnly: !isEditing,
                      decoration: InputDecoration(labelText: 'Artist'),
                    ),
                    TextFormField(
                      initialValue: song['album'] ?? 'Unknown Album',
                      readOnly: !isEditing,
                      decoration: InputDecoration(labelText: 'Album'),
                    ),
                    TextFormField(
                      initialValue: song['year'].toString(),
                      readOnly: !isEditing,
                      decoration: InputDecoration(labelText: 'Year'),
                    ),
                    TextFormField(
                      initialValue: song['genre'] ?? 'Unknown Genre',
                      readOnly: !isEditing,
                      decoration: InputDecoration(labelText: 'Genre'),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    if (isEditing) {
                      // Guardar los cambios
                      // Lógica para guardar los cambios
                    }
                    setState(() {
                      isEditing = !isEditing; // Cambia entre editar y visualizar
                    });
                  },
                  child: Text(isEditing ? 'Guardar' : 'Editar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}

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
            LinearProgressIndicator(value: miningProgress),
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

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  late Future<List<Map<String, dynamic>>> albums;

  @override
  void initState() {
    super.initState();
    // Descargar las canciones cuando se inicializa la página
    var songManager = SongManager();
    songManager.refreshAlbums();
    albums = songManager.data ?? Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: albums, // Llamada asincrónica para obtener las canciones
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar un indicador de carga mientras se descargan las canciones
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Mostrar un mensaje de error si algo salió mal
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Mostrar un mensaje si no hay canciones
          return const Center(child: Text('No songs yet'));
        }

        // Mostrar la lista de canciones si todo está bien
        var albums = snapshot.data!;

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('You have ${albums.length} albums: '),
            ),
            for (var album in albums)
              ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(album['album_name'] ?? 'Unknown Title'),
                subtitle: Text(album['artist'] ?? 'Unknown Artist'),
                onTap: () {
                  // Navigator.pop(context);
                  // Al presionar, mostramos el menú o bottom sheet
                  _showAlbumMenu(context, album);
                },
                
              ),
          ],
        );
      },
    );
  }

  // Función para mostrar un menú o bottom sheet al presionar una canción
  void _showAlbumMenu(BuildContext context, Map<String, dynamic> song) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add to Favorites'),
                onTap: () {
                  Navigator.pop(context); // Cerrar el menú
                  // Lógica para agregar el album a la playlist
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context); // Cerrar el menú
                  // Lógica para mostrar detalles del album
                },
              ),
            ],
          ),
        );
      },
    );
  }
}