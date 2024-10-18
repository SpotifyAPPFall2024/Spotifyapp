import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:spotifyapp/common/helpers/dark_mode.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/presentation/home/page/library_page.dart';
import 'package:spotifyapp/presentation/home/page/player_page.dart';
import 'package:spotifyapp/presentation/home/page/search_page.dart';
import 'package:spotifyapp/presentation/home/page/popup_screen.dart';

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

  bool _isQueueVisible = false;
  bool _isPopupVisible = false;

  void _togglePopup() {
    setState(() {
      _isPopupVisible = !_isPopupVisible;
    });
  }

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
                  ? const Color(0xFF1DB954)
                  : const Color(0xFF191414),
            ),
          ),
          IconButton( // Queue Icon
            onPressed: _togglePopup,
            icon:Icon (
              Icons.queue_music,
              color: context.isDarkMode
                ? const Color(0xFF1DB954)
                : const Color(0xFF191414),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          buildBody(),
          PopupScreen(isVisible: _isPopupVisible,
          accessToken: widget.accessToken,
          playlistID: '44ydl0IWV156LjtcFKDrep',
          ),
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
}