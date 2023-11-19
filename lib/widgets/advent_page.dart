import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdventPage extends StatefulWidget {
  const AdventPage({Key? key}) : super(key: key);

  @override
  State<AdventPage> createState() => _AdventPageState();
}

class _AdventPageState extends State<AdventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          clipBehavior: Clip.none,
          minScale: 0.1,
          maxScale: 3.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image(
                image: AssetImage("assets/background.jpg"),
                fit: BoxFit.cover,
              ),
              // Add a grid layout with 4 columns and 6 rows.
              // Each element in the grid should be a container with a border
              // and a number in the middle.
              // The number should be the index of the element in the grid.
              // The grid should be centered in the middle of the screen.
              Positioned.fill(child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                padding: EdgeInsets.all(10),
                children: List.generate(24, (index) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text("${index + 1}",
                        style: TextStyle(color: Colors.white)),
                  );
                }),
              ),
              ),
          ]),
        ),
      ));
  }
}
