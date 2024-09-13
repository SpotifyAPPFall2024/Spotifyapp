import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';

class AuthenticationService {
  final String clientID = '2586def9fbf844a48cfd8ce0c3d4ed7c';
  final String redirectURI = 'myappspoof://callback';
  final String authURL = 'https://accounts.spotify.com/authorize';
  final String tokenURL = 'https://accounts.spotify.com/api/token';
  final String clientSecret = 'e564cdc63037445287a6470c1fa14a75';

  Future<String?> login() async {
    final url = Uri.parse(
        '$authURL?response_type=code&client_id=$clientID&redirect_uri=$redirectURI&scope=user-read-private');
    try {
      final result = await FlutterWebAuth.authenticate(
        callbackUrlScheme: 'myappspoof',
        url: url.toString(),
      );

      final code = Uri.parse(result).queryParameters['code'];
      if (code != null) {
        return await exchange(code);
      } else {
        print('Authorization code not found.');
        return null;
      }
    } catch (e) {
      if (e is PlatformException) {
        // Specific error handling
        if (e.code == 'CANCELED') {
          print('User canceled login.');
          return null;
          // Inform user or provide a way to retry
        } else {
          print('PlatformException: ${e.message}');
          return null;
        }
      } else {
        print('Error during login: $e');
        return null;
      }
    }
  }

  Future<String?> exchange(String code) async {
    final response = await http.post(
      Uri.parse(tokenURL),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectURI,
        'client_id': clientID,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final tokenResponse = jsonDecode(response.body);
      return tokenResponse['access_token'];
    } else {
      print('Failed to exchange code for token');
      return null;
    }
  }

  Future<void> fetchUserData(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      print('User data: $userData');
    } else {
      print('Error fetching user data: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> fetchFeaturedPlaylist(String accessToken) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/browse/featured-playlists'),
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
}
