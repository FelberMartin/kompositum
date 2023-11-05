import 'package:kompositum/data/compound.dart';

class Compounds {

  static const Krankenhaus = Compound(
    name: "Krankenhaus",
    modifier: "krank",
    head: "Haus",
    frequencyClass: 1,
  );

  static const Spielplatz = Compound(
    name: "Spielplatz",
    modifier: "Spiel",
    head: "Platz",
    frequencyClass: 1,
  );

  static const Adamsapfel = Compound(
    name: "Adamsapfel",
    modifier: "Adam",
    head: "Apfel",
    frequencyClass: 1,
  );

  static const Apfelbaum = Compound(
    name: "Apfelbaum",
    modifier: "Apfel",
    head: "Baum",
    frequencyClass: 1,
  );

  static const Apfelkuchen = Compound(
    name: "Apfelkuchen",
    modifier: "Apfel",
    head: "Kuchen",
    frequencyClass: 1,
  );

  static const Kuchenform = Compound(
    name: "Kuchenform",
    modifier: "Kuchen",
    head: "Form",
    frequencyClass: 1,
  );

  static const Formsache = Compound(
    name: "Formsache",
    modifier: "Form",
    head: "Sache",
    frequencyClass: 1,
  );

  static const SachSchaden = Compound(
    name: "Sachschaden",
    modifier: "Sach",
    head: "Schaden",
    frequencyClass: 1,
  );

  static const Schneemann = Compound(
    name: "Schneemann",
    modifier: "Schnee",
    head: "Mann",
    frequencyClass: 1,
  );

  static const Fruehschoppen = Compound(
    name: "Frühschoppen",
    modifier: "früh",
    head: "Schoppen",
    frequencyClass: 1,
  );

  static const all = [
    Krankenhaus,
    Spielplatz,
    Adamsapfel,
    Apfelbaum,
    Apfelkuchen,
    Kuchenform,
    Formsache,
    SachSchaden,
    Schneemann,
    Fruehschoppen,
  ];
}