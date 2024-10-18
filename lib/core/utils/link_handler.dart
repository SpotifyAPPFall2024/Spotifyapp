import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_links/app_links.dart';
import 'package:spotifyapp/core/utils/authentication_service.dart';
import 'package:spotifyapp/main.dart';

Future<String?> incomingLinks() async {
  final AppLinks appLinks = AppLinks();
  final storage = const FlutterSecureStorage();

  try {
    final Uri? initialLink = await appLinks.getInitialLink();
    if (initialLink != null) {
      print('Initial link: $initialLink');
      final accessToken = await _handleRedirectUri(initialLink, storage);
      if (accessToken!=null){
        navigateToHome(accessToken);
      }
    }
  } catch (e) {
    print('Failed to handle initial link: $e');
  }

  appLinks.uriLinkStream.listen((Uri? link) {
    if (link != null) {
      print('Incoming link: $link');
      final accessToken = _handleRedirectUri(link, storage);

    }
  });
  return null;
}

Future<String?> _handleRedirectUri(Uri uri, FlutterSecureStorage storage) async {
  final code = uri.queryParameters['code'];
  if (code != null) {
    final authService = AuthenticationService();
    try {
      final accessToken = await authService.exchangeCodeForToken(code);
      if (accessToken!=null){
        navigateToHome(accessToken);
      }
      // Navigate to another screen or handle the successful authentication
      print('Token exchange successful');
    } catch (e) {
      print('Failed to exchange code for token: $e');
    }
  } else {
    print('Authorization code is missing');
  }
  return null;
}


// import 'package:app_links/app_links.dart';
// import 'dart:async';
//
// Future<void> incomingLinks() async {
//   final AppLinks _appLinks = AppLinks();
//
//   try {
//     final Uri? initialLink = await _appLinks.getInitialLink();
//     if (initialLink != null) {
//       print('Initial link: $initialLink');
//     }
//   } catch (e) {
//     print('Failed to handle initial link: $e');
//   }
//
//   // Listen to incoming links
//   _appLinks.uriLinkStream.listen((Uri? link) {
//     if (link != null) {
//       print('Incoming link: $link');
//     }
//   });
// }
