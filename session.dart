import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotifyapp/presentation/features/widgets/collab.dart';
import 'create.dart';
import 'join.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

class SessionScreen extends StatefulWidget {
  final String userName;
  final String sessionId;

  const SessionScreen({required this.userName, required this.sessionId});

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final CreateSessionService createSessionService = CreateSessionService(firestore: FirebaseFirestore.instance);
  final JoinSessionService joinSessionService = JoinSessionService(firestore: FirebaseFirestore.instance);

  String? activeSessionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                createSessionService.createSession(widget.userName, context, (sessionId) {
                  setState(() {
                    activeSessionId = sessionId;
                    // Navigate to the session screen or show it on the same screen
                  });
                });
              },
              child: Text('Create Session'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                TextEditingController sessionIdController = TextEditingController();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('Join Session'),
                      content: TextField(
                        controller: sessionIdController,
                        decoration: InputDecoration(hintText: 'Enter Session ID'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            String sessionId = sessionIdController.text.trim();
                            if (sessionId.isNotEmpty) {
                              Navigator.of(context).pop(); // Close the dialog
                              joinSessionService.joinSession(sessionId, widget.userName, context, () {
                                setState(() {
                                  activeSessionId = sessionId;
                                  // Navigate to the session screen or show it on the same screen
                                });
                              });
                            }
                          },
                          child: Text('Join'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Join Session'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> addSongToSession(String sessionId, Map<String, dynamic> track, BuildContext context, String user) async {
  DocumentReference sessionDoc = firestore.collection('sessions').doc(sessionId);

  try {
    await sessionDoc.update({
      'songs': FieldValue.arrayUnion([track]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$user added ${track['name']} to the playlist')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add song: $e')),
    );
  }
}



Future<void> createPlaylistFromDatabase(String sessionId, BuildContext context, String acc) async {
  final sessionDoc = await firestore.collection('sessions').doc(sessionId).get();

  if (sessionDoc.exists) {
    final sessionData = sessionDoc.data() as Map<String, dynamic>;
    List songs = sessionData['songs'];

    // Call Spotify API to create a playlist and add the songs.
    // You should have an access token available here to do this.
    final playlistId = await createSpotifyPlaylist('Collaborative Playlist', acc);

    for (var song in songs) {
      await addTrackToSpotifyPlaylist(playlistId, song['uri'], acc);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Playlist created successfully!')),
    );
  }
}

Future<String> createSpotifyPlaylist(String playlistName, String accessToken) async {
  final url = 'https://api.spotify.com/v1/me/playlists';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'name': playlistName,
      'description': 'A playlist created from collaborative session',
      'public': false,
    }),
  );

  if (response.statusCode == 201) {
    final data = jsonDecode(response.body);
    return data['id'];
  } else {
    throw Exception('Failed to create Spotify playlist: ${response.body}');
  }
}

Future<void> addTrackToSpotifyPlaylist(String playlistId, String trackUri, String accessToken) async {
  final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'uris': [trackUri],
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Failed to add track to Spotify playlist: ${response.body}');
  }
}

Widget buildSessionPlaylist(String sessionId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('sessions').doc(sessionId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error loading session data.'));
        }
        if (snapshot.hasData && snapshot.data != null) {
          var sessionData = snapshot.data!.data() as Map<String, dynamic>;
          List songs = sessionData['songs'] ?? [];

          return ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(songs[index]['name']),
                subtitle: Text(songs[index]['artist']),
              );
            },
          );
        } else {
          return Center(child: Text('No songs found.'));
        }
      },
    );
  }
