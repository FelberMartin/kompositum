// Fetch the reported compounds from the Firestore database and save them to /data/reported_compounds.json.

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:kompositum/data/remote/firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final reports = await fetchAllReportedCompounds();

  // Print the reports to the console in a csv format
  final header = 'compound,modifier,head,time';
  print(header);

  // Do the printing from above in a for loop
  for (var report in reports.docs) {
    final compound = report['compound'];
    final modifier = report['modifier'];
    final head = report['head'];
    final time = report['time'].toDate();
    print('$compound,$modifier,$head,$time');
  }

  print('Fetched ${reports.docs.length} reports');

  // Copy this console output to data/reported/all_reported.csv
}