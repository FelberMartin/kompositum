

import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

Future<void> sendDataToFirestore(String compound, String modifier, String head) async {
  try {
    db.collection('reported_compounds').add({
      'compound': compound,
      'modifier': modifier,
      'head': head,
      'time': DateTime.now(),
    });

    print('Data added to Firestore successfully');

    // Add some delay
    await Future.delayed(const Duration(milliseconds: 500));
  } catch (e) {
    print('Error adding data to Firestore: $e');
    rethrow;
  }
}

/// Perform a dummy query to Firestore to send pending data.
void sendPendingDataToFirestore() {
  try {
    db.collection('dummy').get();
    print('Pending data sent to Firestore successfully');
  } catch (e) {
    print('Error sending pending data to Firestore: $e');
    rethrow;
  }
}