// import 'package:flutter/material.dart';
// import 'package:spotifyapp/core/utils/authentication_service.dart';

// class LibraryPage extends StatefulWidget {
//   final String accessToken;

//   const LibraryPage({required this.accessToken, super.key});

//   @override
//   libraryPageState createState() => libraryPageState();
// }

// class libraryPageState extends State<LibraryPage> {
//   late Future<List<dynamic>> playlists;

//   @override
//   void initState() {
//     super.initState();
//     playlists = AuthenticationService().fetchPlaylists(widget.accessToken);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Your Playlists')),
//       body: FutureBuilder<List<dynamic>>(
//         future: playlists,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No playlists found.'));
//           } else {
//             final playlists = snapshot.data!;
//             return ListView.builder(
//               itemCount: playlists.length,
//               itemBuilder: (context, index) {
//                 final playlist = playlists[index];
//                 return ListTile(
//                   title: Text(playlist['name']),
//                   subtitle: Text('${playlist['tracks']['total']} tracks'),
//                   leading: playlist['images'].isNotEmpty
//                       ? Image.network(playlist['images'][0]['url'], width: 50)
//                       : null,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PlaylistDetailPage(
//                             playlistId: playlistId,
//                             accessToken: widget.accessToken),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
