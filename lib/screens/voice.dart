import 'dart:math';
import 'dart:async';
import 'package:aiassistant/animations/audio_visualizer.dart';
import 'package:aiassistant/providers/chat_provider.dart';
import 'package:aiassistant/providers/transcribe_provider.dart';
import 'package:aiassistant/services/flutter_tts.dart';
import 'package:aiassistant/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key});

  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  final FlutterTts flutterTts = FlutterTts();
  late final AudioRecorder _audioRecorder;
  String? serverUrl;
  bool isRecording = false;
  bool _speaking = false;
  bool _thinking = false;
  String? _audioPath;
  Timer? _timer;
  final List<double> _audioLevels = [];

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(
      10,
      (index) => chars[random.nextInt(chars.length)],
      growable: false,
    ).join();
  }

  Future<void> _startRecording() async {
    setState(() {
      isRecording = true;
      _thinking = true;
    });
    try {
      debugPrint('RECORDING!!!!!!!!!!!!!!!');

      String filePath = await getApplicationDocumentsDirectory().then(
        (value) => '${value.path}/${_generateRandomId()}.wav',
      );

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav, // specify the codec to be `.wav`
        ),
        path: filePath,
      );
      _startLevelMonitor();
    } catch (e) {
      debugPrint('ERROR WHILE RECORDING: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await _audioRecorder.stop();

      setState(() {
        isRecording = false;
        _audioPath = path!;
      });
      debugPrint('PATH: $_audioPath');
      if (mounted) {
        Provider.of<TranscribeProvider>(context, listen: false)
            .sendVoice(
              audiopath: _audioPath!,
              chatProvider: Provider.of<ChatProvider>(context, listen: false),
            )
            .then((value) {
              setState(() {
                _speaking = true;
                _thinking = false;
              });
            });
      }
      _stopLevelMonitor();
    } catch (e) {
      debugPrint('ERROR WHILE STOP RECORDING: $e');
    }
  }

  // Monitor audio levels in real-time
  void _startLevelMonitor() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (
      Timer timer,
    ) async {
      final level = await _audioRecorder.getAmplitude();

      setState(() {
        _audioLevels.add(level.current);
        if (_audioLevels.length > 50) {
          // Keep a reasonable number of data points
          _audioLevels.removeAt(0);
        }
      });
    });
  }

  // Stop monitoring
  void _stopLevelMonitor() {
    _timer?.cancel();
  }

  void _record() async {
    if (isRecording == false) {
      final status = await Permission.microphone.request();

      if (status == PermissionStatus.granted) {
        setState(() {
          isRecording = true;
        });
        await _startRecording();
      } else if (status == PermissionStatus.permanentlyDenied) {
        debugPrint('Permission permanently denied');
        openAppSettings();
      }
    } else {
      await _stopRecording();

      setState(() {
        isRecording = false;
      });
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _stopLevelMonitor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Speech-to-Text')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: _record,
                child: Text(isRecording ? 'Stop Listening' : 'Start Listening'),
              ),
              SizedBox(height: 20),
              _thinking ? Image.asset(Images.thinking, scale: 1) : SizedBox(),
              _speaking
                  ? Image.asset(Images.visualizer, scale: 2.5)
                  : SizedBox(),
              SizedBox(height: 20),
              _speaking
                  ? ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _speaking = false;
                      });
                      await flutterTts.stop();
                    },
                    child: Text('Stop Speaking'),
                  )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
