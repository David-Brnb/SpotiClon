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

  @override
  void initState() {
    super.initState();
    var songManager = SongManager();
    songManager.refreshSongs();
    futureSongs = songManager.data ?? Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureSongs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No songs yet'));
        }

        var songs = snapshot.data!;
        return ListView(
          children: songs.map((song) {
            return ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(song['title'] ?? 'Unknown Title'),
              subtitle: Text(song['artist'] ?? 'Unknown Artist'),
              onTap: () => _showSongMenu(context, song),
            );
          }).toList(),
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
    
    // Creamos controladores para cada campo que queremos editar
    TextEditingController titleController = TextEditingController(text: song['title']);
    TextEditingController artistController = TextEditingController(text: song['artist']);
    TextEditingController albumController = TextEditingController(text: song['album'] ?? 'Unknown Album');
    TextEditingController yearController = TextEditingController(text: song['year'].toString());
    TextEditingController genreController = TextEditingController(text: song['genre'] ?? 'Unknown Genre');

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
                      controller: titleController,
                      readOnly: !isEditing, // Si no está en modo de edición, es solo lectura
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
                      keyboardType: TextInputType.number, // Asegúrate que se use solo números
                    ),
                    TextFormField(
                      controller: genreController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Genre'),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Aquí se guardan los cambios
                      int updatedYear = int.tryParse(yearController.text) ?? song['year'];

                      MySQLDatabase.actualizarRola(
                        song['id_rola'], 
                        song['id_performer'], 
                        song['id_album'],
                        titleController.text, 
                        artistController.text, 
                        albumController.text, 
                        updatedYear, 
                        genreController.text
                      );

                      Navigator.of(context).pop(); // Cerrar el diálogo después de guardar
                      initState();
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
