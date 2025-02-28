import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ShaderScreen(),
    );
  }
}

class ShaderScreen extends StatefulWidget {
  const ShaderScreen({super.key});

  @override
  _ShaderScreenState createState() => _ShaderScreenState();
}

class _ShaderScreenState extends State<ShaderScreen> {
  ui.FragmentShader? _shader;
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {}); // Update shader time
    });
  }

  Future<void> _loadShader() async {
    final program = await _loadFragmentShader('assets/shaders/example.frag');
    setState(() {
      _shader = program.fragmentShader();
    });
  }

  Future<ui.FragmentProgram> _loadFragmentShader(String assetPath) async {
    // Load the shader source code from the asset
    final shaderSource = await rootBundle.loadString(assetPath);

    // Compile the shader program
    return ui.FragmentProgram.compile(
      spirv: Uint8List.fromList(shaderSource.codeUnits),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return const Center(child: CircularProgressIndicator());
    }

    _shader!
      ..setFloat(0, MediaQuery.of(context).size.width)
      ..setFloat(1, MediaQuery.of(context).size.height)
      ..setFloat(2, _stopwatch.elapsedMilliseconds / 1000.0);

    return Scaffold(
      body: Center(
        child: CustomPaint(
          size: MediaQuery.of(context).size,
          painter: ShaderPainter(_shader!),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;

  ShaderPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
