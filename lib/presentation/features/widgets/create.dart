import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CreateSessionService {
  final FirebaseFirestore firestore;

  CreateSessionService({required this.firestore});

  String _generateSixDigitCode() {
    Random random = Random();
    int code = 100000 + random.nextInt(900000); // Generates a number between 100000 and 999999
    return code.toString();
  }

  void createSession(String userName, BuildContext context, Function(String) onSessionCreated) {
    // Generate a 6-digit session ID
    String sessionId = _generateSixDigitCode();

    // Store the session in Firestore
    firestore.collection('sessions').doc(sessionId).set({
      'users': [userName],
      'songs': [],
    }).then((_) {
      print("Session created with ID: $sessionId");
      onSessionCreated(sessionId); // Callback function to handle the created session ID
    }).catchError((error) {
      print('Failed to create session: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create session: $error')),
      );
    });
  }
}