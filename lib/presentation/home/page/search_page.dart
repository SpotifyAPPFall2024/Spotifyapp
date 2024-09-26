import 'package:flutter/material.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';

class SearchPage extends StatelessWidget {
  final String searchTerm;
  final String accessToken;

  const SearchPage({required this.searchTerm, required this.accessToken, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      appBar: AppBar(
        title: Text('Search Results for "$searchTerm"'), 
        /*leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen (HomePage)
          },
        ),*/
      ),
      */
      body: ListView(
        padding: const EdgeInsets.all(25.0),
        children: [
          SearchSection(
            title: 'Songs',
            searchTerm: searchTerm,
            accessToken: accessToken,
            type: 'track',
            isTrack: true,
          ),
          const SizedBox(height: 25),

          SearchSection(
            title: 'Artists',
            searchTerm: searchTerm,
            accessToken: accessToken,
            type: 'artist',
          ),
          const SizedBox(height: 25),

          SearchSection(
            title: 'Albums',
            searchTerm: searchTerm,
            accessToken: accessToken,
            type: 'album',
          ),
          const SizedBox(height: 25),

          SearchSection(
            title: 'Playlists',
            searchTerm: searchTerm,
            accessToken: accessToken,
            type: 'playlist',
          ),
          const SizedBox(height: 25),

          SearchSection(
            title: 'Podcasts',
            searchTerm: searchTerm,
            accessToken: accessToken,
            type: 'show',
          ),
          const SizedBox(height: 25),

          SearchSection(
            title: 'Episodes',
            searchTerm: searchTerm,
            accessToken: accessToken,
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold), //Text for section
        ),
        const SizedBox(height: 20),
        FutureBuilder<List<dynamic>>(
          future: AuthenticationService().searchSpotify(searchTerm, accessToken, type),
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

                    return buildResultCard(title, imageUrl);
                  },
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget buildResultCard(String title, String imageUrl) {
    return Container(
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
    );
  }
}