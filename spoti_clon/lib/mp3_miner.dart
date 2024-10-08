import 'dart:io';

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

    for (int i = 0; i < totalFiles; i++) {
      var file = files[i];
      if (file is File) {
        // Agregar un retraso para ver el progreso más lentamente
        await Future.delayed(Duration(milliseconds: 100)); // Retraso de 2 segundos

        // Ejecutar ffmpeg para extraer los metadatos del archivo MP3
        var result = await Process.run(
          '/opt/homebrew/bin/ffmpeg',
          ['-i', file.path, '-f', 'ffmetadata', '-'], // Comando de ffmpeg para extraer metadatos
        );

        if (result.exitCode == 0) {
          // Parsear la salida de ffmpeg y extraer los campos relevantes
          Map<String, String> tags = _parseMetadata(result.stdout);
          songs.add({
            'title': tags['title'] ?? 'Unknown',
            'artist': tags['artist'] ?? 'Unknown',
            'album': tags['album'] ?? 'Unknown',
            'genre': tags['genre'] ?? 'Unknown',
            'year': tags['date'] ?? 'Unknown',
            'path': file.path,
          });
        } else {
          print("Error al procesar ${file.path}: ${result.stderr}");
        }

        // Actualizar el progreso
        updateProgress((i + 1) / totalFiles);
      }
    }

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
