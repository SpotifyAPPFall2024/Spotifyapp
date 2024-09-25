import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  final List<dynamic> searchResults;

  const SearchPage({Key? key, required this.searchResults}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Results"),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          final playlist = searchResults[index];
          final title = playlist['name'];
          final imageUrl = playlist['images'][0]['url'];

          return ListTile(
            leading: Image.network(imageUrl),
            title: Text(title),
            onTap: () {
              // Handle what happens when the playlist is clicked
            },
          );
        },
      ),
    );
  }
}
