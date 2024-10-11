import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PopupScreen extends StatefulWidget {
  final bool isVisible;
  final String playlistID;
  final String accessToken;

  const PopupScreen({
    required this.isVisible,
    required this.accessToken,
    required this.playlistID,
    super.key,
  });

  @override
  _PopupScreenState createState() => _PopupScreenState();
}

class _PopupScreenState extends State<PopupScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 2 / 7).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PopupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            heightFactor: 1,
            widthFactor: _animation.value,
            child: Container(
              color: Colors.black.withOpacity(0.6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white24)),
                    ),
                    child: Text(
                      'Current Queue Playlist',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Content section to display songs
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: fetchPlaylistTracks(widget.accessToken,widget.playlistID), // Use the fetch method directly
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No songs available', style: TextStyle(color: Colors.white70)));
                        }

                        // Display the list of songs
                        List<dynamic> songs = snapshot.data!;
                        return ListView.builder(
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                songs[index]['name'],
                                style: TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                songs[index]['artists'].map((artist) => artist['name']).join(', '),
                                style: TextStyle(color: Colors.white70),
                              ),
                            ); // Adjust this to match your data structure
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Future<List<dynamic>> fetchPlaylistTracks(
      String accessToken, String playlistID) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistID/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load tracks ${response.statusCode}');
    }
  }
}


