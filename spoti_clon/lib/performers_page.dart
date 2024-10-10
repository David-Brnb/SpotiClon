import 'package:flutter/material.dart';
import 'song_manager.dart';
import 'my_sql_connection.dart'; // Asegúrate de importar la lógica de la base de datos

class PerformersPage extends StatefulWidget {
  const PerformersPage({super.key});

  @override
  State<PerformersPage> createState() => _PerformersPageState();
}

class _PerformersPageState extends State<PerformersPage> {
  late Future<List<Map<String, dynamic>>> futureAlbums;

  @override
  void initState() {
    super.initState();
    refreshAlbums();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureAlbums,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No albums yet'));
        }

        var albums = snapshot.data!;
        return ListView(
          children: albums.map((album) {
            return ListTile(
              leading: const Icon(Icons.album),
              title: Text(album['album_name'] ?? 'Unknown Album'),
              subtitle: Text(album['artist'] ?? 'Unknown Artist'),
              onTap: () => _showAlbumDetailsDialog(context, album),
            );
          }).toList(),
        );
      },
    );
  }

  // Método para mostrar el diálogo de detalles de un álbum
  void _showAlbumDetailsDialog(BuildContext context, Map<String, dynamic> album) {
    bool isEditing = false;

    // Creamos controladores para cada campo que queremos editar
    TextEditingController nameController = TextEditingController(text: album['album_name']);
    TextEditingController yearController = TextEditingController(text: album['year'].toString());
    TextEditingController pathController = TextEditingController(text: album['path']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Album Details'),
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
                      controller: nameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Album Name'),
                    ),
                    TextFormField(
                      controller: yearController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: pathController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Path'),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Guardar los cambios
                      int updatedYear = int.tryParse(yearController.text) ?? album['year'];

                      await MySQLDatabase.actualizarAlbum(
                        album['id_album'], 
                        nameController.text, 
                        updatedYear, 
                        pathController.text
                      );

                      refreshAlbums(); // Refrescar la lista de álbumes

                      Navigator.of(context).pop(); // Cerrar el diálogo después de guardar
                    }
                    setState(() {
                      isEditing = !isEditing; // Cambiar entre editar y visualizar
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

  void refreshAlbums() {
    var songManager = SongManager();
    songManager.refreshAlbums();
    setState(() {
      futureAlbums = songManager.data ?? Future.value([]);
    });
  }
}
