import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:spotifyapp/presentation/home/page/album_page.dart';
import 'package:spotifyapp/presentation/home/page/artist_page.dart';
import 'package:spotifyapp/presentation/home/page/player_page.dart';

class SearchPage extends StatefulWidget {
  final String accessToken;

  const SearchPage({required this.accessToken, super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController searchControl = TextEditingController();
  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchControl,
              decoration: InputDecoration(
                hintText: 'Search for tracks, albums, and artists...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (searchControl.text.isNotEmpty) {
                      search(searchControl.text);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final item = results[index];
                  String imageUrl = '';
                  if (item['type'] == 'track') {
                    imageUrl = item['album']['images'].isNotEmpty
                        ? item['album']['images'][0]['url']
                        : '';
                  } else if (item['type'] == 'album') {
                    imageUrl = item['images'].isNotEmpty
                        ? item['images'][0]['url']
                        : '';
                  } else if (item['type'] == 'artist') {
                    imageUrl = item['images'].isNotEmpty
                        ? item['images'][0]['url']
                        : '';
                  }
                  return ListTile(
                    leading: imageUrl.isNotEmpty
                        ? ClipRRect(
                            child: Image.network(
                              imageUrl,
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          )
                        : const Icon(Icons.music_note),
                    title: Text(item['name']),
                    subtitle: Text(item['type'] == 'track'
                        ? item['artists']
                            .map((artist) => artist['name'])
                            .join(', ')
                        : item['type'] == 'album'
                            ? item['artists']
                                .map((artist) => artist['name'])
                                .join(', ')
                            : ''),
                    onTap: () {
                      if (item['type'] == 'track') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlayerPage(
                                    trackID: item['id'],
                                    trackIndex: index,
                                    accessToken: widget.accessToken)));
                      } else if (item['type'] == 'album') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AlbumPage(
                                    accessToken: widget.accessToken,
                                    albumID: item['id'])));
                      } else if (item['type'] == 'artist') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ArtistPage(
                                    artistID: item['id'],
                                    accessToken: widget.accessToken)));
                      }
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

  Future<void> search(String query) async {
    setState(() {
      results = [];
    });

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$query&type=track,album,artist&limit=5'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        results = data['tracks']['items'] +
            data['albums']['items'] +
            data['artists']['items'];
      });
    } else {
      print('Failed to search: ${response.statusCode}');
    }
  }
}
