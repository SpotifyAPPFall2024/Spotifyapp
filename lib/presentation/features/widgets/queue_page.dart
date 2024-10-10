import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:collection';
import 'package:flutter/material.dart';
import '../../../core/utils/authentication_service.dart';

class QueuePage extends StatefulWidget {
  final String trackID;
  final String accessToken;

  QueuePage({required this.trackID, required this.accessToken, super.key});

  @override
  QueuePageState createState() => QueuePageState();
}

class QueuePageState extends State<QueuePage> {
  Map<String, dynamic>? trackDetails;
  String? playlistId;
  
  Queue<Map<String, dynamic>> currentQueue = Queue();

  @override
  void initState() {
    super.initState();
    fetchTrackDetails();
    fetchOrCreatePlaylist(); // Fetch or create playlist when page initializes
  }

  @override
  Widget build(BuildContext context) {
    if (trackDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final trackTitle = trackDetails!['name'];
    final artistName = trackDetails!['artists'][0]['name'];
    final albumArt = trackDetails!['album']['images'][0]['url'];
    final trackUri = trackDetails!['uri'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Up Next'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Now Playing:',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    title: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            albumArt,
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trackTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                artistName,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (playlistId != null) {
                        await addToPlaylist(trackUri);
                        addToQueue({
                          'title': trackTitle,
                          'artist': artistName,
                          'albumArt': albumArt,
                          'uri': trackUri,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$trackTitle added to playlist and queue')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Playlist not available')),
                        );
                      }
                    },
                    child: const Text('Add to Playlist'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Current Queue:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  ...currentQueue.map((track) => ListTile(
                    leading: Image.network(track['albumArt'], width: 30, height: 30),
                    title: Text(track['title']),
                    subtitle: Text(track['artist']),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchTrackDetails() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/tracks/${widget.trackID}'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        trackDetails = json.decode(response.body);
      });
    } else {
      print('Failed to load track details');
    }
  }

  // Fetch or create playlist
  Future<void> fetchOrCreatePlaylist() async {
    final userResponse = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (userResponse.statusCode == 200) {
      final userId = json.decode(userResponse.body)['id'];
      // Try to fetch the playlist or create a new one
      final playlistResponse = await http.post(
        Uri.parse('https://api.spotify.com/v1/users/$userId/playlists'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': 'Clicked Songs',
          'description': 'Songs you clicked on in the queue',
          'public': false,
        }),
      );

      if (playlistResponse.statusCode == 201) {
        setState(() {
          playlistId = json.decode(playlistResponse.body)['id'];
        });
      } else {
        print('Failed to create or fetch playlist');
      }
    }
  }

  // Add track to playlist
  Future<void> addToPlaylist(String trackUri) async {
    if (playlistId != null) {
      final response = await http.post(
        Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
        headers: {
          'Authorization': 'Bearer ${widget.accessToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'uris': [trackUri],
        }),
      );

      if (response.statusCode == 201) {
        print('Track added to playlist');
      } else {
        print('Failed to add track to playlist');
      }
    }
  }

  // Add track to queue
  void addToQueue(Map<String, dynamic> track) {
    setState(() {
      currentQueue.add(track);
    });
  }
}
