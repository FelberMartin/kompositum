import '../../data/database_interface.dart';
import '../../data/models/compound.dart';
import '../../data/models/unique_component.dart';


class ComponentForest {
  final List<ComponentTree> trees;

  ComponentForest(this.trees);

  static Future<ComponentForest> generate({
    required DatabaseInterface databaseInterface,
    required List<String> rootStrings,
  }) async {
    final trees = <ComponentTree>[];
    for (var rootString in rootStrings) {
      final tree = await ComponentTree.generate(
        databaseInterface: databaseInterface,
        rootString: rootString,
      );
      trees.add(tree);
    }
    return ComponentForest(trees);
  }

  List<Compound> getAllCompounds() {
    final compounds = <Compound>[];
    for (var tree in trees) {
      compounds.addAll(tree.getAllCompounds());
    }
    return compounds;
  }

  List<UniqueComponent> getAllComponents() {
    final components = <UniqueComponent>[];
    for (var tree in trees) {
      components.addAll(tree.getAllComponents());
    }
    return components;
  }

  List<UniqueComponent> getAllNoneRootComponents() {
    final components = <UniqueComponent>[];
    for (var tree in trees) {
      components.addAll(tree.getAllNoneRootComponents());
    }
    return components;
  }

  List<UniqueComponent> getLeaveComponents() {
    final components = <UniqueComponent>[];
    for (var tree in trees) {
      components.addAll(tree.getLeaveComponents());
    }
    return components;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var tree in trees) {
      buffer.writeln(tree.toString());
      buffer.writeln("-----------------------------");
    }
    return buffer.toString();
  }

}

class ComponentTree {
  final ComponentTreeNode root;

  ComponentTree(this.root);

  static Future<ComponentTree> generate({
    required DatabaseInterface databaseInterface,
    required String rootString,
  }) async {
    final rootCompound = await databaseInterface.getCompoundByName(rootString);
    if (rootCompound == null) {
      throw Exception("Could not find compound with name $rootString");
    }
    final rootComponent = UniqueComponent(rootCompound.name);
    final root = ComponentTreeNode(rootComponent);
    final tree = ComponentTree(root);
    await tree.root.addChildrenRecursively(databaseInterface);
    return tree;
  }

  void forEach(void Function(ComponentTreeNode) callback) {
    root.forEach(callback);
  }

  List<Compound> getAllCompounds() {
    final compounds = <Compound>[];
    forEach((node) => {
      if (node.compound != null) {
        compounds.add(node.compound!),
      }
    });
    return compounds;
  }

  List<UniqueComponent> getAllComponents() {
    final components = <UniqueComponent>[];
    forEach((node) => components.add(node.component));
    return components;
  }

  List<UniqueComponent> getAllNoneRootComponents() {
    final allComponents = getAllComponents();
    allComponents.remove(root.component);
    return allComponents;
  }

  List<UniqueComponent> getLeaveComponents() {
    final components = <UniqueComponent>[];
    forEach((node) {
      if (node.isLeaf) {
        components.add(node.component);
      }
    });
    return components;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    forEach((node) {
      buffer.writeln(node.toString());
    });
    return buffer.toString();
  }
}

class ComponentTreeNode {
  final UniqueComponent component;
  Compound? compound;
  ComponentTreeNode? left;
  ComponentTreeNode? right;

  ComponentTreeNode(this.component);

  bool get isLeaf => left == null && right == null;

  void forEach(void Function(ComponentTreeNode) callback) {
    callback(this);
    left?.forEach(callback);
    right?.forEach(callback);
  }

  Future<void> addChildrenRecursively(DatabaseInterface databaseInterface) async {
    final compoundForNode = await databaseInterface.getCompoundByName(component.text);
    if (compoundForNode == null) {
      return;
    }
    compound = compoundForNode;

    final childComponents = UniqueComponent.fromCompound(compoundForNode);
    left = ComponentTreeNode(childComponents[0]);
    right = ComponentTreeNode(childComponents[1]);

    await left!.addChildrenRecursively(databaseInterface);
    await right!.addChildrenRecursively(databaseInterface);
  }

  @override
  String toString() {
    if (compound == null) {
      return component.text;
    }
    return "${compound!.name} = ${compound!.modifier} + ${compound!.head}";
  }
}