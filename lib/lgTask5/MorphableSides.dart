import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MorphableSides());
}

class MorphableSides extends StatelessWidget {
  const MorphableSides({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: const ShapeAnimationPage(),
    );
  }
}

class ShapeAnimationPage extends StatefulWidget {
  const ShapeAnimationPage({Key? key}) : super(key: key);

  @override
  _ShapeAnimationPageState createState() => _ShapeAnimationPageState();
}

class _ShapeAnimationPageState extends State<ShapeAnimationPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _morphController;
  late Animation<double> _rotationAnimation;
  late Animation<int> _sidesAnimation;

  final List<Shape> _shapes = [];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeShapes();
    _startAnimations();
  }

  void _initializeControllers() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _initializeAnimations() {
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_rotationController);

    _sidesAnimation = IntTween(begin: 3, end: 8).animate(_morphController);
  }

  void _initializeShapes() {
    for (int i = 0; i < 5; i++) {
      _shapes.add(
        Shape(
          sides: 3 + i,
          color: _colors[i],
          rotationOffset: (2 * math.pi / 5) * i,
          scale: 1.0 - (i * 0.15),
          individualRotation: 0.0,
        ),
      );
    }
  }

  void _startAnimations() {
    _rotationController.repeat();
    _morphController.repeat(reverse: true);

    _morphController.addListener(() {
      setState(() {
        for (int i = 0; i < _shapes.length; i++) {
          _shapes[i] = _shapes[i].copyWith(
            sides: _sidesAnimation.value + i,
            individualRotation: _shapes[i].individualRotation + 0.02,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _morphController]),
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..rotateX(_rotationAnimation.value)
                ..rotateY(_rotationAnimation.value)
                ..rotateZ(_rotationAnimation.value),
              child: CustomPaint(
                painter: MultiPolygonPainter(shapes: _shapes),
                child: const SizedBox(
                  width: 300,
                  height: 300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class Shape {
  final int sides;
  final Color color;
  final double rotationOffset;
  final double scale;
  final double individualRotation;

  Shape({
    required this.sides,
    required this.color,
    required this.rotationOffset,
    required this.scale,
    required this.individualRotation,
  });

  Shape copyWith({
    int? sides,
    Color? color,
    double? rotationOffset,
    double? scale,
    double? individualRotation,
  }) {
    return Shape(
      sides: sides ?? this.sides,
      color: color ?? this.color,
      rotationOffset: rotationOffset ?? this.rotationOffset,
      scale: scale ?? this.scale,
      individualRotation: individualRotation ?? this.individualRotation,
    );
  }
}

class MultiPolygonPainter extends CustomPainter {
  final List<Shape> shapes;

  MultiPolygonPainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final shape in shapes) {
      final paint = Paint()
        ..color = shape.color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3;

      final path = Path();
      final center = Offset(size.width / 2, size.height / 2);
      final angle = (2 * math.pi) / shape.sides;
      final radius = (size.width / 2) * shape.scale;

      final totalRotation = shape.rotationOffset + shape.individualRotation;

      path.moveTo(
        center.dx + radius * math.cos(totalRotation),
        center.dy + radius * math.sin(totalRotation),
      );

      for (int i = 0; i < shape.sides; i++) {
        final currentAngle = angle * i + totalRotation;
        path.lineTo(
          center.dx + radius * math.cos(currentAngle),
          center.dy + radius * math.sin(currentAngle),
        );
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}