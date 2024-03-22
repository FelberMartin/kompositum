

import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

Future<void> sendDataToFirestore(String compound, String modifier, String head, String level) async {
  try {
    db.collection('reported_compounds').add({
      'compound': compound,
      'modifier': modifier,
      'head': head,
      'time': DateTime.now(),
      'level': level,
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

Future<QuerySnapshot<Map<String, dynamic>>> fetchAllReportedCompounds() async {
  try {
    final reports = await db.collection('reported_compounds').get();
    return reports;
  } catch (e) {
    print('Error fetching data from Firestore: $e');
    rethrow;
  }
}