import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotifyapp/presentation/home/page/player_page.dart';

class AlbumPage extends StatelessWidget {
  final String albumID;
  final String accessToken;

  const AlbumPage({
    required this.accessToken,
    required this.albumID,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album Tracks'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchAlbumTracks(accessToken, albumID),
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
                final track = tracks[index];
                final trackName = track['name'] ?? 'Unknown Track';
                final artistNames = track['artists'] != null
                    ? track['artists']
                        .map((artist) => artist['name'] ?? 'Unknown Artist')
                        .join(', ')
                    : 'Unknown Artist';

                return ListTile(
                  title: Text(trackName),
                  subtitle: Text(artistNames),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerPage(
                          trackID: track['id'] ?? '',
                          trackIndex: index,
                          accessToken: accessToken,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchAlbumTracks(
      String accessToken, String albumID) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/albums/$albumID'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tracks']['items'];
    } else {
      throw Exception('Failed to load tracks: ${response.statusCode}');
    }
  }
}
