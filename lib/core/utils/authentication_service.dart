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
    this.redirectUri = 'http://localhost:50677/callback',
    //this.redirectUri = 'myappspoof://callback',
    this.scope =
        'user-read-private user-read-email playlist-read-private playlist-modify-private user-read-playback-state user-modify-playback-state user-library-read user-library-modify user-top-read user-read-recently-played',
  });

  // Generate a random string
  String _generateRandomString(int length) {
    const possible =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final values =
        List<int>.generate(length, (i) => random.nextInt(possible.length));
    return values.map((e) => possible[e]).join();
  }

  // Hash a string using SHA-256
  Future<Uint8List> _sha256(String plain) async {
    final bytes = utf8.encode(plain);
    final digest = sha256.convert(bytes);
    return Uint8List.fromList(digest.bytes);
  }

  // Encode bytes in Base64 URL format
  String _base64UrlEncode(Uint8List input) {
    return base64Url
        .encode(input)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }

  // Generate the authorization URL
  Future<Uri> getAuthorizationUrl() async {
    final codeVerifier = _generateRandomString(64);
    final hashed = await _sha256(codeVerifier);
    final codeChallenge = _base64UrlEncode(hashed);

    // Store code verifier in secure storage
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

  // Exchange authorization code for access token
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
      // Store access token as needed
    } else {
      print('Failed to exchange code for token: ${response.body}');
      return null;
    }
  }

  Future<String?> login() async {}
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
      throw Exception('Failed to load featured playlists');
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
      throw Exception('Falied to load recent plays');
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
      throw Exception('Falied to load top mixes');
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
      throw Exception('Falied to load top mixes');
    }
  }

  // Future<List<dynamic>> fetchTopMixes(String accessToken) async {
  //   final response = await http.get(
  //     Uri.parse('https://api.spotify.com/v1/me/top/tracks?limit=15'),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data['items'];
  //   } else {
  //     throw Exception('Falied to load top mixes');
  //   }
  // }

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
      throw Exception('Falied to load jump back in playlists');
    }
  }
}


// import 'dart:convert';
// import 'dart:async';
// import 'dart:math';
// import 'package:crypto/crypto.dart';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
// import 'package:oauth2_client/access_token_response.dart';
// import 'package:oauth2_client/spotify_oauth2_client.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class AuthenticationService {
//   final String clientID = '905df89fc43547469d85ece7a82de400';
//   final String redirectURI = 'myappspoof://callback';
//   final String authURL = 'https://accounts.spotify.com/authorize';
//   final String tokenURL = 'https://accounts.spotify.com/api/token';
//   final String clientSecret = '5c81b0bc2a124697ab18e12aca65ca3f';
//   static const int tokenExpires = 60;
//
//
//   // Timer? refreshTimer;
//   // final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
//   //
//   String generateRandomString(int length) {
//     const String chars =
//         'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
//     final Random random = Random.secure();
//     final List<int> values = List<int>.generate(length, (i)=> random.nextInt(chars.length));
//     return values.map((index)=>chars[index]).join();
//   }


  //
  // Future<String?> remoteService() async {
  //   AccessTokenResponse? accessToken;
  //   SpotifyOAuth2Client client = SpotifyOAuth2Client(
  //       redirectUri: redirectURI, customUriScheme: 'myappspoof');
  //   var authResp =
  //       await client.requestAuthorization(clientId: clientID, scopes: [
  //     'user-read-private'
  //
  //   ]);
  //   var authCode = authResp.code;
  //   accessToken = await client.requestAccessToken(
  //       code: authCode.toString(),
  //       clientId: clientID,
  //       clientSecret: clientSecret);
  //   final accesstoken = accessToken.accessToken;
  //   final refreshtoken = accessToken.refreshToken;
  //   final expiresIn = accessToken.expiresIn;
  //
  //   if(accesstoken != null && refreshtoken != null && expiresIn != null){
  //     await storeToken(accesstoken, refreshtoken, expiresIn);
  //     scheduledTokenRefresh(expiresIn);
  //   }
  //   return accesstoken;
  // }
  //
  // Future<void> storeToken(String accesstoken, String refreshtoken, int expiresIn) async{
  //   await secureStorage.write(key: 'accessToken', value: accesstoken);
  //   await secureStorage.write(key:'refreshToken', value:refreshtoken);
  //   await secureStorage.write(key:'expiresAt', value:(DateTime.now().millisecondsSinceEpoch+(expiresIn-tokenExpires)*1000).toString());
  //
  // }
  // Future<void> scheduledTokenRefresh(int expiresIn) async{
  //   final expireTime = DateTime.now().millisecondsSinceEpoch + (expiresIn - tokenExpires) * 1000;
  //   final duration = Duration(milliseconds: (expireTime-DateTime.now().millisecondsSinceEpoch).toInt());
  //
  //   refreshTimer?.cancel();
  //   refreshTimer = Timer(duration, () async{
  //     await refreshToken();
  //     final newExpiration = await getTokenExpired();
  //     if (newExpiration != null){
  //       scheduledTokenRefresh(expiresIn);
  //     }
  //   });
  // }
  //
  // Future<void> refreshToken() async{
  //   final refreshtoken = await secureStorage.read(key:'refreshToken');
  //   if(refreshtoken==null){
  //     print('No refresh token found');
  //     return;
  //   }
  //   final response = await http.post(
  //     Uri.parse(tokenURL),
  //     headers:{
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body:{
  //       'grant_type':'refresh_token',
  //       'refresh_token': refreshtoken,
  //       'client_id': clientID,
  //       'client_secret':clientSecret,
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final tokenResponse = jsonDecode(response.body);
  //     final newAccessToken = tokenResponse['access_token'];
  //     final newExpiresIn = tokenResponse['expires_in'];
  //
  //     if (newAccessToken != null && newExpiresIn != null) {
  //       await storeToken(newAccessToken, refreshtoken, newExpiresIn);
  //     }
  //   } else {
  //     print('Failed to refresh token');
  //   }
  // }
  //
  // Future<String?> login() async {
  //   final state = generateRandomString(16);
  //   final url = Uri.parse(
  //       '$authURL?client_id=$clientID&response_type=code&redirect_uri=$redirectURI&scope=user-read-private&state=$state');
  //   try {
  //     final result = await FlutterWebAuth2.authenticate(
  //       callbackUrlScheme: 'myappspoof',
  //       url: url.toString(),
  //     );
  //     print('Auth Result: $result');
  //     final code = Uri.parse(result).queryParameters['code'];
  //     if (code != null) {
  //       return await exchange(code);
  //     } else {
  //       print('Authorization code not found.');
  //       return null;
  //     }
  //   } catch (e) {
  //     if (e is PlatformException) {
  //       // Specific error handling
  //       if (e.code == 'CANCELED') {
  //         print('User canceled login.');
  //         // Inform user or provide a way to retry
  //       } else {
  //         print('PlatformException: ${e.message}');
  //       }
  //     } else {
  //       print('Error during login: $e');
  //     }
  //     return null;
  //   }
  // }
  //
  // Future<String?> exchange(String code) async {
  //   final response = await http.post(
  //     Uri.parse(tokenURL),
  //     headers: {
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'grant_type': 'authorization_code',
  //       'code': code,
  //       'redirect_uri': redirectURI,
  //       'client_id': clientID,
  //       'client_secret': clientSecret,
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final tokenResponse = jsonDecode(response.body);
  //     final accessToken = tokenResponse['access_token'];
  //     final refreshToken = tokenResponse['refresh_token'];
  //     final expiresIn = tokenResponse['expires_in'];
  //
  //     if (accessToken != null && refreshToken != null && expiresIn != null) {
  //       await storeToken(accessToken, refreshToken, expiresIn);
  //       scheduledTokenRefresh(expiresIn);
  //     }
  //     return accessToken;
  //   } else {
  //     print('Failed to exchange code for token');
  //     return null;
  //   }
  // }
  //
  // Future<void> fetchUserData(String accessToken) async {
  //   final response = await http.get(
  //     Uri.parse('https://api.spotify.com/v1/me'),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final userData = jsonDecode(response.body);
  //     print('User data: $userData');
  //   } else {
  //     print('Error fetching user data: ${response.statusCode}');
  //   }
  // }
  //
  // Future<List<dynamic>> fetchFeaturedPlaylist(String accessToken) async {
  //   final response = await http.get(
  //     Uri.parse('https://api.spotify.com/v1/browse/featured-playlists'),
  //     headers: {
  //       'Authorization': 'Bearer $accessToken',
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     return data['playlists']['items'];
  //   } else {
  //     throw Exception('Failed to load featured playlists');
  //   }
  // }
  //
  // Future<int?> getTokenExpired() async{
  //   final expiredAt = await secureStorage.read(key:'expiresAt');
  //   return expiredAt != null ? int.tryParse(expiredAt): null;
  // }
//}
