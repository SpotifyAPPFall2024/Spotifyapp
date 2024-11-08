import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PopupScreen extends StatefulWidget {
  final bool isVisible;
  final String accessToken;
  final String playlistID;

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

    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(CurvedAnimation(
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
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  Future<List<dynamic>> fetchPlaylistTracks() async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/${widget.playlistID}/tracks'),
      headers: {
        'Authorization': 'Bearer ${widget.accessToken}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['items'] != null) {
        return data['items'];
      } else {
        throw Exception('No items found in playlist');
      }
    } else {
      throw Exception('Failed to load playlist tracks');
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
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(MediaQuery.of(context).size.width * _animation.value, 0), // Slide from right
          child: Visibility(
            visible: widget.isVisible,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2, // 2/5 of the screen
              height: MediaQuery.of(context).size.height, // Full height
              color: Colors.grey[850], // Solid black background
              child: FutureBuilder<List<dynamic>>(
                future: fetchPlaylistTracks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No tracks available'));
                  } else {
                    final tracks = snapshot.data!;
                    return ListView.builder(
                      itemCount: tracks.length,
                      itemBuilder: (context, index) {
                        final track = tracks[index]['track'];
                        return track != null
                            ? ListTile(
                                title: Text(track['name'] ?? 'Unknown Track'),
                                subtitle: Text(
                                    track['artists']?.isNotEmpty == true
                                        ? track['artists'][0]['name']
                                        : 'Unknown Artist' ?? 'Unknown Artist'),
                              )
                            : const SizedBox(); // Handle null track case
                      },
                    );
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
