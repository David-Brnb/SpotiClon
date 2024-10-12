import 'dart:io';
import 'my_sql_connection.dart';

class Mp3Miner {
  // Función para ejecutar ffmpeg y extraer los metadatos de los archivos MP3
  Future<List<Map<String, dynamic>>> mineDirectory(String directoryPath, Function(double) updateProgress) async {
    List<Map<String, dynamic>> songs = [];

    // Verificar si el directorio existe
    Directory directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      print("El directorio no existe");
      return songs;
    }

    // Obtener todos los archivos MP3 en el directorio
    var files = directory.listSync(recursive: true).where((element) => element.path.endsWith('.mp3')).toList();
    int totalFiles = files.length;
    var conn = await MySQLDatabase.getConnection();

    for (int i = 0; i < totalFiles; i++) {
      var file = files[i];
      if (file is File) {
        // Agregar un retraso para ver el progreso más lentamente
        await Future.delayed(const Duration(milliseconds: 100)); // Retraso de 2 segundos

        // Ejecutar ffmpeg para extraer los metadatos del archivo MP3
        var result = await Process.run(
          '/opt/homebrew/bin/ffmpeg',
          ['-i', file.path, '-f', 'ffmetadata', '-'], // Comando de ffmpeg para extraer metadatos
        );

        if (result.exitCode == 0) {
          // Parsear la salida de ffmpeg y extraer los campos relevantes
          Map<String, String> tags = _parseMetadata(result.stdout);
          songs.add({
            'title': tags['title'] ?? 'Unknown',   // Título de la canción
            'artist': tags['artist'] ?? 'Unknown',  // Intérprete
          });

          var name = tags['artist'] ?? 'Unknown';
          var album = tags['album'] ?? 'Unknown';
          int year = int.tryParse(tags['date'] ?? 'Unknown') ?? 0;
          var title = tags['title'] ?? 'Unknown';
          var genre = tags['genre'] ?? 'Unknown';
          int track = int.tryParse(tags['track'] ?? tags['TRCK'] ?? 'Unknown') ?? 0;
          var idType = 2;
          
          // Verificar si ya existe un performer con ese nombre e id_type
          var res = await conn.query(
            'SELECT id_performer FROM performers WHERE name = ? AND id_type = ?',
            [name, idType]
          );
          
          int idPerformer;

          if (res.isEmpty) {
            // Si no existe, obtener el id_performer más alto y agregar el nuevo performer
            var maxIdResult = await conn.query('SELECT IFNULL(MAX(id_performer), 0) as max_id FROM performers');
            idPerformer = maxIdResult.first['max_id'] + 1;

            // Insertar el nuevo performer
            await conn.query(
              'INSERT INTO performers (id_performer, id_type, name) VALUES (?, ?, ?)',
              [idPerformer, idType, name]
            );
            print('Nuevo performer insertado con id: $idPerformer');
          } else {
            // Si ya existe, obtener el id_performer
            idPerformer = res.first['id_performer'];
            print('El performer ya existe con id: $idPerformer');
          }

          // Ahora verificar y/o insertar el álbum
          res = await conn.query(
            'SELECT COUNT(*) as count FROM albums WHERE name = ?',
            [album]
          );
          int count = res.first['count'];
          var albumId;

          if (count == 0) {
            // Si el álbum no existe, obtener el id_album más alto actual e insertarlo
            var maxIdResult = await conn.query('SELECT IFNULL(MAX(id_album), 0) as max_id FROM albums');
            albumId = maxIdResult.first['max_id'] + 1;

            await conn.query(
              'INSERT INTO albums (id_album, name, year, path) VALUES (?, ?, ?, ?)',
              [albumId, album, year, file.path]
            );
            print('Nuevo álbum insertado con id: $albumId');
          } else {
            // Si el álbum ya existe, obtener el id_album
            var existingAlbumResult = await conn.query(
              'SELECT id_album FROM albums WHERE name = ?',
              [album]
            );
            albumId = existingAlbumResult.first['id_album'];
            print('Álbum ya existente, id: $albumId');
          }

          res = await conn.query(
            'SELECT COUNT(*) as count FROM rolas WHERE title = ?',
            [title]
          );
          count = res.first['count'];
          int newIdRola = -1;

          if(count == 0){
            // Ahora insertar la canción (rola)
            var maxIdRolaResult = await conn.query('SELECT IFNULL(MAX(id_rola), 0) as max_id FROM rolas');
            newIdRola = maxIdRolaResult.first['max_id'] + 1;

            await conn.query(
              'INSERT INTO rolas (id_rola, id_performer, id_album, path, title, track, year, genre) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
              [newIdRola, idPerformer, albumId, file.path, title, track, year, genre]
            );

            print('Nueva rola insertada con id: $newIdRola');

          } else {
            print('La rola ya existe');
          }

        } else {
          print("Error al procesar ${file.path}: ${result.stderr}");
        }

        // Actualizar el progreso
        updateProgress((i + 1) / totalFiles);
      }
    }

    conn.close();

    return songs;
  }

  // Función para parsear la salida de ffmpeg y extraer los metadatos
  Map<String, String> _parseMetadata(String metadata) {
    Map<String, String> tags = {};
    var lines = metadata.split('\n');
    for (var line in lines) {
      if (line.contains('=')) {
        var parts = line.split('=');
        if (parts.length == 2) {
          tags[parts[0].trim()] = parts[1].trim();
        }
      }
    }
    return tags;
  }
}
