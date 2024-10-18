import 'package:flutter/material.dart';
import 'package:spotifyapp/common/helpers/dark_mode.dart';
import 'package:spotifyapp/common/widgets/playlistspage/playlists_page.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/presentation/features/widgets/podcast_player.dart';
import 'package:spotifyapp/presentation/home/page/album_page.dart';
import 'package:spotifyapp/presentation/home/page/artist_page.dart';
import 'package:spotifyapp/presentation/home/page/player_page.dart';
import 'package:spotifyapp/presentation/home/page/podcast_page.dart';

class SearchPage extends StatefulWidget {
  final String accessToken;

  const SearchPage({required this.accessToken, super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  String searchTerm = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for songs, artists, albums...',
                filled: true,
                fillColor: context.isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.black.withOpacity(0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      searchTerm = '';
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          SearchSection(
            title: 'Songs',
            searchTerm: searchTerm,
            accessToken: widget.accessToken,
            type: 'track',
            isTrack: true,
          ),
          const SizedBox(height: 25),
          SearchSection(
            title: 'Artists',
            searchTerm: searchTerm,
            accessToken: widget.accessToken,
            type: 'artist',
          ),
          const SizedBox(height: 25),
          SearchSection(
            title: 'Albums',
            searchTerm: searchTerm,
            accessToken: widget.accessToken,
            type: 'album',
          ),
          const SizedBox(height: 25),
          SearchSection(
            title: 'Playlists',
            searchTerm: searchTerm,
            accessToken: widget.accessToken,
            type: 'playlist',
          ),
          const SizedBox(height: 25),
          SearchSection(
            title: 'Podcasts',
            searchTerm: searchTerm,
            accessToken: widget.accessToken,
            type: 'show',
          ),
          const SizedBox(height: 25),
          SearchSection(
            title: 'Episodes',
            searchTerm: searchTerm,
            accessToken: widget.accessToken,
            type: 'episode',
          ),
        ],
      ),
    );
  }
}

class SearchSection extends StatelessWidget {
  final String title;
  final String searchTerm;
  final String accessToken;
  final String type;
  final bool isTrack;

  const SearchSection({
    required this.title,
    required this.searchTerm,
    required this.accessToken,
    required this.type,
    this.isTrack = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<dynamic>>(
          future: AuthenticationService()
              .searchSpotify(searchTerm, accessToken, type),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No results found'));
            } else {
              final results = snapshot.data!;
              return SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    final title = result['name'];
                    final imageUrl = isTrack
                        ? result['album']['images'][0]['url']
                        : result['images']?.isNotEmpty == true
                            ? result['images'][0]['url']
                            : 'https://via.placeholder.com/150';

                    return buildResultCard(
                        context, result, index, title, imageUrl);
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget buildResultCard(BuildContext context, dynamic item, int index,
      String title, String imageUrl) {
    return GestureDetector(
      onTap: () {
        if (item['type'] == 'track') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerPage(
                trackID: item['id'],
                trackIndex: 0,
                accessToken: accessToken,
              ),
            ),
          );
        } else if (item['type'] == 'album') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AlbumPage(
                accessToken: accessToken,
                albumID: item['id'],
              ),
            ),
          );
        } else if (item['type'] == 'artist') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArtistPage(
                artistID: item['id'],
                accessToken: accessToken,
              ),
            ),
          );
        } else if (item['type'] == 'playlist') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistsPage(
                playlistID: item['id'],
                accessToken: accessToken,
              ),
            ),
          );
        } else if (item['type'] == 'show') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodcastPage(
                showID: item['id'],
                accessToken: accessToken,
              ),
            ),
          );
        } else if (item['type'] == 'episode') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PodcastPlayer(
                showID: item['id'],
                showIndex: index,
                accessToken: accessToken,
              ),
            ),
          );
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 180,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
