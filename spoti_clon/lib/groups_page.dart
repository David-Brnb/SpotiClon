import 'package:flutter/material.dart';
import 'my_sql_connection.dart'; // Importa la conexión a la base de datos
import 'package:intl/intl.dart'; // Para formatear fechas

// Clase GroupsPage, una página que muestra una lista de grupos de la base de datos
class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  // futureGroups contendrá la lista de grupos a descargar de la base de datos
  late Future<List<Map<String, dynamic>>> futureGroups;

  @override
  void initState() {
    super.initState();
    // Al inicializar el estado, se refresca la lista de grupos
    refresGroups();
  }
  
  @override
  Widget build(BuildContext context) {
    // FutureBuilder construye la UI en función del estado futuro de futureGroups
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureGroups,
      builder: (context, snapshot) {
        // Muestra un indicador de progreso mientras se cargan los datos
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } 
        // Si hay un error, lo muestra en pantalla
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } 
        // Si no hay grupos, muestra un mensaje
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No groups yet'));
        }

        // Cuando se cargan los grupos, los muestra en una lista
        var groups = snapshot.data!;
        return ListView(
          children: groups.map((group) {
            // Muestra cada grupo como un ListTile
            return ListTile(
              leading: const Icon(Icons.group), // Ícono de grupo
              title: Text(group['name'] ?? 'Unknown group'), // Nombre del grupo
              onTap: () => _showGroupDetailsDialog(context, group), // Muestra los detalles al hacer clic
            );
          }).toList(),
        );
      },
    );
  }

  // Método que muestra un cuadro de diálogo con los detalles del grupo seleccionado
  void _showGroupDetailsDialog(BuildContext context, Map<String, dynamic> group) {
    bool isEditing = false; // Controla si está en modo de edición o solo visualización

    // Controladores de texto para los campos de edición
    TextEditingController nameController = TextEditingController(text: group['name'].toString());
    TextEditingController startDateController = TextEditingController(text: group['start_date'].toString());
    TextEditingController endDateController = TextEditingController(text: group['end_date'].toString());

    // Función para seleccionar una fecha y actualizar el controlador con el nuevo valor
    void selectDate(BuildContext context, TextEditingController controller) async {
      DateTime? initialDate;
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(controller.text); // Intenta parsear la fecha actual
      } catch (e) {
        initialDate = DateTime.now(); // Usa la fecha actual si falla
      }

      // Muestra un selector de fecha
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate, // Fecha inicial
        firstDate: DateTime(1900), // Fecha mínima seleccionable
        lastDate: DateTime(2100), // Fecha máxima seleccionable
      );

      // Si se selecciona una fecha, actualiza el controlador con el valor seleccionado
      if (picked != null) {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        return;
      }

      // Si no se selecciona una fecha, mantiene la fecha original
      controller.text = DateFormat('yyyy-MM-dd').format(initialDate);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // StatefulBuilder permite cambiar el estado del diálogo
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Group Details'), // Título del cuadro de diálogo
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo al presionar el botón
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    // Campo de texto para el nombre del grupo
                    TextFormField(
                      controller: nameController,
                      readOnly: !isEditing, // Solo editable si está en modo de edición
                      decoration: const InputDecoration(labelText: 'Group Name'),
                    ),
                    // Campo de texto para la fecha de inicio del grupo
                    TextFormField(
                      controller: startDateController,
                      decoration: const InputDecoration(labelText: 'Start Date'),
                      readOnly: true, // Solo lectura, permite seleccionar una fecha con DatePicker
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, startDateController); // Seleccionar una nueva fecha
                        }
                      },
                    ),
                    // Campo de texto para la fecha de fin del grupo
                    TextFormField(
                      controller: endDateController,
                      decoration: const InputDecoration(labelText: 'End Date'),
                      readOnly: true, // Solo lectura, permite seleccionar una fecha con DatePicker
                      onTap: () {
                        if (isEditing) {
                          selectDate(context, endDateController); // Seleccionar una nueva fecha
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
                      // Guardar los cambios en la base de datos (comentar o implementar la lógica aquí)
                      // await MySQLDatabase.actualizargroupa(
                      //   group['id_group'], 
                      //   nameController.text, 
                      //   startDateController.text, 
                      //   endDateController.text
                      // );

                      refresGroups(); // Refresca la lista de grupos

                      Navigator.of(context).pop(); // Cierra el diálogo después de guardar
                    }
                    setState(() {
                      isEditing = !isEditing; // Alterna entre modo de edición y visualización
                    });
                  },
                  child: Text(isEditing ? 'Guardar' : 'Editar'), // Cambia el texto del botón según el modo
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método que actualiza la lista de grupos desde la base de datos
  void refresGroups() {
    setState(() {
      futureGroups = MySQLDatabase.descargarGrupos(); // Descarga los grupos desde la base de datos
    });
  }
}
