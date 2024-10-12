import 'package:flutter/material.dart';
import 'song_manager.dart';
import 'my_sql_connection.dart'; // Importar la lógica de conexión a la base de datos

class PerformersPage extends StatefulWidget {
  const PerformersPage({super.key});

  @override
  State<PerformersPage> createState() => _PerformersPageState();
}

class _PerformersPageState extends State<PerformersPage> {
  late Future<List<Map<String, dynamic>>> futurePerformers;

  @override
  void initState() {
    super.initState();
    refreshPerformers(); // Cargar la lista de performers al iniciar
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futurePerformers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar indicador de progreso mientras los datos se cargan
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Mostrar un mensaje de error si algo falla
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Mostrar un mensaje si no hay performers
          return const Center(child: Text('No performers yet'));
        }

        var performers = snapshot.data!;
        var type = "";

        // Mostrar la lista de performers
        return ListView(
          children: performers.map((performer) {
            // Determinar el tipo de performer
            if (performer['id_type'] == 0) {
              type = "Person";
            } else if (performer['id_type'] == 1) {
              type = "Group";
            } else {
              type = "Unknown";
            }

            // Mostrar la información del performer
            return ListTile(
              leading: const Icon(Icons.mic_external_on_rounded),
              title: Text(performer['name'] ?? 'Unknown performer'),
              subtitle: Text(type),
              onTap: () => _showPerformerDetailsDialog(context, performer),
            );
          }).toList(),
        );
      },
    );
  }

  // Mostrar el diálogo de detalles de un performer con opción de edición
  void _showPerformerDetailsDialog(BuildContext context, Map<String, dynamic> performer) {
    bool isEditing = false; // Controla si el diálogo está en modo edición

    // Controladores para los campos del diálogo
    TextEditingController nameController = TextEditingController(text: performer['name']);
    var type = "";

    // Determinar el tipo del performer
    if (performer['id_type'] == 0) {
      type = "Person";
    } else if (performer['id_type'] == 1) {
      type = "Group";
    } else {
      type = "Unknown";
    }
    TextEditingController typeController = TextEditingController(text: type);

    // Construir el diálogo
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Performer Details'),
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
                    // Campo para el nombre del performer
                    TextFormField(
                      controller: nameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Performer Name'),
                    ),
                    // Campo para el tipo del performer
                    TextFormField(
                      controller: typeController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                  ],
                ),
              ),
              actions: [
                // Botón para alternar entre modo edición y guardado
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Guardar cambios
                      int updatedType = 2;

                      if (typeController.text == "Person") {
                        updatedType = 0;
                      } else if (typeController.text == "Group") {
                        updatedType = 1;
                      }

                      // Actualizar el performer en la base de datos
                      await MySQLDatabase.actualizarPerformer(
                        performer['id_performer'], 
                        updatedType, 
                        nameController.text, 
                        performer['stage_name'].toString()
                      );

                      refreshPerformers(); // Refrescar la lista de performers

                      Navigator.of(context).pop(); // Cerrar el diálogo
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

  // Refrescar la lista de performers desde la base de datos
  void refreshPerformers() {
    var songManager = SongManager();
    songManager.refreshPerformers();
    setState(() {
      futurePerformers = songManager.data ?? Future.value([]);
    });
  }
}
