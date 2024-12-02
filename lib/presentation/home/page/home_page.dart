import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/helpers/dark_mode.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/presentation/features/widgets/collab.dart';
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

class _HomePageState extends State<HomePage> {
  int currentNavigation = 0;
  late Future<List<dynamic>> featuredPlaylist;
  late Future<List<dynamic>> recentPlays;
  late Future<List<dynamic>> topMixes;
  late Future<List<dynamic>> jumpBackIn;

  @override
  void initState() {
    super.initState();
    featuredPlaylist =
        AuthenticationService().fetchFeaturedPlaylist(widget.accessToken);
    recentPlays = AuthenticationService().fetchRecentPlays(widget.accessToken);
    topMixes = AuthenticationService().fetchTopMixes(widget.accessToken);
    jumpBackIn = AuthenticationService().fetchJumpBackIn(widget.accessToken);
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
        ],
      ),
      body: buildBody(),
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
          NavigationDestination(
            selectedIcon: Icon(Icons.library_music),
            icon: Icon(Icons.handshake_outlined),
            label: 'Collab Playlist',
          ),
        ],
      ),
    );
  }

  Widget buildBody() {
    switch (currentNavigation) {
      case 0: // Home
        return buildHomeContent();
      case 1: // Search
        return SearchPage(accessToken: widget.accessToken);
      case 2: // Your Library
        return LibraryPage(accessToken: widget.accessToken);
      case 3: //Collab Feature
        return CollabPage(
          userName:
              'YOUR_USER_NAME', // Replace with actual username variable if available
          userFollowers:
              'YOUR_FOLLOWERS_COUNT', // Replace with actual followers variable if available
          accessToken: widget.accessToken,
        );
      default:
        return Container();
    }
  }

  Widget buildHomeContent() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        buildSectionTitle('Recommended Plays'),
        FutureBuilder<List<dynamic>>(
          future: topMixes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No recommended plays available'));
            } else {
              final data = snapshot.data!;
              return buildGrid(data);
            }
          },
        ),
        const SizedBox(height: 24),
        buildSectionTitle('Recent Plays'),
        FutureBuilder<List<dynamic>>(
          future: recentPlays,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No recent plays available'));
            } else {
              final data = snapshot.data!;
              return buildGrid(data);
            }
          },
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildGrid(List<dynamic> tracks) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track =
            tracks[index]['track'] ?? tracks[index]; // Adjust as needed
        return buildTrackCard(track);
      },
    );
  }

  Widget buildTrackCard(dynamic track) {
    final imageUrl = track['album']?['images']?.first?['url'];
    final trackID = track['id'];
    if (track == null) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {
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
