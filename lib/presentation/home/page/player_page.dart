import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerPage extends StatefulWidget {
  final String trackID;
  final int trackIndex;
  final String accessToken;

  PlayerPage(
      {required this.trackID,
      required this.trackIndex,
      required this.accessToken,
      super.key});

  @override
  playerPageState createState() => playerPageState();
}

class playerPageState extends State<PlayerPage> {
  Map<String, dynamic>? trackDetails;
  late AudioPlayer audio;
  late int currentIndex;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    audio = AudioPlayer();
    currentIndex = widget.trackIndex;
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
    fetchTrackDetails();
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
      await playTrack();
    } else {
      print('Failed to load track details');
    }
  }

  Future<void> playTrack() async {
    if (trackDetails != null) {
      final preview = trackDetails!['preview_url'];
      if (preview != null) {
        await audio.setUrl(preview);
        await audio.play();
      } else {
        print('No preview available for this track');
      }
    }
  }

  Future<void> skip() async {
    if (currentIndex < widget.trackID.length - 1) {
      setState(() {
        currentIndex++;
      });
      await fetchTrackDetails();
    }
  }

  Future<void> previous() async {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
      await fetchTrackDetails();
    }
  }

  @override
  void dispose() {
    audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (trackDetails == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final trackTitle = trackDetails!['name'];
    final artistName = trackDetails!['artists'][0]['name'];
    final albumArt = trackDetails!['album']['images'][0]['url'];

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
              trackTitle,
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
            )
          ],
        ));
  }
}
