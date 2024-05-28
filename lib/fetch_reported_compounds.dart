// Fetch the reported compounds from the Firestore database and save them to /data/reported_compounds.json.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:kompositum/data/remote/firestore.dart';

import 'firebase_options.dart';

class ReportedCompound implements Comparable<ReportedCompound> {
  final String compound;
  final String modifier;
  final String head;
  final DateTime time;
  final String level;
  final String appVersion;

  ReportedCompound(this.compound, this.modifier, this.head, this.time, this.level, this.appVersion);

  @override
  String toString() {
    return '$compound,$modifier,$head';
  }

  @override
  int compareTo(ReportedCompound other) {
    return time.compareTo(other.time);
  }
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final reports = await fetchAllReportedCompounds();

  // Print the reports to the console in a csv format
  final header = 'compound,modifier,head,time,level,app_version';
  print(header);

  final reportedCompounds = <ReportedCompound>[];

  // Do the printing from above in a for loop
  for (var report in reports.docs) {
    final compound = report['compound'];
    final modifier = report['modifier'];
    final head = report['head'];
    final time = report['time'].toDate();
    final level = report.data()['level'] ?? 'null';
    final appVersion = report.data()['app_version'] ?? 'null';
    reportedCompounds.add(ReportedCompound(compound, modifier, head, time, level, appVersion));
  }

  reportedCompounds.sort();
  for (var reportedCompound in reportedCompounds) {
    print(reportedCompound);
  }

  print('Fetched ${reports.docs.length} reports');

  // Copy this console output to data/reported/all_reported.csv
}