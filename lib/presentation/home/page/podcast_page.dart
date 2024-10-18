import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:spotifyapp/presentation/features/widgets/podcast_player.dart';

class PodcastPage extends StatefulWidget {
  final String showID;
  final String accessToken;

  const PodcastPage({required this.showID, required this.accessToken, super.key});

  @override
  podcastPageState createState() => podcastPageState();
}

class podcastPageState extends State<PodcastPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Podcast Episodes')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPodcastEpisodes(widget.showID, widget.accessToken),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final episodes = snapshot.data!;
            return ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (context, index) {
                final episode = episodes[index];
                return ListTile(
                    title: Text(episode['name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PodcastPlayer(
                            showID: episode['id'] ?? '',
                            showIndex: index,
                            accessToken: widget.accessToken,
                          ),
                        ),
                      );
                    });
              },
            );
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchPodcastEpisodes(
      String showID, String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/shows/$showID/episodes'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['items'];
    } else {
      throw Exception('Failed to load podcast episodes');
    }
  }
}
