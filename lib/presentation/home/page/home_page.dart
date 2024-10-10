import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:spotifyapp/common/helpers/dark_mode.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/presentation/home/page/library_page.dart';
import 'package:spotifyapp/presentation/home/page/player_page.dart';
import 'package:spotifyapp/presentation/home/page/search_page.dart';

import '../../../core/configs/assets/app_vector.dart';

class HomePage extends StatefulWidget {
  final String accessToken;

  const HomePage({required this.accessToken, super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int currentNavigation = 0;
  late Future<List<dynamic>> featuredPlaylist;
  late Future<List<dynamic>> recentPlays;
  late Future<List<dynamic>> topMixes;
  late Future<List<dynamic>> jumpBackIn;

  late AnimationController _queueController;
  late Animation<double> _queueAnimation;
  bool _isQueueVisible = false;

  @override
  void initState() {
    super.initState();
    featuredPlaylist = AuthenticationService().fetchFeaturedPlaylist(widget.accessToken);
    recentPlays = AuthenticationService().fetchRecentPlays(widget.accessToken);
    topMixes = AuthenticationService().fetchTopMixes(widget.accessToken);
    jumpBackIn = AuthenticationService().fetchJumpBackIn(widget.accessToken);

    _queueController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _queueAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _queueController,
      curve: Curves.easeInOut,
    ));
  }
  
  Future<void> addToQueue(String trackUri, String accessToken) async {
    final response = await http.post(
      Uri.parse('https://api.spotify.com/v1/me/player/queue?uri=$trackUri'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 204) {
      print('Song added to queue');
    } else {
      throw Exception('Failed to add song to queue');
    }
  }

  @override
  void dispose() {
    _queueController.dispose();
    super.dispose();
  }

  void _toggleQueue() {
    setState(() {
      _isQueueVisible = !_isQueueVisible;
      if (_isQueueVisible) {
        _queueController.forward();
      } else {
        _queueController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 30,
          width: 30,
        ),
        backgroundColor: context.isDarkMode
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.account_circle,
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
            ),
          ),
          IconButton( // Queue Icon
            onPressed: _toggleQueue,
            icon: const Icon(Icons.queue_music),
          ),
        ],
      ),
      body: Stack(
        children: [
          buildBody(),
          _buildQueuePopup(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentNavigation = index;
          });
        },
        indicatorColor: Colors.green,
        selectedIndex: currentNavigation,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.search),
            icon: Icon(Icons.search_outlined),
            label: 'Search',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.library_music),
            icon: Icon(Icons.library_music_outlined),
            label: 'Your Library',
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    switch (currentNavigation) {
      case 0:
        return buildHomeContent();
      case 1:
        return SearchPage(accessToken: widget.accessToken);
      case 2:
        return LibraryPage(accessToken: widget.accessToken);
      default:
        return Container();
    }
  }

  Widget buildHomeContent() {
    return FutureBuilder(
      future: featuredPlaylist,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final playlists = snapshot.data!;
          return ListView(
            children: [
              Container(
                height: 200,
                color: Colors.black,
                child: PageView(
                  children: playlists.map<Widget>((playlist) {
                    final imageUrl = playlist['images'][0]['url'];
                    return Image.network(imageUrl, fit: BoxFit.contain);
                  }).toList(),
                ),
              ),
              buildSection('Recent Plays', recentPlays),
            ],
          );
        }
      },
    );
  }

  Widget buildSection(String title, Future<List<dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FutureBuilder<List<dynamic>>(
            future: items,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final data = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final track = data[index]['track'];
                    return track != null
                        ? buildTrackCard(track)
                        : const SizedBox();
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildTrackCard(dynamic track) {
  final imageUrl = track['album']?['images']?.first?['url'];
  final trackID = track['id'];
  final trackUri = track['uri'];  // Spotify track URI

  return GestureDetector(
    onTap: () {
      // Add the selected track to the queue
      addToQueue(trackUri, widget.accessToken);

      // Optionally navigate to the player page if needed
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayerPage(
            trackID: trackID,
            trackIndex: 0,
            accessToken: widget.accessToken,
          ),
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(child: Icon(Icons.error))),
                )
              : const SizedBox(
                  width: 100,
                  height: 100,
                  child: Center(child: Text('No Image'))),
        ),
        const SizedBox(height: 4),
        Text(
          track['name'],
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          track['artists']?.map((artist) => artist['name']).join(', ') ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    ),
  );
}


  Widget _buildQueuePopup() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width * 0.23,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start off-screen to the right
          end: Offset.zero, // End at the right edge of the screen
        ).animate(_queueAnimation),
        child: Material(
          color: Colors.white,
          elevation: 8.0,
          child: QueuePage(
            accessToken: widget.accessToken,
          ),
        ),
      ),
    );
  }
}


class QueuePage extends StatefulWidget {
  final String accessToken;

  const QueuePage({required this.accessToken, super.key});

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  late Future<List<dynamic>> playlistTracks;

  @override
  void initState() {
    super.initState();
    // Replace this with the actual ID of your "Current Queue Playlist"
    playlistTracks = fetchPlaylistTracks('334XjplzpRA3CSVdbKtoPr', widget.accessToken);
  }

  Future<List<dynamic>> fetchPlaylistTracks(String playlistId, String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/playlists/$playlistId/tracks'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['items'];
    } else {
      throw Exception('Failed to load playlist tracks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Queue Playlist'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: playlistTracks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No songs in the playlist'));
          } else {
            final tracks = snapshot.data!;
            return ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index]['track'];
                final trackName = track['name'];
                final artistName = track['artists'][0]['name'];
                final albumArt = track['album']['images'][0]['url'];

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      albumArt,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(trackName),
                  subtitle: Text(artistName),
                );
              },
            );
          }
        },
      ),
    );
  }
}
