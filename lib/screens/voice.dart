import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SpeechToTextPage extends StatefulWidget {
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late IO.Socket socket;
  String transcription = "";
  bool isListening = false;
  String? serverUrl;

  @override
  void initState() {
    super.initState();
    // Initialize socket, but don't connect yet
    serverUrl = dotenv.env['SERVER_URL'];
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  // Establish WebSocket connection to the Python server when button is pressed
  void startListening() {
    setState(() {
      isListening = true;
    });

    socket.connect();

    // Listen for 'transcription' messages from the server
    socket.on('transcription', (data) {
      setState(() {
        transcription = data['text'];
      });
    });
  }

  // Stop listening and disconnect the socket
  void stopListening() {
    setState(() {
      isListening = false;
    });

    socket.emit(
      'stop_listening',
    ); // Send message to stop the server-side listening
    socket.disconnect();
  }

  @override
  void dispose() {
    socket.disconnect();
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
              Text(
                'Transcription: $transcription',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    isListening
                        ? stopListening
                        : startListening, // Switch button behavior
                child: Text(isListening ? 'Stop Listening' : 'Start Listening'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
