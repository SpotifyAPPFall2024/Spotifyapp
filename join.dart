import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JoinSessionService {
  final FirebaseFirestore firestore;

  JoinSessionService({required this.firestore});

  void joinSession(String sessionId, String userName, BuildContext context, Function onSessionJoined) {
    firestore.collection('sessions').doc(sessionId).get().then((doc) {
      if (doc.exists) {
        firestore.collection('sessions').doc(sessionId).update({
          'users': FieldValue.arrayUnion([userName]),
        }).then((_) {
          print("User $userName joined session: $sessionId");
          onSessionJoined(); // Callback function to handle UI updates after joining
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to join session: $error')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session ID does not exist')),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding session: $error')),
      );
    });
  }
}