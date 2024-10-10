import 'package:flutter/material.dart';
import 'song_manager.dart';
import 'my_sql_connection.dart'; // Asegúrate de importar la lógica de la base de datos

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
    refreshPerformers();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futurePerformers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No performers yet'));
        }

        var performers = snapshot.data!;
        var type = "";

  
        return ListView(
          children: performers.map((performer) {
            if(performer['id_type'] == 0){
              type = "Person";

            } else if(performer['id_type'] == 1){
              type = "Group";
              
            } else {
              type = "Unknown";

            }
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

  // Método para mostrar el diálogo de detalles de un álbum
  void _showPerformerDetailsDialog(BuildContext context, Map<String, dynamic> performer) {
    bool isEditing = false;

    // Creamos controladores para cada campo que queremos editar
    TextEditingController nameController = TextEditingController(text: performer['name']);
    var type = "";

    if(performer['id_type'] == 0){
      type = "Person";

    } else if(performer['id_type'] == 1){
      type = "Group";
      
    } else {
      type = "Unknown";

    }
    TextEditingController typeController = TextEditingController(text: type);

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
                    TextFormField(
                      controller: nameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Performer Name'),
                    ),
                    TextFormField(
                      controller: typeController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Type'),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Guardar los cambios
                      int updatedType = 2;

                      if(typeController.text == "Person"){
                        updatedType = 0; 
                      } else if(typeController.text == "Group"){
                        updatedType = 1;
                      }
                      

                      await MySQLDatabase.actualizarPerformer(
                        performer['id_performer'], 
                        updatedType, 
                        nameController.text
                      );

                      refreshPerformers(); // Refrescar la lista de álbumes

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

  void refreshPerformers() {
    var songManager = SongManager();
    songManager.refreshPerformers();
    setState(() {
      futurePerformers = songManager.data ?? Future.value([]);
    });
  }
}
