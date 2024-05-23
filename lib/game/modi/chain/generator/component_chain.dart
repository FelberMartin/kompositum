import 'package:flutter/foundation.dart';
import 'package:kompositum/data/database_interface.dart';
import 'package:kompositum/data/models/compound.dart';
import 'package:kompositum/data/models/unique_component.dart';
import 'package:kompositum/game/level_content.dart';

class ComponentChain extends LevelContent {
  final List<UniqueComponent> components;
  final List<Compound> compounds;

  ComponentChain(this.components, this.compounds);

  static Future<ComponentChain> fromLowercaseComponentStrings({
    required List<String> componentStrings,
    required DatabaseInterface databaseInterface,
  }) async {
    final components = <UniqueComponent>[];
    final compounds = <Compound>[];

    for (int i = 0; i < componentStrings.length - 1; i++) {
      final modifier = componentStrings[i];
      final head = componentStrings[i + 1];
      final compound = await databaseInterface.getCompound(modifier, head, caseSensitive: false);
      compounds.add(compound!);
      components.add(UniqueComponent(compound.modifier));
    }

    final lastComponent = UniqueComponent(compounds.last.head);
    components.add(lastComponent);
    return ComponentChain(components, compounds);
  }


  @override
  String toString() {
    return components.map((component) => component.text).join(" ");
  }

  @override
  List<Compound> getCompounds() {
    return compounds;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ComponentChain &&
      listEquals(other.compounds, compounds);
  }

  @override
  int get hashCode => _deepHash(compounds);

  // Helper method to generate a consistent hash code for a list
  int _deepHash(List<dynamic> list) {
    return list.fold(0, (previousValue, element) => previousValue ^ element.hashCode);
  }

}