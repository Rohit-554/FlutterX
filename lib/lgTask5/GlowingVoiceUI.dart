import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(VoiceAssistantApp());
}

class VoiceAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: VoiceAssistantScreen(),
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap the mic and start speaking...";
  double _bubbleSize = 100;
  bool _isInitialized = false;
  double _soundLevel = 0.0;
  final double _baseSize = 100;
  String _debugText = "";

  late AnimationController _idleAnimationController;
  late Animation<double> _idleAnimation;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializeSpeech();

    _idleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _idleAnimation = Tween<double>(begin: _baseSize, end: _baseSize + 2).animate(
      CurvedAnimation(
        parent: _idleAnimationController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
      if (_soundLevel <= 0.1) {
        setState(() {
          _bubbleSize = _idleAnimation.value;
        });
      }
    });

    _idleAnimationController.repeat(reverse: true);
  }

  Future<void> _initializeSpeech() async {
    try {
      var status = await Permission.microphone.request();
      if (status.isGranted) {
        _isInitialized = await _speech.initialize(
          onError: (error) {
            _resetStates();
          },
          onStatus: (status) {
            if (status == 'notListening' || status == 'done') {
              _resetStates();
            }
          },
        );
        setState(() {});
      }
    } catch (e) {
      print('Error initializing speech recognition: $e');
    }
  }

  void _resetStates() {
    setState(() {
      _isListening = false;
      _soundLevel = 0.0;
      _bubbleSize = _baseSize;
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
    if (!_isInitialized) {
      await _initializeSpeech();
    }

    try {
      if (_isInitialized) {
        setState(() {
          _isListening = true;
          _bubbleSize = _idleAnimation.value;
        });

        await _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
            });
          },
          listenFor: Duration(seconds: 30),
          pauseFor: Duration(seconds: 3),
          onSoundLevelChange: (level) {
            double mappedLevel = _mapSoundLevel(level);
            setState(() {
              _soundLevel = level;
              _debugText = "Raw Level: $level, Mapped: $mappedLevel";
              print(_debugText);
              if (mappedLevel > 0.1) {
                double scaleFactor = level * level;
                _bubbleSize = _baseSize + (scaleFactor );
              } else {
                _bubbleSize = _idleAnimation.value;
              }
            });
          },
          listenOptions: stt.SpeechListenOptions(
            listenMode: stt.ListenMode.confirmation,
            cancelOnError: true,
            partialResults: true,
          )
        );
      } else {
        setState(() {
          _text = "Speech recognition not available";
        });
      }
    } catch (e) {
      _resetStates();
      setState(() {
        _text = "Error starting speech recognition";
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    _resetStates();
  }

  @override
  void dispose() {
    _speech.stop();
    _idleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: _bubbleSize,
              height: _bubbleSize,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: (_soundLevel > 0.1 ? 0.3 + (_soundLevel * 0.4) : 0.3).clamp(0.0, 1.0)),
                    Colors.purple.withValues(alpha: (_soundLevel > 0.1 ? 0.3 + (_soundLevel * 0.4) : 0.3).clamp(0.0, 1.0)),
                  ],
                  center: Alignment.center,
                  radius: 1.0,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    blurRadius: _soundLevel > 0.1 ? 10 + (_soundLevel * 15) : 10,
                    spreadRadius: _soundLevel > 0.1 ? (_soundLevel * 8) : 0,
                  ),
                ],
              ),
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _text,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(height: 30),
          FloatingActionButton(
            onPressed: _isListening ? _stopListening : _startListening,
            backgroundColor: _isListening ? Colors.red : Colors.blueAccent,
            child: Icon(_isListening ? Icons.stop : Icons.mic),
          ),
        ],
      ),
    );
  }
}