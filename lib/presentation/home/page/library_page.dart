import 'package:flutter/material.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';

import '../../../common/widgets/playlistspage/playlist_tile.dart';
import '../../../core/utils/create_section.dart';

class LibraryPage extends StatefulWidget {
  final String accessToken;

  const LibraryPage({required this.accessToken, super.key});

  @override
  LibraryPageState createState() => LibraryPageState();
}

class LibraryPageState extends State<LibraryPage> {
  late Future<List<dynamic>> playlists;
  late Future<List<dynamic>> albums;
  late Future<List<dynamic>> artists;

  @override
  void initState() {
    super.initState();
    playlists = AuthenticationService().fetchPlaylists(widget.accessToken);
    albums = AuthenticationService().fetchAlbums(widget.accessToken);
    artists = AuthenticationService().fetchArtists(widget.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(50.0),
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
        //     child: TextField(
        //       decoration: InputDecoration(
        //         hintText: 'Search',
        //         filled: true,
        //         fillColor: Colors.black,
        //         border: OutlineInputBorder(
        //           borderRadius: BorderRadius.circular(30.0),
        //           borderSide: BorderSide.none,
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<dynamic>>(
              future: playlists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SectionEmpty(title: 'Playlists');
                } else {
                  return Section(
                    title: 'Playlists',
                    itemBuilder: (context, index) {
                      final playlist = snapshot.data![index];
                      return PlaylistTile(
                        name: playlist['name'],
                        imageUrl: playlist['images'].isNotEmpty
                            ? playlist['images'][0]['url']
                            : 'https://via.placeholder.com/150',
                        id: playlist['id'],
                        accessToken: widget.accessToken,
                        type: 'playlist',
                      );
                    },
                    itemCount: snapshot.data!.length,
                  );
                }
              },
            ),
            FutureBuilder<List<dynamic>>(
              future: artists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SectionEmpty(title: 'Artists');
                } else {
                  return Section(
                    title: 'Artists',
                    itemBuilder: (context, index) {
                      final artist = snapshot.data![index];
                      return PlaylistTile(
                        name: artist['name'],
                        imageUrl: artist['images'].isNotEmpty
                            ? artist['images'][0]['url']
                            : 'https://via.placeholder.com/150',
                        id: artist['id'],
                        accessToken: widget.accessToken,
                        type: 'artist',
                      );
                    },
                    itemCount: snapshot.data!.length,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
