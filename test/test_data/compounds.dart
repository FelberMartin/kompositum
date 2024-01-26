import 'package:kompositum/data/models/compound.dart';

class Compounds {

  static var Krankenhaus = Compound(
    id: 0,
    name: "Krankenhaus",
    modifier: "krank",
    head: "Haus",
    frequencyClass: 1,
  );

  static var Spielplatz = Compound(
    id: 0,
    name: "Spielplatz",
    modifier: "Spiel",
    head: "Platz",
    frequencyClass: 1,
  );

  static var Adamsapfel = Compound(
    id: 0,
    name: "Adamsapfel",
    modifier: "Adam",
    head: "Apfel",
    frequencyClass: 1,
  );

  static var Apfelbaum = Compound(
    id: 0,
    name: "Apfelbaum",
    modifier: "Apfel",
    head: "Baum",
    frequencyClass: 1,
  );

  static var Apfelkuchen = Compound(
    id: 0,
    name: "Apfelkuchen",
    modifier: "Apfel",
    head: "Kuchen",
    frequencyClass: 1,
  );

  static var Kuchenform = Compound(
    id: 0,
    name: "Kuchenform",
    modifier: "Kuchen",
    head: "Form",
    frequencyClass: 1,
  );

  static var Formsache = Compound(
    id: 0,
    name: "Formsache",
    modifier: "Form",
    head: "Sache",
    frequencyClass: 1,
  );

  static var SachSchaden = Compound(
    id: 0,
    name: "Sachschaden",
    modifier: "Sach",
    head: "Schaden",
    frequencyClass: 1,
  );

  static var Schneemann = Compound(
    id: 0,
    name: "Schneemann",
    modifier: "Schnee",
    head: "Mann",
    frequencyClass: 1,
  );

  static var Fruehschoppen = Compound(
    id: 0,
    name: "Frühschoppen",
    modifier: "früh",
    head: "Schoppen",
    frequencyClass: 1,
  );

  static var Ueberdachung = Compound(
    id: 0,
    name: "Überdachung",
    modifier: "Über",
    head: "Dach",
    frequencyClass: 1,
  );

  static var Maschinenbau = Compound(
    id: 0,
    name: "Maschinenbau",
    modifier: "Maschine",
    head: "Bau",
    frequencyClass: 1,
  );

  static var Baumaschine = Compound(
    id: 0,
    name: "Baumaschine",
    modifier: "Bau",
    head: "Maschine",
    frequencyClass: 1,
  );

  static var Kindeskind = Compound(
    id: 0,
    name: "Kindeskind",
    modifier: "Kind",
    head: "Kind",
    frequencyClass: 1,
  );

  static var all = [
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