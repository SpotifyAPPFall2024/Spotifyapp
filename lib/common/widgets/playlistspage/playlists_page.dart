import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotifyapp/presentation/home/page/player_page.dart';

class PlaylistsPage extends StatelessWidget {
  final String playlistID;
  final String accessToken;

  const PlaylistsPage(
      {required this.accessToken, required this.playlistID, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playlist Tracks'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPlaylistTracks(accessToken, playlistID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tracks found'));
          } else {
            final tracks = snapshot.data!;
            return ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index]['track'];
                return ListTile(
                  title: Text(track['name']),
                  subtitle:
                      Text(track['artists'].map((a) => a['name']).join(', ')),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlayerPage(
                                trackID: track['id'],
                                trackIndex: index,
                                accessToken: accessToken)));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchPlaylistTracks(
      String accessToken, String playlistID) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistID/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load tracks ${response.statusCode}');
    }
  }
}
