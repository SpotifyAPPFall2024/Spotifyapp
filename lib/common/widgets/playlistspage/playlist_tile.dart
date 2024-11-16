import 'package:flutter/material.dart';
import 'package:spotifyapp/common/widgets/playlistspage/playlists_page.dart';
import 'package:spotifyapp/presentation/home/page/artist_page.dart';

class PlaylistTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String id;
  final String accessToken;
  final String type;

  const PlaylistTile(
      {super.key,
      required this.name,
      required this.imageUrl,
      required this.id,
      required this.accessToken,
      required this.type});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (type == 'playlist') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PlaylistsPage(accessToken: accessToken, playlistID: id),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ArtistPage(accessToken: accessToken, artistID: id),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
