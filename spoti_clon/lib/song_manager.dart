import 'my_sql_connection.dart';

class SongManager {
  static final SongManager _instance = SongManager._internal();
  Future<List<Map<String, dynamic>>>? data;

  factory SongManager() {
    return _instance;
  }

  SongManager._internal();

  void refreshSongs() {
    data = MySQLDatabase.descargaRolas();
  }

  void refreshAlbums(){
    data = MySQLDatabase.descargaAlbums();
  }
}
