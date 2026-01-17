import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/notes_model.dart';
import 'package:flutter_application_1/services/ai_service.dart';
import 'package:flutter_application_1/services/messenger.dart';

class AIChatBottomSheet extends StatefulWidget {
  final List<Note> currentNotes;
  const AIChatBottomSheet({super.key, required this.currentNotes});
  @override
  State<AIChatBottomSheet> createState() => _AIChatBottomSheetState();
}

class _AIChatBottomSheetState extends State<AIChatBottomSheet> {
  final List<ChatMessage> _messages = [];

  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();
  bool _isTyping = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userText = _controller.text;
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _isTyping = true;
      _controller.clear();
    });

    //Call the New method and pass the notes from the widget
    final response = await _aiService.getAIResponse(_controller.text);

    setState(() {
      _messages.add(ChatMessage(text: response, isUser: false));
      _isTyping = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Note Assistant",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder:
                  (context, i) => ListTile(
                    title: Align(
                      alignment:
                          _messages[i].isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _messages[i].isUser
                                  ? Colors.blue
                                  : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _messages[i].text,
                          style: TextStyle(
                            color:
                                _messages[i].isUser
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
          ),
          if (_isTyping) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask me anything....",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
