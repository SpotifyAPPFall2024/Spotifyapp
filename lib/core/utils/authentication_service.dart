import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthenticationService {
  final String clientId;
  final String redirectUri;
  final String scope;

  AuthenticationService({
    this.clientId = '905df89fc43547469d85ece7a82de400',
    this.redirectUri = 'http://localhost:65302/callback',
    //this.redirectUri = 'myappspoof://callback',
    this.scope =
        'user-read-private user-read-email playlist-read-private playlist-modify-private user-read-playback-state user-modify-playback-state user-library-read user-library-modify user-top-read user-read-recently-played user-follow-read',
  });

  String _generateRandomString(int length) {
    const possible =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final values =
        List<int>.generate(length, (i) => random.nextInt(possible.length));
    return values.map((e) => possible[e]).join();
  }

  Future<Uint8List> _sha256(String plain) async {
    final bytes = utf8.encode(plain);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  String _base64UrlEncode(Uint8List input) {
    return base64Url
        .encode(input)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  Future<Uri> getAuthorizationUrl() async {
    final codeVerifier = _generateRandomString(64);
    final hashed = await _sha256(codeVerifier);
    final codeChallenge = _base64UrlEncode(hashed);

    final storage = FlutterSecureStorage();
    await storage.write(key: 'code_verifier', value: codeVerifier);

    return Uri.parse('https://accounts.spotify.com/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': clientId,
        'scope': scope,
        'code_challenge_method': 'S256',
        'code_challenge': codeChallenge,
        'redirect_uri': redirectUri,
      },
    );
  }

  Future<String?> exchangeCodeForToken(String code) async {
    final storage = FlutterSecureStorage();
    final codeVerifier = await storage.read(key: 'code_verifier');

    if (codeVerifier == null) {
      throw Exception('Code verifier is missing');
    }

    final url = Uri.parse('https://accounts.spotify.com/api/token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'code_verifier': codeVerifier,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final accessToken = responseBody['access_token'];
      return accessToken;
    } else {
      print('Failed to exchange code for token: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>> fetchFeaturedPlaylist(String accessToken) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/browse/featured-playlists?limit=10'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['playlists']['items'];
    } else {
      throw Exception(
          'Failed to load featured playlists ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchRecentPlays(String accessToken) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/me/player/recently-played?limit=20'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load recent plays ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchTopMixes(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/top/tracks?limit=15'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load top mixes ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchPlaylists(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load playlists ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchTracks(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/tracks?limit=15'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load tracks ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchJumpBackIn(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/playlists'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception(
          'Falied to load jump back in playlists ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchAlbums(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/albums'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['items'];
    } else {
      throw Exception('Falied to load user albums ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchArtists(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me/following?type=artist'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['artists']['items'];
    } else {
      throw Exception('Falied to load followed artists ${response.statusCode}');
    }
  }

  Future<void> addToQueue(String accessToken, String trackUri,
      {String? deviceId}) async {
    final url = Uri.parse('https://api.spotify.com/v1/me/player/queue');
    final response = await http.post(
      url.replace(queryParameters: {
        'uri': trackUri,
        if (deviceId != null) 'device_id': deviceId,
      }),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 204) {
      print('Track added to queue successfully.');
    } else {
      print(
          'Failed to add track to queue: ${response.statusCode}, ${response.body}');
    }
  }

  Future<List<dynamic>> searchSpotify(
      String query, String accessToken, String type) async {
    final url = Uri.https('api.spotify.com', '/v1/search', {
      'q': query,
      'type': type,
      'limit': '10',
    });

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['${type}s']['items'];
    } else {
      throw Exception('Failed to search Spotify API');
    }
  }
}
