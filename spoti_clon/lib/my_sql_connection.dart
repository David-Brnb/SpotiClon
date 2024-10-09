import 'package:mysql1/mysql1.dart';

class MySQLDatabase {
  // Configura los parámetros de conexión
  static Future<MySqlConnection> getConnection() async {
    var settings = ConnectionSettings(
      host: 'localhost',
      port: 3306, // Puerto de MySQL, normalmente es 3306
      user: 'root', // Usuario de la base de datos
      password: '007David', // Contraseña del usuario
      db: 'musica', // Nombre de la base de datos
    );
    return await MySqlConnection.connect(settings);
  }

  // Función para crear las tablas
  static Future<void> createTables() async {
    try {
      var conn = await getConnection();

      // Crear la tabla 'types'
      await conn.query('''
        CREATE TABLE IF NOT EXISTS types (
          id_type       INTEGER PRIMARY KEY,
          description   TEXT
        );
      ''');

      // Crear la tabla 'performers'
      await conn.query('''
        CREATE TABLE IF NOT EXISTS performers (
          id_performer  INTEGER PRIMARY KEY,
          id_type       INTEGER,
          name          TEXT,
          FOREIGN KEY   (id_type) REFERENCES types(id_type)
        );
      ''');

      // Crear la tabla 'persons'
      await conn.query('''
        CREATE TABLE IF NOT EXISTS persons (
          id_person     INTEGER PRIMARY KEY,
          stage_name    TEXT,
          real_name     TEXT,
          birth_date    TEXT,
          death_date    TEXT
        );
      ''');

      // Crear la tabla 'groups' (Usar comillas invertidas para evitar conflictos con palabras reservadas)
      await conn.query('''
        CREATE TABLE IF NOT EXISTS `groups` (
          id_group      INTEGER PRIMARY KEY,
          name          TEXT,
          start_date    TEXT,
          end_date      TEXT
        );
      ''');

      // Crear la tabla 'in_group'
      await conn.query('''
        CREATE TABLE IF NOT EXISTS in_group (
          id_person     INTEGER,
          id_group      INTEGER,
          PRIMARY KEY   (id_person, id_group),
          FOREIGN KEY   (id_person) REFERENCES persons(id_person),
          FOREIGN KEY   (id_group) REFERENCES `groups`(id_group)
        );
      ''');

      // Crear la tabla 'albums'
      await conn.query('''
        CREATE TABLE IF NOT EXISTS albums (
          id_album      INTEGER PRIMARY KEY,
          path          TEXT,
          name          TEXT,
          year          INTEGER
        );
      ''');

      // Crear la tabla 'rolas'
      await conn.query('''
        CREATE TABLE IF NOT EXISTS rolas (
          id_rola       INTEGER PRIMARY KEY,
          id_performer  INTEGER,
          id_album      INTEGER,
          path          TEXT,
          title         TEXT,
          track         INTEGER,
          year          INTEGER,
          genre         TEXT,
          FOREIGN KEY   (id_performer) REFERENCES performers(id_performer),
          FOREIGN KEY   (id_album) REFERENCES albums(id_album)
        );
      ''');

      // Verificar si la tabla 'types' ya tiene datos
      var result = await conn.query('SELECT COUNT(*) as count FROM types');
      var rowCount = result.first['count'];

      if (rowCount == 0) {
        // Si no hay registros, hacer las inserciones
        await conn.query('INSERT INTO types (id_type, description) VALUES (0, "Person")');
        await conn.query('INSERT INTO types (id_type, description) VALUES (1, "Group")');
        await conn.query('INSERT INTO types (id_type, description) VALUES (2, "Unknown")');

        print('Inserciones realizadas en la tabla types.');
      } else {
        print('La tabla types ya contiene datos. No se realizaron inserciones.');
      }

      print('Tables created successfully!');

      // Cerrar la conexión
      await conn.close();
    } catch (e) {
      print('Error al crear las tablas: $e');
    }
  }
}
