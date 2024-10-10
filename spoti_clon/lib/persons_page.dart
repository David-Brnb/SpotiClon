import 'dart:math';

import 'package:flutter/material.dart';
import 'song_manager.dart';
import 'my_sql_connection.dart'; // Asegúrate de importar la lógica de la base de datos
import 'package:intl/intl.dart'; // Para formatear fechas

class PersonsPage extends StatefulWidget {
  const PersonsPage({super.key});

  @override
  State<PersonsPage> createState() => _PersonsPageState();
}

class _PersonsPageState extends State<PersonsPage> {
  late Future<List<Map<String, dynamic>>> futurePersons;

  @override
  void initState() {
    super.initState();
    refreshPersons();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futurePersons,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No persons yet'));
        }

        var persons = snapshot.data!;
        return ListView(
          children: persons.map((person) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(person['stage_name'] ?? 'Unknown person'),
              subtitle: Text(person['real_name'] ?? 'Unknown person'),
              onTap: () => _showPersonDetailsDialog(context, person),
            );
          }).toList(),
        );
      },
    );
  }

  

  // Método para mostrar el diálogo de detalles de un álbum
  void _showPersonDetailsDialog(BuildContext context, Map<String, dynamic> person) {
    bool isEditing = false;

    // Creamos controladores para cada campo que queremos editar
    TextEditingController stageNameController = TextEditingController(text: person['stage_name'].toString());
    TextEditingController realNameController = TextEditingController(text: person['real_name'].toString());
    TextEditingController birthDateController = TextEditingController(text: person['birth_date'].toString());
    TextEditingController deathDateController = TextEditingController(text: person['death_date'].toString());


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
                  const Text('Person Details'),
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
                      controller: stageNameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Stage Name'),
                    ),
                    TextFormField(
                      controller: realNameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Real Name'),
                    ),
                    TextFormField(
                      controller: birthDateController,
                      decoration: const InputDecoration(labelText: 'Birth Date'),
                      readOnly: true, // Hacer que el campo sea solo de lectura
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, birthDateController); // Mostrar el DatePicker solo si está en modo de edición
                        }
                      },
                    ),
                    TextFormField(
                      controller: deathDateController,
                      decoration: const InputDecoration(labelText: 'Death Date'),
                      readOnly: true, // Hacer que el campo sea solo de lectura
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, deathDateController); // Mostrar el DatePicker solo si está en modo de edición
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
                      await MySQLDatabase.actualizarPersona(
                        person['id_person'], 
                        stageNameController.text, 
                        realNameController.text, 
                        birthDateController.text, 
                        deathDateController.text
                      );

                      refreshPersons(); // Refrescar la lista de álbumes

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

  void refreshPersons() {
    var songManager = SongManager();
    songManager.refreshPersons();
    setState(() {
      futurePersons = songManager.data ?? Future.value([]);
    });
  }
}
