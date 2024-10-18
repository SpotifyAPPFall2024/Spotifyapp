import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:spotifyapp/presentation/home/page/album_page.dart';
import 'player_page.dart';

class ArtistPage extends StatefulWidget {
  final String artistID;
  final String accessToken;

  const ArtistPage(
      {required this.artistID, required this.accessToken, super.key});

  @override
  ArtistPageState createState() => ArtistPageState();
}

class ArtistPageState extends State<ArtistPage> {
  Map<String, dynamic>? artistDetails;
  List<dynamic>? albums;
  List<dynamic>? topTracks;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArtistDetails();
    fetchArtistAlbums();
    fetchTopTracks();
  }

  Future<void> fetchArtistDetails() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/${widget.artistID}'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        artistDetails = json.decode(response.body);
      });
    } else {
      print('Failed to load artist details: ${response.statusCode}');
    }
  }

  Future<void> fetchArtistAlbums() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/${widget.artistID}/albums'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        albums = json.decode(response.body)['items'];
      });
    } else {
      print('Failed to load artist albums: ${response.statusCode}');
    }
  }

  Future<void> fetchTopTracks() async {
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/artists/${widget.artistID}/top-tracks?market=US'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        topTracks = json.decode(response.body)['tracks'];
        isLoading = false;
      });
    } else {
      print('Failed to load top tracks: ${response.statusCode}');
    }
  }

  void navigateToTrack(String trackID) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          trackID: trackID,
          trackIndex: 0,
          accessToken: widget.accessToken,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Artist Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (artistDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Artist Details'),
        ),
        body: const Center(child: Text('No artist details found')),
      );
    }

    final artistName = artistDetails!['name'];
    final artistImage = artistDetails!['images'].isNotEmpty
        ? artistDetails!['images'][0]['url']
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Text(artistName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(artistImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Top Tracks:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: topTracks?.length ?? 0,
                itemBuilder: (context, index) {
                  final track = topTracks![index];
                  return ListTile(
                    title: Text(track['name']),
                    subtitle: Text(track['artists']
                        .map((artist) => artist['name'])
                        .join(', ')),
                    onTap: () {
                      navigateToTrack(track['id']);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Albums:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: albums?.length ?? 0,
                itemBuilder: (context, index) {
                  final album = albums![index];
                  return ListTile(
                    title: Text(album['name']),
                    subtitle: Text(album['release_date']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AlbumPage(
                            albumID: album['id'],
                            accessToken: widget.accessToken,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
