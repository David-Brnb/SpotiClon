import 'package:flutter/material.dart';
import 'song_manager.dart';
import 'my_sql_connection.dart'; // Importar la lógica de conexión a la base de datos
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
    refreshPersons(); // Cargar la lista de personas al iniciar
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futurePersons,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar indicador de progreso mientras los datos se cargan
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Mostrar un mensaje de error si algo falla
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Mostrar un mensaje si no hay personas
          return const Center(child: Text('No persons yet'));
        }

        var persons = snapshot.data!;

        // Mostrar la lista de personas
        return ListView(
          children: persons.map((person) {
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(person['stage_name'] ?? 'Unknown person'),
              subtitle: Text(person['real_name'] ?? 'Unknown person'),
              onTap: () => _showPersonDetailsDialog(context, person), // Mostrar detalles al tocar
            );
          }).toList(),
        );
      },
    );
  }

  // Método para mostrar el diálogo de detalles de una persona con opción de edición
  void _showPersonDetailsDialog(BuildContext context, Map<String, dynamic> person) {
    bool isEditing = false; // Controla si el diálogo está en modo edición

    // Controladores para los campos de la persona
    TextEditingController stageNameController = TextEditingController(text: person['stage_name'].toString());
    TextEditingController realNameController = TextEditingController(text: person['real_name'].toString());
    TextEditingController birthDateController = TextEditingController(text: person['birth_date'].toString());
    TextEditingController deathDateController = TextEditingController(text: person['death_date'].toString());

    // Función para seleccionar una fecha a través del DatePicker
    void selectDate(BuildContext context, TextEditingController controller) async {
      DateTime? initialDate;
      try {
        // Intentar convertir el texto de la fecha a un objeto DateTime
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text);
      } catch (e) {
        // Si falla la conversión, usar la fecha actual como predeterminada
        initialDate = DateTime.now();
      }

      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate, // Fecha inicial en el DatePicker
        firstDate: DateTime(1900), // Fecha mínima permitida
        lastDate: DateTime(2100), // Fecha máxima permitida
      );

      if (picked != null) {
        // Si se selecciona una fecha, actualizar el controlador con el nuevo valor
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      } else {
        // Si no se selecciona nada, mantener la fecha original
        controller.text = DateFormat('yyyy-MM-dd').format(initialDate);
      }
    }

    // Mostrar el diálogo de detalles de la persona
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
                    // Campo para editar el nombre artístico
                    TextFormField(
                      controller: stageNameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Stage Name'),
                    ),
                    // Campo para editar el nombre real
                    TextFormField(
                      controller: realNameController,
                      readOnly: !isEditing,
                      decoration: const InputDecoration(labelText: 'Real Name'),
                    ),
                    // Campo para seleccionar la fecha de nacimiento
                    TextFormField(
                      controller: birthDateController,
                      decoration: const InputDecoration(labelText: 'Birth Date'),
                      readOnly: true, // Solo lectura hasta que se esté en modo edición
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, birthDateController); // Mostrar el DatePicker solo en modo edición
                        }
                      },
                    ),
                    // Campo para seleccionar la fecha de defunción
                    TextFormField(
                      controller: deathDateController,
                      decoration: const InputDecoration(labelText: 'Death Date'),
                      readOnly: true, // Solo lectura hasta que se esté en modo edición
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, deathDateController); // Mostrar el DatePicker solo en modo edición
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                // Botón para alternar entre modo edición y guardado
                ElevatedButton(
                  onPressed: () async {
                    if (isEditing) {
                      // Guardar los cambios en la base de datos
                      await MySQLDatabase.actualizarPersona(
                        person['id_person'], 
                        stageNameController.text, 
                        realNameController.text, 
                        birthDateController.text, 
                        deathDateController.text
                      );

                      refreshPersons(); // Refrescar la lista de personas
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

  // Refrescar la lista de personas desde la base de datos
  void refreshPersons() {
    var songManager = SongManager();
    songManager.refreshPersons();
    setState(() {
      futurePersons = songManager.data ?? Future.value([]);
    });
  }
}
