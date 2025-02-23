import 'dart:math';
import 'package:flutter/material.dart';
import 'Contstants.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class GlowingVoiceUI extends StatefulWidget {
  const GlowingVoiceUI({super.key});

  @override
  _GlowingVoiceUIState createState() => _GlowingVoiceUIState();
}

class _GlowingVoiceUIState extends State<GlowingVoiceUI>
    with TickerProviderStateMixin {
  late AnimationController _waveController;

  late stt.SpeechToText _voice;
  bool _isListening = false;
  String _spokenText = "Hi, how can I help?";
  bool _isVoiceReady = false;
  double _soundLevel = 0.0;
  final double _baseHeight = 10.0;
  String _debugText = "";

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _voice = stt.SpeechToText();
    _initializeVoice();
  }

  Future<void> _initializeVoice() async {
    try {
      var micStatus = await Permission.microphone.request();
      if (micStatus.isGranted) {
        _isVoiceReady = await _voice.initialize(
          onError: (error) => _resetVoiceState(),
          onStatus: (status) {
            if (status == 'notListening' || status == 'done') {
              _resetVoiceState();
            }
          },
        );
        setState(() {});
      }
    } catch (e) {
      print('Voice initialization error: $e');
    }
  }

  void _resetVoiceState() {
    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
      _debugText = "";
    });
  }

  double _mapSoundLevel(double level) {
    const double minDb = -160.0;
    const double maxDb = -10.0;
    level = level.clamp(minDb, maxDb);
    return (level - minDb) / (maxDb - minDb);
  }

  void _startListening() async {
    if (!_isVoiceReady) {
      await _initializeVoice();
    }

    try {
      if (_isVoiceReady) {
        setState(() {
          _isListening = true;
        });

        await _voice.listen(
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          onSoundLevelChange: (level) {
            double mappedLevel = _mapSoundLevel(level);
            setState(() {
              _soundLevel = level;
              _debugText = "Level: $level, Mapped: $mappedLevel";
              print(_debugText);
            });
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
            cancelOnError: true,
            partialResults: true,
          ),
        );
      } else {
        setState(() {
          _spokenText = "Voice recognition unavailable";
        });
      }
    } catch (e) {
      _resetVoiceState();
      setState(() {
        _spokenText = "Error starting voice recognition";
      });
    }
  }

  void _stopListening() {
    _voice.stop();
    _resetVoiceState();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _voice.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "Tap the mic and try Speaking",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                height: 220,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        _isListening ? _stopListening() : _startListening();
                      },
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _spokenText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    !_isListening
                        ? const SizedBox(
                      width: double.infinity,
                    )
                        :
                    _WaveAnimation(
                        controller: _waveController,
                        soundLevel: _soundLevel,
                        baseHeight: _baseHeight),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _WaveAnimation extends StatelessWidget {
  final AnimationController controller;
  final double soundLevel;
  final double baseHeight;

  const _WaveAnimation({
    required this.controller,
    required this.soundLevel,
    required this.baseHeight,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth,
      height: 30,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          double t = controller.value;
          const double amplitude = 0.3;

          List<double> pulses = List.generate(4, (index) {
            double phase = index / 4.0; // 0, 0.25, 0.5, 0.75
            return 1.0 + amplitude * sin(2 * pi * (t + phase));
          });

          double sumPulses = pulses.fold(0.0, (prev, value) => prev + value);
          List<double> widths =
              pulses.map((pulse) => (pulse / sumPulses) * screenWidth).toList();

          return Row(
            children: List.generate(4, (index) {
              return Container(
                width: widths[index],
                height: baseHeight,
                decoration: BoxDecoration(
                  color: _getColor(index),
                  boxShadow: [
                    BoxShadow(
                      color: _getColor(index).withAlpha((160).toInt()),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, -3.5),
                    )
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  // Rectangle colors.
  Color _getColor(int index) {
    switch (index) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.red;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: GlowingVoiceUI(),
    debugShowCheckedModeBanner: false,
  ));
}
