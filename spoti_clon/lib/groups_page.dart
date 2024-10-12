import 'package:flutter/material.dart';
import 'my_sql_connection.dart'; // Asegúrate de importar la lógica de la base de datos
import 'package:intl/intl.dart'; // Para formatear fechas

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  late Future<List<Map<String, dynamic>>> futureGroups;

  @override
  void initState() {
    super.initState();
    refresGroups();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureGroups,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No groups yet'));
        }

        var groups = snapshot.data!;
        return ListView(
          children: groups.map((group) {
            return ListTile(
              leading: const Icon(Icons.group),
              title: Text(group['name'] ?? 'Unknown group'),
              onTap: () => _showGroupDetailsDialog(context, group),
            );
          }).toList(),
        );
      },
    );
  }

  

  // Método para mostrar el diálogo de detalles de un álbum
  void _showGroupDetailsDialog(BuildContext context, Map<String, dynamic> group) {
    bool isEditing = false;

    // Creamos controladores para cada campo que queremos editar
    TextEditingController nameController = TextEditingController(text: group['name'].toString());
    TextEditingController startDateController = TextEditingController(text: group['start_date'].toString());
    TextEditingController endDateController = TextEditingController(text: group['end_date'].toString());


    // Función para seleccionar una fecha a partir de un string y devolver el nuevo string
    void selectDate(BuildContext context, TextEditingController controller) async {
      // Convertir el string inicial a DateTime
      DateTime? initialDate;
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      } catch (e) {
        initialDate = DateTime.now(); // Si falla la conversión, usar la fecha actual
      }

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate, // Fecha inicial convertida
        firstDate: DateTime(1900), // Fecha mínima
        lastDate: DateTime(2100), // Fecha máxima
      );

      if (picked != null) {
        // Si el usuario seleccionó una fecha, devolverla como String
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        return;
      }

      // Si el usuario no seleccionó nada, devolver null
      controller.text = DateFormat('yyyy-MM-dd').format(initialDate );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Group Details'),
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
                      decoration: const InputDecoration(labelText: 'Group Name'),
                    ),
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      readOnly: true, // Hacer que el campo sea solo de lectura
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, startDateController); // Mostrar el DatePicker solo si está en modo de edición
                        }
                      },
                    ),
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(labelText: 'End Date'),
                      readOnly: true, // Hacer que el campo sea solo de lectura
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, endDateController); // Mostrar el DatePicker solo si está en modo de edición
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Guardar los cambios
                      // await MySQLDatabase.actualizargroupa(
                      //   group['id_group'], 
                      //   nameController.text, 
                      //   realNameController.text, 
                      //   startDateController.text, 
                      //   endDateController.text
                      // );

                      refresGroups(); // Refrescar la lista de álbumes

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

  void refresGroups() {
    setState(() {
      futureGroups = MySQLDatabase.descargarGrupos();
    });
  }
}
