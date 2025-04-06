import 'package:aiassistant/animations/threedots.dart';
import 'package:aiassistant/screens/voice.dart';
import 'package:aiassistant/utils/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  // ignore: unused_field
  int _index = 0;

  void _sendMessage() {
    setState(() {
      _loading = true;
    });
    if (_controller.text.isEmpty) {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => SpeechToTextPage(),
        ),
      );
    } else {
      Provider.of<ChatProvider>(context, listen: false).setLoading(true);
      Provider.of<ChatProvider>(
        context,
        listen: false,
      ).addUserMessage(_controller.text);
      _controller.clear();
    }
  }
  @override
  Widget build(BuildContext context) {
    var chatProvider = Provider.of<ChatProvider>(context);
    // bool loading = Provider.of<ChatProvider>(context).isLoading;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey,
        title: const Text(
          'Ask Me',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // dismiss the keyboard
          },
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    _index = index;
                    var message = chatProvider.messages;
                    return Align(
                      alignment:
                          message[index].isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child:
                          message[index].isUser
                              ? Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      message[index].isUser
                                          ? Color(0xFFE5E4E2)
                                          : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message[index].text,
                                  style: TextStyle(fontSize: 17),
                                ),
                              )
                              : Padding(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 40,
                                  bottom: 15,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Image(
                                      image: AssetImage(Images.neurology),
                                      height: 25,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(width: 5),
                                    // _loading
                                    //     ? ThreeDotsLoader()
                                    //     :
                                    Flexible(
                                      child: Text(
                                        message[index].text,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(fontSize: 17),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: Offset(0, -3),
                      color: Color(0xFFf0f0f0),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                              selectionColor: Color(0xFFd4d4d4),
                              selectionHandleColor: Colors.black,
                            ),
                          ),
                          child: TextField(
                            style: TextStyle(fontSize: 18),
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 6,
                            controller: _controller,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Ask me...',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _controller.text = value;
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon:
                            _controller.text.isNotEmpty
                                ? Icon(Icons.arrow_upward_rounded)
                                : Icon(Icons.voice_chat),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
