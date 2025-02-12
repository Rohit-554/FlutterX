import 'dart:math';

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

final List<MorphableShapeBorder> shapes = [
  CircleShapeBorder(
    border: DynamicBorderSide(
        color: Colors.white, style: BorderStyle.solid),
  ),
  StarShapeBorder(
      corners: 12,
      inset: 12.toPercentLength,
      cornerRadius: 20.toPXLength,
      cornerStyle: CornerStyle.rounded,
      insetRadius: 0.toPXLength,
      insetStyle: CornerStyle.rounded),
  RectangleShapeBorder(
      borderRadius:
          DynamicBorderRadius.all(DynamicRadius.circular(40.toPXLength))),
  PolygonShapeBorder(
    sides: 6,
    cornerStyle: CornerStyle.rounded,
    cornerRadius: 20.toPXLength,
  )
];

class MorphingShapeScreen extends StatefulWidget {
  const MorphingShapeScreen({Key? key}) : super(key: key);

  @override
  _MorphingShapeScreenState createState() => _MorphingShapeScreenState();
}

class _MorphingShapeScreenState extends State<MorphingShapeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3), // Set duration to 1 second
      vsync: this,
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  MorphableShapeBorder? getInterpolatedShape(double t) {
    final double normalizedT = t % shapes.length;
    final int currentIndex = normalizedT.floor();
    final int nextIndex = (currentIndex + 1) % shapes.length;
    final double localT = normalizedT - currentIndex;

    print(': $currentIndex, nextIndex: $nextIndex, localT: $localT');
    return MorphableShapeBorderTween(
      begin: shapes[currentIndex],
      end: shapes[nextIndex],
      method: MorphMethod.weighted, // Explicitly set morphing method
    ).lerp(localT);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Morphing Shape Demo'),
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _animation.value * 1 * pi,
              child: Material(
                shape: getInterpolatedShape(_animation.value),
                color: Colors.blue,
                child: const SizedBox(
                  width: 200,
                  height: 200,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}









ShapeBorder rectangle = RectangleShapeBorder(
    borderRadius: DynamicBorderRadius.only(
        topLeft: DynamicRadius.circular(10.toPXLength),
        bottomRight:
            DynamicRadius.elliptical(60.0.toPXLength, 10.0.toPercentLength)));

//Gemini star shape
final starShape = StarShapeBorder(
    corners: 12,
    inset: 12.toPercentLength,
    cornerRadius: 20.toPXLength,
    cornerStyle: CornerStyle.rounded,
    insetRadius: 0.toPXLength,
    insetStyle: CornerStyle.rounded);

final circleShape = CircleShapeBorder();

//gemini rectangle shape
final rectangleShape = RectangleShapeBorder(
    borderRadius:
        DynamicBorderRadius.all(DynamicRadius.circular(76.toPXLength)));

//gemini polygon shape
final polygonshape = PolygonShapeBorder(
  sides: 6,
  cornerStyle: CornerStyle.rounded,
  cornerRadius: 20.toPXLength,
);

void main() {
  runApp(const MaterialApp(
    home: MorphingShapeScreen(),
  ));
}
