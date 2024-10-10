import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:spotifyapp/presentation/features/widgets/queue_page.dart';

class PodcastPlayer extends StatefulWidget {
  final String showID;
  final int showIndex;
  final String accessToken;

  PodcastPlayer(
      {required this.showID,
      required this.showIndex,
      required this.accessToken,
      super.key});

  @override
  podcastPlayerState createState() => podcastPlayerState();
}

class podcastPlayerState extends State<PodcastPlayer> {
  Map<String, dynamic>? showDetails;
  late AudioPlayer audio;
  late int currentIndex;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    audio = AudioPlayer();
    currentIndex = widget.showIndex;
    audio.positionStream.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });

    audio.durationStream.listen((newDuration) {
      setState(() {
        duration = newDuration ?? Duration.zero;
      });
    });
    fetchPodcastDetails();
  }

  Future<void> fetchPodcastDetails() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/episodes/${widget.showID}'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        showDetails = json.decode(response.body);
      });
      await playPodcast();
    } else {
      print('Failed to load podcast episodes');
    }
  }

  Future<void> playPodcast() async {
    if (showDetails != null) {
      final preview = showDetails!['audio_preview_url'];
      if (preview != null) {
        await audio.setUrl(preview);
        await audio.play();
      } else {
        print('No preview available for this podcast');
      }
    }
  }

  Future<void> skip() async {
    if (currentIndex < widget.showID.length - 1) {
      setState(() {
        currentIndex++;
      });
      await fetchPodcastDetails();
    }
  }

  Future<void> previous() async {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      await fetchPodcastDetails();
    }
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final showTitle = showDetails!['name'];
    final artistName = showDetails!['show']['name'];
    final albumArt = showDetails!['images'][0]['url'];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Now Playing'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(albumArt,
                  width: 300, height: 300, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            Text(
              showTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              artistName,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            Slider(
              value: position.inSeconds.toDouble(),
              min: 0,
              max: duration.inSeconds.toDouble() > 0
                  ? duration.inSeconds.toDouble()
                  : 1,
              onChanged: (value) {
                final newPosition = Duration(seconds: value.toInt());
                audio.seek(newPosition);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () async {
                    if (audio.playing) {
                      await audio.pause();
                    } else {
                      await audio.play();
                    }
                  },
                  icon: Icon(audio.playing ? Icons.pause : Icons.play_arrow),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.skip_next),
                  iconSize: 30,
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite),
                  iconSize: 15,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QueuePage(
                          trackID: showDetails!['id'],
                          accessToken: widget.accessToken,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_outlined),
                  iconSize: 15,
                ),
              ],
            )
          ],
        ));
  }
}
