

import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

Future<void> sendDataToFirestore(String compound, String modifier, String head) async {
  try {
    await db.collection('reported_compounds').add({
      'compound': compound,
      'modifier': modifier,
      'head': head,
    });
    print('Data added to Firestore successfully');
  } catch (e) {
    print('Error adding data to Firestore: $e');
  }
}