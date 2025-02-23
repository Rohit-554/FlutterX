import 'package:flutter/material.dart';
import 'dart:math' as math;

class GeminiAnimation extends StatefulWidget {
  const GeminiAnimation({Key? key}) : super(key: key);

  @override
  _GeminiAnimationState createState() => _GeminiAnimationState();
}



class _GeminiAnimationState extends State<GeminiAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controllerA;
  late AnimationController _controllerB;
  late AnimationController _controllerC;

  late Animation<double> _sizeAnim;
  late Animation<double> _spinAnim;
  late Animation<double> _shapeSpinAnim;
  late Animation<Color?> _gradientColorA;
  late Animation<Color?> _gradientColorB;

  @override
  void initState() {
    super.initState();

    _controllerA = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sizeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controllerA, curve: Curves.easeOut),
    );

    _spinAnim = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _controllerA, curve: Curves.easeOut),
    );

    _controllerB = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _gradientColorA = ColorTween(
      begin: Colors.blue,
      end: Colors.purple,
    ).animate(_controllerB);

    _gradientColorB = ColorTween(
      begin: Colors.deepPurple,
      end: Colors.blueAccent,
    ).animate(_controllerB);

    _controllerC = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _shapeSpinAnim = Tween<double>(begin: 0.0, end: 2.0 * math.pi).animate(
      CurvedAnimation(parent: _controllerC, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controllerA.dispose();
    _controllerB.dispose();
    _controllerC.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (_controllerA.isCompleted) {
      _controllerA.reverse();
      _controllerB.stop();
      _controllerC.stop();
    } else {
      _controllerA.forward();
      _controllerB.repeat(reverse: true);
      _controllerC.repeat();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: GestureDetector(
              onTap: _handleTap,
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _controllerA,
                  _controllerB,
                  _controllerC,
                ]),
                builder: (context, child) {
                  final ShapeBorder currentShape = _controllerB.value < 0.25
                      ? const CircleBorder()
                      : _controllerB.value < 0.5
                      ? const WavyCircle(
                    points: 50,
                    amplitude: 7.0,
                    waves: 8,
                  )
                      : _controllerB.value < 0.75
                      ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(120),
                  )
                      : const HexagonBorder();

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _shapeSpinAnim.value,
                        child: Transform.scale(
                          scale: _sizeAnim.value,
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: ShapeDecoration(
                              shape: currentShape,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _gradientColorA.value ?? Colors.blue,
                                  _gradientColorB.value ?? Colors.deepPurple,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.rotate(
                        angle: _spinAnim.value,
                        child: Image.asset(
                          'assets/gemini.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Spacer(),
          const Text("Click to Start",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class WavyCircle extends ShapeBorder {
  final int points;
  final double amplitude;
  final int waves;

  const WavyCircle({
    required this.points,
    required this.amplitude,
    required this.waves,
  });

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final double centerX = rect.center.dx;
    final double centerY = rect.center.dy;
    final double radius = rect.width / 2;
    final double angleStep = 2 * math.pi / points;

    final List<Offset> offsets = List.generate(points, (i) {
      final double angle = i * angleStep;
      final double currentAmplitude = amplitude * math.sin(waves * angle);
      final double r = radius + currentAmplitude;

      final double x = centerX + r * math.cos(angle);
      final double y = centerY + r * math.sin(angle);

      return Offset(x, y);
    });

    path.moveTo(offsets[0].dx, offsets[0].dy);

    for (int i = 0; i < points; i++) {
      final Offset current = offsets[i];
      final Offset next = offsets[(i + 1) % points];
      final Offset midPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      path.quadraticBezierTo(current.dx, current.dy, midPoint.dx, midPoint.dy);
    }

    path.close();
    return path;
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => WavyCircle(
    points: (points * t).toInt(),
    amplitude: amplitude * t,
    waves: waves,
  );

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(1.0), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}


// I am creating a custom shape with Shape class
class HexagonBorder extends ShapeBorder {
  final double radius;

  const HexagonBorder({this.radius = 16.0});

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final double width = rect.width;
    final double height = rect.height;
    final double centerX = rect.center.dx;
    final double centerY = rect.center.dy;
    final double r = width / 2;

    final List<Offset> vertices = List.generate(6, (i) {
      final double angle = 2 * math.pi / 6 * i;
      final double x = centerX + r * math.cos(angle);
      final double y = centerY + r * math.sin(angle);
      return Offset(x, y);
    });

    path.moveTo(vertices[0].dx, vertices[0].dy);

    for (int i = 0; i < vertices.length; i++) {
      final Offset current = vertices[i];
      final Offset next = vertices[(i + 1) % vertices.length];

      final double dx = next.dx - current.dx;
      final double dy = next.dy - current.dy;
      final double angle = math.atan2(dy, dx);

      final Offset cp1 = Offset(
        current.dx + radius * math.cos(angle - math.pi / 2),
        current.dy + radius * math.sin(angle - math.pi / 2),
      );
      final Offset cp2 = Offset(
        next.dx + radius * math.cos(angle - math.pi / 2),
        next.dy + radius * math.sin(angle - math.pi / 2),
      );

      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, next.dx, next.dy);
    }

    path.close();
    return path;
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  ShapeBorder scale(double t) => HexagonBorder(radius: radius * t);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect.deflate(1.0), textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}

void main() {
  runApp(const MaterialApp(
    home: GeminiAnimation(),
  ));
}