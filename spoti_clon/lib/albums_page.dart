import 'package:flutter/material.dart';
import 'song_manager.dart';
import 'my_sql_connection.dart'; // Asegúrate de importar la lógica de la base de datos

// La clase AlbumsPage representa la página de álbumes y es un StatefulWidget porque su estado puede cambiar.
class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

// _AlbumsPageState gestiona el estado de AlbumsPage
class _AlbumsPageState extends State<AlbumsPage> {
  // futureAlbums almacenará el resultado de la consulta de álbumes.
  late Future<List<Map<String, dynamic>>> futureAlbums;

  @override
  void initState() {
    super.initState();
    // Llamamos a la función para cargar los álbumes al inicializar el widget
    refreshAlbums();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos FutureBuilder para construir la UI según el estado de futureAlbums
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureAlbums,
      builder: (context, snapshot) {
        // Mientras los datos se están cargando, mostramos un indicador de progreso.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // Si hubo un error en la consulta, mostramos un mensaje de error.
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } 
        // Si no hay álbumes, mostramos un mensaje indicando que no hay álbumes disponibles.
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No albums yet'));
        }

        // Si los datos fueron cargados correctamente, construimos una lista de álbumes.
        var albums = snapshot.data!;
        return ListView(
          children: albums.map((album) {
            // Cada álbum se muestra como un ListTile con un ícono, título y subtítulo.
            return ListTile(
              leading: const Icon(Icons.album), // Ícono de álbum.
              title: Text(album['album_name'] ?? 'Unknown Album'), // Nombre del álbum.
              subtitle: Text(album['artist'] ?? 'Unknown Artist'), // Artista del álbum.
              onTap: () => _showAlbumDetailsDialog(context, album), // Al hacer clic, mostramos un diálogo con los detalles del álbum.
            );
          }).toList(),
        );
      },
    );
  }

  // Método para mostrar un cuadro de diálogo con los detalles del álbum.
  void _showAlbumDetailsDialog(BuildContext context, Map<String, dynamic> album) {
    bool isEditing = false; // Indicador de modo de edición

    // Creamos controladores para los campos de nombre del álbum, año y ruta.
    TextEditingController nameController = TextEditingController(text: album['album_name']);
    TextEditingController yearController = TextEditingController(text: album['year'].toString());
    TextEditingController pathController = TextEditingController(text: album['path']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilder nos permite actualizar el estado de los botones dentro del diálogo.
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Album Details'), // Título del diálogo.
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo.
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Campo para editar el nombre del álbum.
                    TextFormField(
                      controller: nameController,
                      readOnly: !isEditing, // Solo editable si está en modo de edición.
                      decoration: const InputDecoration(labelText: 'Album Name'),
                    ),
                    // Campo para editar el año del álbum.
                    TextFormField(
                      controller: yearController,
                      readOnly: !isEditing, // Solo editable si está en modo de edición.
                      decoration: const InputDecoration(labelText: 'Year'),
                      keyboardType: TextInputType.number, // El campo acepta solo números.
                    ),
                    // Campo para editar la ruta del álbum.
                    TextFormField(
                      controller: pathController,
                      readOnly: !isEditing, // Solo editable si está en modo de edición.
                      decoration: const InputDecoration(labelText: 'Path'),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Si está en modo de edición, guardamos los cambios.
                      int updatedYear = int.tryParse(yearController.text) ?? album['year']; // Convertimos el año a entero.

                      // Llamada a la base de datos para actualizar el álbum.
                      await MySQLDatabase.actualizarAlbum(
                        album['id_album'], 
                        nameController.text, 
                        updatedYear, 
                        pathController.text
                      );

                      refreshAlbums(); // Refresca la lista de álbumes después de guardar.

                      Navigator.of(context).pop(); // Cierra el diálogo después de guardar.
                    }
                    setState(() {
                      isEditing = !isEditing; // Cambia entre modo de edición y visualización.
                    });
                  },
                  child: Text(isEditing ? 'Guardar' : 'Editar'), // El botón cambia entre 'Guardar' y 'Editar'.
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para refrescar la lista de álbumes.
  void refreshAlbums() {
    var songManager = SongManager(); // Instancia del manejador de canciones.
    songManager.refreshAlbums(); // Actualiza la lista de álbumes.
    setState(() {
      // Actualizamos el estado con los nuevos álbumes.
      futureAlbums = songManager.data ?? Future.value([]); // Si no hay datos, devolvemos una lista vacía.
    });
  }
}
