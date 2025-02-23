import 'dart:math';

import 'package:flutter/material.dart';
/*
void main() {
  runApp(const AnimatingShapes());
}*/

class AnimatingShapes extends StatefulWidget {
  const AnimatingShapes({super.key});

  @override
  State<AnimatingShapes> createState() => _AnimatingShapesState();
}

class _AnimatingShapesState extends State<AnimatingShapes>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late int _currentShapeIndex;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _enterAnimation; // New animation for smooth entry
  bool _isForwardTransition = true;

  @override
  void initState() {
    super.initState();
    _currentShapeIndex = 0;

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Fade out animation near the transition
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.8, 1.0, curve: Curves.easeInOut), // Fade out at the end
      ),
    );

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _enterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.2, curve: Curves.easeInOut), // Fade in at the start
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          if (_isForwardTransition) {
            _currentShapeIndex = (_currentShapeIndex + 1) % 4;
          } else {
            _currentShapeIndex = (_currentShapeIndex - 1 + 4) % 4;
          }
          _controller.reset();
          _controller.forward();
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shapes = [
      CircleShape(),
      CapsuleShape(),
      HexagonShape(),
      FlowerShape(),
    ];

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Morphing Shapes'),
          actions: [
            IconButton(
              icon: Icon(_isForwardTransition
                  ? Icons.arrow_forward
                  : Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _isForwardTransition = !_isForwardTransition;
                });
              },
              tooltip: 'Change direction',
            ),
          ],
        ),
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value == 0.0 ? 1.0 : _fadeAnimation.value, // Avoid full transparency
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child:shapes[_currentShapeIndex],
                ),
              );
            },
          ),
        ),
      ),
    );
  }



}

class CircleShape extends StatelessWidget {
  const CircleShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PhysicalModel(
          color: Colors.blue,
          elevation: 5,
          shadowColor: Colors.black,
          shape: BoxShape.circle,
          child: SizedBox(
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}

class FlowerShape extends StatelessWidget {
  const FlowerShape({super.key});

  double get diameter => 250 - 100;

  double get radius => diameter / 2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: FlowerPainter(radius,fillColor: Colors.blue),
        )
      ],
    );
  }
}

class CapsuleShape extends StatelessWidget {
  const CapsuleShape({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PhysicalModel(
          color: Colors.blue,
          elevation: 5,
          shadowColor: Colors.black,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}

class HexagonShape extends StatelessWidget {
  const HexagonShape({super.key});

  double get diameter => 250 - 100;

  double get radius => diameter / 2;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(
          painter: HexagonPainter(radius,fillColor: Colors.blue),
        )
      ],
    );
  }
}

class HexagonPainter extends CustomPainter {
  final double radius;
  final Color fillColor;
  final Color borderColor;
  final double strokeWidth;

  HexagonPainter(
    this.radius, {
    this.fillColor = Colors.blue,
    this.borderColor = Colors.blueGrey,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = borderColor.withOpacity(0.5)
      ..strokeWidth = strokeWidth;

    Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor.withOpacity(0.3);

    final center = Offset(size.width / 2, size.height / 2);
    final effectiveRadius = radius - borderPaint.strokeWidth / 2;
    final angleMul = [1, 3, 5, 7, 9, 11, 1];

    final Path fillPath = Path();

    final firstPoint = Offset(
        effectiveRadius * cos(pi * 2 * (angleMul[0] * 30 / 360)) + center.dx,
        effectiveRadius * sin(pi * 2 * (angleMul[0] * 30 / 360)) + center.dy);
    fillPath.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i <= 6; i++) {
      final point = Offset(
          effectiveRadius * cos(pi * 2 * (angleMul[i] * 30 / 360)) + center.dx,
          effectiveRadius * sin(pi * 2 * (angleMul[i] * 30 / 360)) + center.dy);
      fillPath.lineTo(point.dx, point.dy);
    }

    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(fillPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class FlowerPainter extends CustomPainter {
  final double radius;
  final Color fillColor;
  final Color borderColor;
  final double cornerRadius;
  final double strokeWidth;

  FlowerPainter(
    this.radius, {
    this.fillColor = Colors.blue,
    this.borderColor = Colors.blueGrey,
    this.cornerRadius = 15.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // For the border
    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = borderColor.withOpacity(0.5)
      ..strokeWidth = strokeWidth;

    // For the fill
    Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor.withOpacity(0.3);

    final center = Offset(size.width / 2, size.height / 2);
    final effectiveRadius = radius - borderPaint.strokeWidth / 2;
    final angleMul = [1, 3, 5, 7, 9, 11];

    // List to store all corner points
    final List<Offset> corners = [];

    // Calculate all corner points
    for (int i = 0; i < 6; i++) {
      corners.add(Offset(
          effectiveRadius * cos(pi * 2 * (angleMul[i] * 30 / 360)) + center.dx,
          effectiveRadius * sin(pi * 2 * (angleMul[i] * 30 / 360)) +
              center.dy));
    }

    // Create path for filling with rounded corners
    final Path fillPath = Path();

    for (int i = 0; i < 6; i++) {
      final p1 = corners[i];
      final p2 = corners[(i + 1) % 6];

      // Calculate the direction vectors
      final dx1 = p1.dx - center.dx;
      final dy1 = p1.dy - center.dy;
      final dx2 = p2.dx - center.dx;
      final dy2 = p2.dy - center.dy;

      // Normalize
      final len1 = sqrt(dx1 * dx1 + dy1 * dy1);
      final len2 = sqrt(dx2 * dx2 + dy2 * dy2);

      final nx1 = dx1 / len1;
      final ny1 = dy1 / len1;
      final nx2 = dx2 / len2;
      final ny2 = dy2 / len2;

      // Calculate corner points
      final cornerPoint1 = Offset(
        p1.dx - nx1 * cornerRadius,
        p1.dy - ny1 * cornerRadius,
      );

      final cornerPoint2 = Offset(
        p2.dx - nx2 * cornerRadius,
        p2.dy - ny2 * cornerRadius,
      );

      if (i == 0) {
        fillPath.moveTo(cornerPoint1.dx, cornerPoint1.dy);
      } else {
        fillPath.lineTo(cornerPoint1.dx, cornerPoint1.dy);
      }

      // Add the arc
      fillPath.arcToPoint(
        cornerPoint2,
        radius: Radius.circular(cornerRadius),
        rotation: 0,
        largeArc: false,
        clockwise: true,
      );
    }

    // Close the path
    fillPath.close();

    // First fill the shape
    canvas.drawPath(fillPath, fillPaint);

    // Draw the rounded border
    canvas.drawPath(fillPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ArcPainter extends CustomPainter {
  final double radius;

  ArcPainter(this.radius);

  @override
  void paint(Canvas canvas, Size size) {
    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..color = Colors.blueGrey.withOpacity(0.5)
      ..strokeWidth = 1.0;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height / 2);

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}



/**
 * This is used to create a screen that morphs between different shapes
 * */
class MorphingShapesScreen extends StatefulWidget {
  const MorphingShapesScreen({super.key});

  @override
  _MorphingShapesScreenState createState() => _MorphingShapesScreenState();
}

class _MorphingShapesScreenState extends State<MorphingShapesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  int _currentShapeIndex = 0;
  bool _isForwardTransition = true;

  final List<CustomClipper<Path>> _shapeClippers = [
    CircleClipper(),
    CapsuleClipper(),
    RoundedHexagonClipper(),
    FlowerClipper(),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentShapeIndex = _isForwardTransition
              ? (_currentShapeIndex + 1) % _shapeClippers.length
              : (_currentShapeIndex - 1 + _shapeClippers.length) %
              _shapeClippers.length;
        });
        _controller.reset();
        _controller.forward();
      }
    });

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: ClipPath(
                    clipper: _shapeClippers[_currentShapeIndex],
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.blueAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/star.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) => false;
}

class CapsuleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.6),
        Radius.circular(size.width / 2)));
    return path;
  }

  @override
  bool shouldReclip(CapsuleClipper oldClipper) => false;
}




class RoundedHexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;
    double cornerRadius = width * 0.0;

    List<Offset> points = [
      Offset(width * 0.25, 0),
      Offset(width * 0.75, 0),
      Offset(width, height * 0.5),
      Offset(width * 0.75, height),
      Offset(width * 0.25, height),
      Offset(0, height * 0.5),
    ];

    path.moveTo(points[0].dx + cornerRadius, points[0].dy);

    for (int i = 0; i < points.length; i++) {
      Offset start = points[i];
      Offset end = points[(i + 1) % points.length];
      double angle = atan2(end.dy - start.dy, end.dx - start.dx);
      Offset startArc = Offset(
        start.dx + cos(angle) * cornerRadius,
        start.dy + sin(angle) * cornerRadius,
      );
      Offset endArc = Offset(
        end.dx - cos(angle) * cornerRadius,
        end.dy - sin(angle) * cornerRadius,
      );

      path.lineTo(startArc.dx, startArc.dy);
      path.arcToPoint(
        endArc,
        radius: Radius.circular(cornerRadius),
        clockwise: true,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(RoundedHexagonClipper oldClipper) => false;
}



class FlowerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double radius = size.width / 4;
    Offset center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 6; i++) {
      double angle = (pi / 3) * i;
      path.addOval(Rect.fromCircle(
          center: Offset(
            center.dx + radius * cos(angle),
            center.dy + radius * sin(angle),
          ),
          radius: radius));
    }

    return path;
  }

  @override
  bool shouldReclip(FlowerClipper oldClipper) => false;
}


