import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotifyapp/common/helpers/dark_mode.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import '../../../core/configs/assets/app_vector.dart';

class HomePage extends StatefulWidget {
  final String accessToken;

  const HomePage({required this.accessToken, super.key});
  @override
  homeState createState() => homeState();
}

class homeState extends State<HomePage> {
  late Future<List<dynamic>> featuredPlaylist;

  @override
  void initState() {
    super.initState();
    featuredPlaylist =
        AuthenticationService().fetchFeaturedPlaylist(widget.accessToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.isDarkMode
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        elevation: 0,
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
            ),
            onPressed: () {},
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: context.isDarkMode
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.03),
            ),
          ),
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
      body: FutureBuilder(
        future: featuredPlaylist,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final playlists = snapshot.data!;
            return Column(
              children: [
                Container(
                  height: 200,
                  color: Colors.grey[900],
                  child: PageView(
                    children: playlists.map<Widget>((playlist) {
                      final imageUrl = playlist['images'][0]['url'];
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      final title = playlist['name'];
                      final imageUrl = playlist['images'][0]['url'];
                      return buildPlaylist(title, imageUrl, context);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildPlaylist(String title, String imageUrl, BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Image.network(imageUrl),
        title: Text(title, style: const TextStyle(fontSize: 18)),
        onTap: () {},
      ),
    );
  }
}
