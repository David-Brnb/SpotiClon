import 'package:flutter/material.dart';
import 'song_manager.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  late Future<List<Map<String, dynamic>>> futureAlbums;

  @override
  void initState() {
    super.initState();
    var songManager = SongManager();
    songManager.refreshAlbums();
    futureAlbums = songManager.data ?? Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureAlbums,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No albums yet'));
        }

        var albums = snapshot.data!;
        return ListView(
          children: albums.map((album) {
            return ListTile(
              leading: const Icon(Icons.album),
              title: Text(album['album_name'] ?? 'Unknown Album'),
              subtitle: Text(album['artist'] ?? 'Unknown Artist'),
            );
          }).toList(),
        );
      },
    );
  }
}
