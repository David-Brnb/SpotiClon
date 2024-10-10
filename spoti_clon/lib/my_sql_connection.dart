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
      await Future.delayed(const Duration(seconds: 1));
      var result = await conn.query('SELECT COUNT(*) as count FROM types');
      await Future.delayed(const Duration(seconds: 1));

      if (result.isNotEmpty) {
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
      } else {
        print('La consulta no devolvió ningún resultado.');
      }

      print('Tables created successfully!');

      // Cerrar la conexión
      await conn.close();
    } catch (e) {
      print('Error al crear las tablas: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> descargaRolas() async {
    List<Map<String, dynamic>> songs = [];
    var conn = await MySQLDatabase.getConnection(); // Abre la conexión a la base de datos

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Consultar todas las filas de la tabla 'rolas' y unirse con la tabla 'performers' y 'albums' para obtener los nombres de los artistas y álbumes
      var results = await conn.query('''
        SELECT r.id_rola, r.id_performer, r.id_album, r.path, r.title, r.track, r.year as song_year, r.genre, 
              p.name as artist, s.year as album_year, s.name as album_name
        FROM rolas r
        JOIN performers p ON r.id_performer = p.id_performer
        JOIN albums s ON r.id_album = s.id_album
      ''');

      await Future.delayed(const Duration(milliseconds: 500));

      // Iterar sobre los resultados y agregarlos a la lista de mapas
      for (var row in results) {
        Map<String, dynamic> song = {
          'id_rola': row['id_rola'],
          'id_performer': row['id_performer'],
          'id_album': row['id_album'],
          'path': row['path'].toString(), // Asegurarse de que `path` es un string
          'title': row['title'].toString(), // Asegurarse de que `title` es un string
          'artist': row['artist'].toString(), // Usar directamente el valor del artista
          'album': row['album_name'].toString(), // Nombre del álbum
          'albumYear': row['album_year'].toString(), // Año del álbum
          'track': row['track'],
          'year': row['song_year'], // Año de la canción
          'genre': row['genre'].toString(), // Asegurarse de que `genre` es un string
        };
        songs.add(song);
      }

      print('Consulta ejecutada: Resultados obtenidos');
    } catch (e) {
      print('Error al ejecutar la consulta: $e');
    } finally {
      await conn.close(); // Cerrar la conexión a la base de datos
    }

    return songs; // Retornar la lista de canciones descargadas
  }


  static Future<List<Map<String, dynamic>>> descargaAlbums() async {
    List<Map<String, dynamic>> albums = [];

    var conn = await MySQLDatabase.getConnection(); // Abre la conexión a la base de datos

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Consultar todas las filas de la tabla 'rolas' y unirse con la tabla 'performers' y 'albums' para obtener los nombres de los artistas y álbumes
      var results = await conn.query('''
        SELECT a.id_album, a.path, a.name, a.year, 
              p.name as artist, s.id_performer
        FROM albums a
        JOIN rolas s ON a.id_album = s.id_album
        JOIN performers p ON s.id_performer = p.id_performer
      ''');

      await Future.delayed(const Duration(milliseconds: 500));

      // Iterar sobre los resultados y agregarlos a la lista de mapas
      for (var row in results) {
        Map<String, dynamic> album = {
          'id_album': row['id_album'],
          'path': row['path'].toString(), // Asegurarse de que `path` es un string
          'album_name': row['name'].toString(), // Nombre del album
          'year': row['year'].toString(), // Año del álbum
          'artist': row['artist'].toString(),
          'id_performer': row['id_performer'] // Asegurarse de que `genre` es un string
        };
        albums.add(album);
      }

      print('Consulta ejecutada: Resultados obtenidos');
    } catch (e) {
      print('Error al ejecutar la consulta: $e');
    } finally {
      await conn.close(); // Cerrar la conexión a la base de datos
    }
    
    return albums; 
  }

  static Future<List<Map<String, dynamic>>> descargaPerformers() async {
    List<Map<String, dynamic>> performers = [];

    var conn = await MySQLDatabase.getConnection(); // Abre la conexión a la base de datos

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Consultar todas las filas de la tabla 'rolas' y unirse con la tabla 'performers' y 'albums' para obtener los nombres de los artistas y álbumes
      var results = await conn.query('''
        SELECT p.id_performer, p.id_type, p.name, 
        FROM performers p
      ''');

      await Future.delayed(const Duration(milliseconds: 500));

      // Iterar sobre los resultados y agregarlos a la lista de mapas
      for (var row in results) {
        Map<String, dynamic> performer = {
          'id_performer': row['id_performer'],
          'id_type': row['id_type'],
          'name': row['name'].toString(), // Nombre del performer
        };

        performers.add(performer);
      }

      print('Consulta ejecutada: Resultados obtenidos');
    } catch (e) {
      print('Error al ejecutar la consulta: $e');
    } finally {
      await conn.close(); // Cerrar la conexión a la base de datos
    }
    
    return performers; 
  }

  // Método para actualizar un registro en la tabla 'rolas'
  static Future<void> actualizarRola(int idRola, int idPerformer, int idAlbum, String title, String artist, String album, int year, String genre, int track) async {
    try {
      var conn = await getConnection();

      // Ejecutar el UPDATE
      await conn.query('''
        UPDATE rolas
        SET title = '$title', genre = '$genre', year = $year, track = $track
        WHERE id_rola = $idRola
      ''');

      // Si quieres también actualizar el artista y álbum (suponiendo que tengas relaciones correctas)
      await conn.query('''
        UPDATE performers 
        SET name = '$artist'
        WHERE id_performer = $idPerformer
      ''');

      await conn.query('''
        UPDATE albums 
        SET name = '$album'
        WHERE id_album = $idAlbum
      ''');

      print("Rola actualizada correctamente");
      await conn.close();
    } catch (e) {
      print('Error al actualizar la rola: $e');
    }
  }

  static Future<void> actualizarAlbum(int idAlbum, String name, int year, String path) async {
    try {
      var conn = await getConnection(); // Obtener la conexión a la base de datos

      // Ejecutar el UPDATE
      await conn.query('''
        UPDATE albums 
        SET name = '${name.replaceAll("'", " ")}', year = $year, path = '$path' 
        WHERE id_album = $idAlbum
      ''');

      print("Álbum actualizado correctamente");
      await conn.close(); // Cerrar la conexión después de la actualización
    } catch (e) {
      print('Error al actualizar el álbum: $e');
    }
  }

  static Future<void> actualizarPerformer(int idPerformer, int idType, String name) async{
    try {
      var conn = await getConnection(); // Obtener la conexión a la base de datos

      // Ejecutar el UPDATE
      await conn.query('''
        UPDATE performers 
        SET name = '${name.replaceAll("'", " ")}', id_type = $idType
        WHERE id_performer = $idPerformer
      ''');

      print("Álbum actualizado correctamente");
      await conn.close(); // Cerrar la conexión después de la actualización
    } catch (e) {
      print('Error al actualizar el álbum: $e');
    }
  }



}
