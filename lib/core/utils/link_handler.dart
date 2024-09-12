import 'package:uni_links/uni_links.dart';
//import 'package:flutter/material.dart';

Future<void> incomingLinks() async {
  try {
    final initialLink = await getInitialLink();
    if (initialLink != null) {
      print('Initial link: $initialLink');
    }
  } catch (e) {
    print('Failed to handle link: $e');
  }

  linkStream.listen((String? link) {
    if (link != null) {
      print('Incoming link: $link');
    }
  });
}
