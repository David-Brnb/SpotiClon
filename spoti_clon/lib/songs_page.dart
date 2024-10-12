 import 'package:flutter/material.dart';
import 'my_sql_connection.dart';
import 'song_manager.dart'; // Lógica del SongManager

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  late Future<List<Map<String, dynamic>>> futureSongs;
  TextEditingController searchController = TextEditingController(); // Controlador para el campo de búsqueda

  @override
  void initState() {
    super.initState();
    refreshSongs(); // Cargar la lista de canciones al iniciar la página
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          // Campo de búsqueda
          child: TextField(
            controller: searchController, // Controlador para manejar la entrada del usuario
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Acción que se ejecuta al enviar el texto de búsqueda
            onSubmitted: (value) {
              setState(() {
                futureSongs = MySQLDatabase.buscarSongs(value); // Buscar canciones con el valor ingresado
              });
              print("Texto de búsqueda final: $value");
            },
          ),
        ),
        // Mostrar la lista de canciones
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: futureSongs,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Mostrar indicador de progreso mientras se cargan las canciones
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Mostrar mensaje de error si ocurre algún problema
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Mostrar mensaje si no hay canciones disponibles
                return const Center(child: Text('No songs yet'));
              }

              var songs = snapshot.data!;
              return ListView(
                children: songs.map((song) {
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: Text(song['title'] ?? 'Unknown Title'), // Título de la canción
                    subtitle: Text(song['artist'] ?? 'Unknown Artist'), // Artista de la canción
                    onTap: () => _showSongMenu(context, song), // Mostrar el menú al seleccionar la canción
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // Función para mostrar un menú o bottom sheet al seleccionar una canción
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
                  // Lógica para agregar la canción a una playlist
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(context); // Cerrar el menú
                  _showDetailsDialog(context, song); // Mostrar los detalles de la canción
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Función para mostrar el diálogo de detalles de una canción
  void _showDetailsDialog(BuildContext context, Map<String, dynamic> song) {
    bool isEditing = false; // Controla si el usuario está en modo edición
    
    // Controladores para los campos de la canción
    TextEditingController titleController = TextEditingController(text: song['title']);
    TextEditingController artistController = TextEditingController(text: song['artist']);
    TextEditingController albumController = TextEditingController(text: song['album'] ?? 'Unknown Album');
    TextEditingController yearController = TextEditingController(text: song['year'].toString());
    TextEditingController genreController = TextEditingController(text: song['genre'] ?? 'Unknown Genre');
    TextEditingController trackController = TextEditingController(text: song['track'].toString());

    // Mostrar el diálogo con los detalles de la canción
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
                    // Campos de edición de los detalles de la canción
                    TextFormField(
                      controller: titleController,
                      readOnly: !isEditing, // Solo lectura si no está en modo edición
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextFormField(
                      controller: artistController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Artist'),
                    ),
                    TextFormField(
                      controller: albumController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Album'),
                    ),
                    TextFormField(
                      controller: yearController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number, // Asegura que solo se ingresen números
                    ),
                    TextFormField(
                      controller: genreController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Genre'),
                    ),
                    TextFormField(
                      controller: trackController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Track'),
                    ),
                  ],
                ),
              ),
              actions: [
                // Botón para alternar entre edición y guardar cambios
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Guardar los cambios en la base de datos
                      int updatedYear = int.tryParse(yearController.text) ?? song['year'];
                      int updatedTrack = int.tryParse(trackController.text) ?? song['track'];

                      MySQLDatabase.actualizarRola(
                        song['id_rola'], 
                        song['id_performer'], 
                        song['id_album'],
                        titleController.text, 
                        artistController.text, 
                        albumController.text, 
                        updatedYear, 
                        genreController.text, 
                        updatedTrack
                      );

                      refreshSongs(); // Refrescar la lista de canciones

                      Navigator.of(context).pop(); // Cerrar el diálogo después de guardar
                    }
                    // Alternar entre modo edición y visualización
                    setState(() {
                      isEditing = !isEditing;
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

  // Refrescar la lista de canciones desde la base de datos
  void refreshSongs() {
    var songManager = SongManager();
    songManager.refreshSongs();
    setState(() {
      futureSongs = songManager.data ?? Future.value([]);
    });
  }
}
