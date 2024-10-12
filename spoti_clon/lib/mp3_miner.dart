import 'dart:io';
import 'my_sql_connection.dart';

class Mp3Miner {
  // Función que extrae metadatos de archivos MP3 y los inserta en la base de datos
  Future<List<Map<String, dynamic>>> mineDirectory(String directoryPath, Function(double) updateProgress) async {
    List<Map<String, dynamic>> songs = [];

    // Verifica si el directorio existe
    Directory directory = Directory(directoryPath);
    if (!directory.existsSync()) {
      print("El directorio no existe");
      return songs;
    }

    // Obtiene todos los archivos MP3 del directorio
    var files = directory.listSync(recursive: true).where((element) => element.path.endsWith('.mp3')).toList();
    int totalFiles = files.length;
    var conn = await MySQLDatabase.getConnection();

    // Procesa cada archivo MP3
    for (int i = 0; i < totalFiles; i++) {
      var file = files[i];
      if (file is File) {
        // Retraso para visualizar el progreso más lento
        await Future.delayed(const Duration(milliseconds: 100));

        // Ejecuta ffmpeg para extraer los metadatos del archivo MP3
        var result = await Process.run(
          '/opt/homebrew/bin/ffmpeg',
          ['-i', file.path, '-f', 'ffmetadata', '-'],
        );

        if (result.exitCode == 0) {
          // Analiza los metadatos obtenidos de ffmpeg
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
          
          // Verifica si el intérprete ya existe en la base de datos
          var res = await conn.query(
            'SELECT id_performer FROM performers WHERE name = ? AND id_type = ?',
            [name, idType]
          );
          
          int idPerformer;

          if (res.isEmpty) {
            // Si el intérprete no existe, lo inserta en la base de datos
            var maxIdResult = await conn.query('SELECT IFNULL(MAX(id_performer), 0) as max_id FROM performers');
            idPerformer = maxIdResult.first['max_id'] + 1;

            await conn.query(
              'INSERT INTO performers (id_performer, id_type, name) VALUES (?, ?, ?)',
              [idPerformer, idType, name]
            );
            print('Nuevo performer insertado con id: $idPerformer');
          } else {
            // Si el intérprete ya existe, obtiene su id
            idPerformer = res.first['id_performer'];
            print('El performer ya existe con id: $idPerformer');
          }

          // Verifica si el álbum ya existe en la base de datos
          res = await conn.query(
            'SELECT COUNT(*) as count FROM albums WHERE name = ?',
            [album]
          );
          int count = res.first['count'];
          var albumId;

          if (count == 0) {
            // Si el álbum no existe, lo inserta en la base de datos
            var maxIdResult = await conn.query('SELECT IFNULL(MAX(id_album), 0) as max_id FROM albums');
            albumId = maxIdResult.first['max_id'] + 1;

            await conn.query(
              'INSERT INTO albums (id_album, name, year, path) VALUES (?, ?, ?, ?)',
              [albumId, album, year, file.path]
            );
            print('Nuevo álbum insertado con id: $albumId');
          } else {
            // Si el álbum ya existe, obtiene su id
            var existingAlbumResult = await conn.query(
              'SELECT id_album FROM albums WHERE name = ?',
              [album]
            );
            albumId = existingAlbumResult.first['id_album'];
            print('Álbum ya existente, id: $albumId');
          }

          // Verifica si la canción ya existe en la base de datos
          res = await conn.query(
            'SELECT COUNT(*) as count FROM rolas WHERE title = ?',
            [title]
          );
          count = res.first['count'];
          int newIdRola = -1;

          if(count == 0){
            // Si la canción no existe, la inserta en la base de datos
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

        // Actualiza el progreso del procesamiento
        updateProgress((i + 1) / totalFiles);
      }
    }

    conn.close();

    return songs;
  }

  // Función que analiza los metadatos obtenidos de ffmpeg
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
