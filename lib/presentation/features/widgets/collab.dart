import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/authentication_service.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create.dart';
import 'join.dart';
import 'session.dart';

//create/join session hosted in other files
final CreateSessionService createSessionService =
    CreateSessionService(firestore: FirebaseFirestore.instance);
final JoinSessionService joinSessionService =
    JoinSessionService(firestore: FirebaseFirestore.instance);
//uuid for generating session id, ended up going with 6 code digit
const Uuid uuid = Uuid();
//access to firebase database
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class CollabPage extends StatefulWidget {
  final String userName;
  final String userFollowers;
  final String accessToken;

  const CollabPage(
      {required this.userName,
      required this.userFollowers,
      required this.accessToken,
      super.key});

  @override
  CollabPageState createState() => CollabPageState();
}

class CollabPageState extends State<CollabPage> {
  Map<String, dynamic>? userInfo; //holds user data
  List<dynamic> searchResults = []; //keeps track of what user searched up
  TextEditingController userInput = TextEditingController();

  ///handles input from user, used to search up songs
  TextEditingController userPlaylistName =
      TextEditingController(); //names collab playlist
  List<dynamic> userPlaylists = []; //holds users' playlist
  List<dynamic> playlistContents = []; //holds contents of user playlist
  String? collabPlaylistID;
  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  @override
  void dispose() {
    userInput.dispose();
    userPlaylistName.dispose();
    super.dispose();
  }

  String? activeSessionId;
  Stream<DocumentSnapshot>?
      sessionStream; //meant to constantly communicate with database and establish a session

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Create and view your collab playlists!'),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.library_music),
                  onPressed: () {
                    fetchUserPlaylists();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    promptForPlaylistName();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.group),
                  onPressed: () {
                    showSessionDialog(context, widget.userName);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: activeSessionId != null
            ? StreamBuilder<DocumentSnapshot>(
                stream: sessionStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    //if user is waiting for someone to join, user is prompted with a display with a loading circle
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading session.'));
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    //if session is able to be created, display info about users in session
                    var sessionData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List users = sessionData['users'];
                    List songs = sessionData['songs'];

                    return Column(
                      //display info on the current session
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Session ID: $activeSessionId',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16.0),
                        Text('Users in Session:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...users.map((user) => Text(user)),
                        const SizedBox(height: 16.0),
                        Text('Playlist:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ListView.builder(
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(songs[index]['name']),
                                subtitle: Text(songs[index]['artist']),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  return Center(child: Text('Waiting for someone to join...'));
                },
              )
            : Column(
                //user is able to search for songs
                children: [
                  // Search field
                  TextField(
                    controller: userInput,
                    decoration: InputDecoration(
                      labelText: 'Search for songs',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (query) {
                      searchSongs(query);
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Display search results
                  searchResults.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: searchResults.length,
                            itemBuilder: (context, index) {
                              final track = searchResults[index];
                              final trackName = track?['name'] ?? 'Unnamed';
                              final artistName = track?['artists']?[0]
                                      ['name'] ??
                                  'Unknown Artist';
                              final albumArtUrl = track?['album']?['images']?[0]
                                      ['url'] ??
                                  'default_image_url'; // You can use a default URL or a local asset for missing images
                              final trackUri = track?['uri'] ??
                                  'default_uri'; // Provide a default URI if it's null

                              return ListTile(
                                leading: albumArtUrl.isNotEmpty
                                    ? Image.network(
                                        albumArtUrl,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.music_note),
                                title: Text(trackName),
                                subtitle: Text(artistName),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    //able to add songs to database once session established
                                    if (activeSessionId == null) {
                                      // addToCollaborativePlaylist(
                                      //     collabPlaylistID!, trackUri);
                                      addTrackToSpotifyPlaylist(
                                          collabPlaylistID!,
                                          trackUri,
                                          widget.accessToken);
                                      // addSongToSession(
                                      //     activeSessionId!, track, context);
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'You must create or join a session to add songs')),
                                      );
                                    }
                                  },
                                  child: const Text('Add to Playlist'),
                                ),
                              );
                            },
                          ),
                        )
                      : const Expanded(
                          child: Center(
                            child: Text(
                              'Search for songs to display results here.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }

  void promptForPlaylistName() {
    //allows user to enter a playlist name
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Collaborative Playlist'),
          content: TextField(
            controller: userPlaylistName,
            decoration: const InputDecoration(
              hintText: 'Enter playlist name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                //once clicked, collab playlist with given name is created
                final collabName = userPlaylistName.text.trim();
                if (collabName.isNotEmpty) {
                  collabPlaylistID =
                      await createCollaborativePlaylist(collabName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<String> createCollaborativePlaylist(String collabName) async {
    //collab playlist added to list of user's playlists
    collabPlaylistID = collabName;
    final url = 'https://api.spotify.com/v1/users/${userInfo?['id']}/playlists';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': collabName,
        'description': 'A playlist created with my app',
        'public': false,
        'collaborative': true,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collaborative playlist created!')),
      );
      final playlistData = json.decode(response.body);
      return playlistData['id'];
      //print('Collaborative playlist created: ${playlistData['name']}');
    } else {
      throw Exception(
          'Failed to create collaborative playlist. Status code: ${response.statusCode}');
    }
  }

  Future<void> searchSongs(String query) async {
    //enables users to search for songs using Spotify's API
    final url =
        'https://api.spotify.com/v1/search?q=$query&type=track&limit=10';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        searchResults = json.decode(response.body)['tracks']['items'];
      });
    } else {
      print('Failed to search for songs: ${response.statusCode}');
    }
  }

  Future<void> addToCollaborativePlaylist(
      String playlistId, String trackUri) async {
    //meant to add song to given collab playlist
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
      print('Track added to collaborative playlist');
    } else {
      print('Failed to add track: ${response.body}');
    }
  }

  Future<void> fetchUserInfo() async {
    //get user data
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userInfo = json.decode(response.body);
        print(userInfo);
      });
    } else {
      print('Failed to load user information: ${response.statusCode}');
    }
  }

  Future<void> fetchUserPlaylists() async {
    //get user's playlists to be displayed
    const url = 'https://api.spotify.com/v1/me/playlists';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userPlaylists = json.decode(response.body)['items'];
      });
      showUserPlaylistsDialog();
    } else {
      print('Failed to load playlists: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load playlists')),
      );
    }
  }

  void showPlaylistTracksDialog(String playlistName) {
    //show the contents of playlist
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$playlistName Tracks'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlistContents.length,
              itemBuilder: (context, index) {
                final track = playlistContents[index]['track'];

                final trackName = track?['name'] ?? 'Unnamed';
                final artistName =
                    track?['artists']?[0]['name'] ?? 'Unknown Artist';
                final albumArtUrl = track?['album']?['images']?[0]['url'] ??
                    'default_image_url';
                final trackUri = track?['uri'] ?? 'default_uri';

                return ListTile(
                  leading: albumArtUrl != null
                      ? Image.network(
                          albumArtUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.music_note),
                  title: Text(trackName),
                  subtitle: Text(artistName),
                  onTap: () {
                    openSpotifyTrack(trackUri);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openSpotifyTrack(String trackUri) async {
    final trackId =
        trackUri.split(':').last; //extracts trackid from given spotify url
    final spotifyUrl = Uri.parse('https://open.spotify.com/track/$trackId');

    if (await canLaunchUrl(spotifyUrl)) {
      await launchUrl(spotifyUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Spotify')),
      );
    }
  }

  Future<void> fetchPlaylistTracks(
      String playlistId, String playlistName) async {
    final url = 'https://api.spotify.com/v1/playlists/$playlistId/tracks';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        playlistContents = json.decode(response.body)['items'];
      });
      showPlaylistTracksDialog(playlistName);
    } else {
      print('Failed to load playlist tracks: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load playlist tracks')),
      );
    }
  }

  void showUserPlaylistsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Your Playlists'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = userPlaylists[index];
                final playlistName = playlist?['name'] ?? 'Unnamed Playlist';
                final trackCount = playlist?['tracks']?['total'] ?? 0;
                final playlistId = playlist?['id'] ?? 'Unknown ID';
                final isCollaborative = playlist?['collaborative'] ?? false;

                return ListTile(
                  title: Row(
                    children: [
                      Text(playlistName),
                      if (isCollaborative) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.yellow, size: 20),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    trackCount > 0 ? '$trackCount tracks' : 'Empty playlist',
                  ),
                  onTap: () {
                    fetchPlaylistTracks(playlistId, playlistName);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showWaitingDialog(
      BuildContext context, String sessionId, String userName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Stream<DocumentSnapshot> sessionStream =
                firestore.collection('sessions').doc(sessionId).snapshots();

            return StreamBuilder<DocumentSnapshot>(
              stream: sessionStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var sessionData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  var users = List<String>.from(sessionData['users']);

                  if (users.length > 1) {
                    // Close the waiting dialog and show connected screen when another user joins
                    Navigator.of(context).pop();
                    showSessionConnectedScreen(
                        context, sessionId, [widget.userName]);
                  }
                }

                return AlertDialog(
                  title: Text('Waiting for someone to join...'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Session ID: $sessionId'),
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // Cancel the session creation and delete the session from Firestore
                        firestore
                            .collection('sessions')
                            .doc(sessionId)
                            .delete();
                        Navigator.of(context).pop(); // Close the waiting dialog
                      },
                      child: Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void showSessionConnectedScreen(
      BuildContext context, String sessionId, List<String> users) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Session Connected'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session ID: $sessionId', style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Text('Connected Users:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...users
                    .map((user) => Text(user, style: TextStyle(fontSize: 16))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showSessionDialog(BuildContext context, String userName) {
    TextEditingController sessionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Session Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Close the dialog and create a session
                  Navigator.of(context).pop();

                  // Use the createSessionService to create a session
                  createSessionService.createSession(userName, context,
                      (sessionId) {
                    // Handle session creation - You can navigate to the session screen here or update the UI
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionScreen(
                            sessionId: sessionId, userName: userName),
                      ),
                    );
                  });
                },
                child: Text('Create Session'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Show dialog to enter session ID for joining
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Join Session'),
                        content: TextField(
                          controller: sessionController,
                          decoration:
                              InputDecoration(hintText: 'Enter Session ID'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(); // Close the join session dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              String sessionId = sessionController.text.trim();
                              if (sessionId.isNotEmpty) {
                                Navigator.of(context)
                                    .pop(); // Close the join session dialog

                                // Use the joinSessionService to join a session
                                joinSessionService.joinSession(
                                    sessionId, userName, context, () {
                                  // Handle joining the session - Navigate to the session screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SessionScreen(
                                          sessionId: sessionId,
                                          userName: userName),
                                    ),
                                  );
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please enter a valid session ID')),
                                );
                              }
                            },
                            child: const Text('Join'),
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
        );
      },
    );
  }

  Future<void> addUserToSession(
      String sessionId, String userName, BuildContext context) async {
    DocumentReference sessionDoc =
        firestore.collection('sessions').doc(sessionId);

    // Check if the session exists
    DocumentSnapshot sessionSnapshot = await sessionDoc.get();

    if (sessionSnapshot.exists) {
      // Add the user to the participants list
      await sessionDoc.update({
        'users': FieldValue.arrayUnion([userName]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Successfully joined session with ID: $sessionId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session ID does not exist')),
      );
    }
  }

  void showSessionIdDialog(BuildContext context, String sessionId) {
    // Display the session ID to the user in an AlertDialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Session Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your session has been created!'),
              SizedBox(height: 10),
              SelectableText(
                'Session ID: $sessionId',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> searchSpotifyTracks(
      String query, String accessToken) async {
    final url =
        'https://api.spotify.com/v1/search?q=$query&type=track&limit=10';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List tracks = data['tracks']['items'];
      return tracks.map<Map<String, dynamic>>((track) {
        return {
          'name': track['name'],
          'artist': track['artists'][0]['name'],
          'uri': track['uri'],
        };
      }).toList();
    } else {
      throw Exception('Failed to search Spotify tracks');
    }
  }

  Future<void> addSongToSession(String sessionId, Map<String, dynamic> track,
      BuildContext context) async {
    DocumentReference sessionDoc =
        firestore.collection('sessions').doc(sessionId);

    try {
      await sessionDoc.update({
        'songs': FieldValue.arrayUnion([track]),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Song added to session with ID: $sessionId')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add song: $e')),
      );
    }
  }

  Widget buildSessionPlaylist(String sessionId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: firestore.collection('sessions').doc(sessionId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var sessionData = snapshot.data!.data() as Map<String, dynamic>;
          List songs = sessionData['songs'];

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
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void showAddSongDialog(
      BuildContext context, String sessionId, String accessToken) {
    TextEditingController songSearchController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: songSearchController,
                decoration: InputDecoration(hintText: 'Search for a song'),
                onSubmitted: (query) async {
                  try {
                    searchResults =
                        await searchSpotifyTracks(query, accessToken);
                    setState(() {}); // Update UI after getting search results
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to search for songs: $e')),
                    );
                  }
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final track = searchResults[index];
                    return ListTile(
                      title: Text(track['name']),
                      subtitle: Text(track['artist']),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          // addToCollaborativePlaylist(
                          //     collabPlaylistID!, track['uri']);
                          addTrackToSpotifyPlaylist(collabPlaylistID!,
                              track['uri'], widget.accessToken);
                          addSongToSession(sessionId, track['uri'], context);
                          Navigator.of(context)
                              .pop(); // Close dialog after adding song
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
