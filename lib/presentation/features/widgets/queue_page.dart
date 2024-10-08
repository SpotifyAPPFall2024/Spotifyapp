import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    fetchTrackDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (trackDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final trackTitle = trackDetails!['name'];
    final artistName = trackDetails!['artists'][0]['name'];
    final albumArt = trackDetails!['album']['images'][0]['url'];
    final trackUri = trackDetails!['uri']; // Get the track URI

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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      final authService = AuthenticationService();
                      await authService.addToQueue(
                          widget.accessToken, trackUri);
                    },
                    child: const Text('Add to Queue'),
                  ),
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
      //await playTrack();
    } else {
      print('Failed to load track details');
    }
  }
}
