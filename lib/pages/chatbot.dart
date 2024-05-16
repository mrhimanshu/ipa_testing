import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:jumping_dot/jumping_dot.dart';
import 'dart:convert';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class ChatScreen extends StatefulWidget {
  final String userId;

  // Constructor to receive the userId as an argument
  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class Message {
  final String text;
  final bool isUser;
  final bool isLoading;

  Message({required this.text, required this.isUser, required this.isLoading});
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _textController = TextEditingController();
  List<Map<String, dynamic>> _messages_user = [];

  List<Message> _messages = [
    Message(text: "Hello!", isUser: true, isLoading: false),
    Message(
        text:
            "Hey !! \n\nI am your helpful medical bot. Kindly ask your query...",
        isUser: false,
        isLoading: true), // Placeholder for bot response
  ];

  bool _isSending = false;
  bool _isPublicAnswer = false; // New variable to track public answer toggle

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    setState(() {
      _messages.add(Message(text: message, isUser: true, isLoading: false));
      _isSending = true;
    });

    _textController.clear();

    setState(() {
      _messages.add(Message(text: "", isUser: false, isLoading: true));
      _isSending = true;
    });

    // Make API call to get the bot's response
    _fetchBotResponse(message);
  }

  void _fetchBotResponse(String message) async {
    // final String userId = ModalRoute.of(context)!.settings.arguments as String;
    final String userId = widget.userId;
    print(userId);
    print(message);

    // Define the query parameter for public answer
    final String publicParam = _isPublicAnswer ? 'public=true' : 'public=false';

    final url = Uri.parse(
        // 'https://304a-2405-201-4036-8912-19de-d411-5c2f-9984.ngrok-free.app/model?ques=$userId&data=$message');
        // 'https://memrhimanshu.loca.lt/model?conversation_id=$userId&ques=$message&$publicParam');
        'https://d29215ecd7b884fdaa0969642fbd056a7.clg07azjl.paperspacegradient.com/model?conversation_id=$userId&ques=$message&$publicParam');
    final client = http.Client();
    String botResponse = '';
    try {
      final request = http.Request('GET', url);

      request.headers.addAll({
        'Access-Control-Allow-Origin': '*', // Allow requests from any origin
      });

      final response = await client.send(request);

      // Read and print the chunks from the response stream
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        // Process each chunk as it is received
        botResponse += chunk;
        setState(() {
          _messages.last =
              Message(text: botResponse, isUser: false, isLoading: true);
          _isSending = true;
        });
      }

      // Set final AI response message with loading indicator turned off
      setState(() {
        _messages.last =
            Message(text: botResponse, isUser: false, isLoading: false);
        _isSending = false;
      });
    } catch (e) {
      print("Error: $e");
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'MediQuery',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Public',
                style: TextStyle(
                  fontSize: 15, // Adjust font size as needed
                  color: Color.fromARGB(255, 46, 46, 46), // Set text color
                ),
              ),
              Transform.scale(
                scale: 0.7, // Adjust the scale factor as needed
                child: Switch(
                  value: _isPublicAnswer,
                  onChanged: (value) {
                    setState(() {
                      _isPublicAnswer = value;
                    });
                  },
                  activeColor: Color.fromARGB(255, 144, 203, 185),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Text("Public Answer"),
            //     Switch(
            //       activeColor: Color.fromARGB(255, 144, 203, 185),
            //       value: _isPublicAnswer,
            //       onChanged: (value) {
            //         setState(() {
            //           _isPublicAnswer = value;
            //         });
            //       },
            //     ),
            //   ],
            // ),
            Expanded(
              child: ListView.separated(
                reverse: true,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.grey,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _messages.length - 1 - index;
                  final message = _messages[reversedIndex];
                  final isUserMessage = message.isUser;
                  final alignment = isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft;
                  final icon = isUserMessage ? Icons.person : Icons.radar;

                  return Row(
                    mainAxisAlignment: isUserMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        color: isUserMessage
                            ? Color.fromARGB(255, 144, 203, 185)
                            : Colors.black,
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: message.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied to clipboard')),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isUserMessage
                                  ? Color.fromARGB(255, 144, 203, 185)
                                  : Color.fromARGB(255, 250, 250, 250),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: [
                                HtmlWidget(
                                  message.text,
                                  textStyle: TextStyle(
                                    color: isUserMessage
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(children: [
                      if (_isSending)
                        JumpingDots(
                          color: Color.fromARGB(255, 144, 203, 185),
                          radius: 8,
                          numberOfDots: 5,
                        ),
                      TextField(
                        enabled: !_isSending,
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter a message',
                        ),
                      ),
                    ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _isSending
                        ? null
                        : () => _sendMessage(_textController.text),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
