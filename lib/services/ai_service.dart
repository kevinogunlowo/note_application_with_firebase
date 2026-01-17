import 'package:flutter_application_1/model/notes_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _apiKey = 'AIzaSyCfYbFIdumNFuZfnHVDsxcuVOKeADFDasQ';
  final GenerativeModel _model;

  AIService()
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,

        //This tells the AI how to behave
        systemInstruction: Content.system(
          "You are a helpful Note Asssistant."
          "You help users summarize, organize and improve their personal notes.",
        ),
      );
  Future<String> getAIResponse(String userInput) async {
    final response = await _model.generateContent([Content.text(userInput)]);
    return response.text ?? "I'm not sure how to help with that.";
  }

  Future<String> getAIResponseWithNotes(
    String userInput,
    List<Note> notes,
  ) async {
    //convert the List<Note> into a single string
    String notesContext = notes
        .map(
          (n) =>
              "Title: ${n.title}\nContent: ${n.content}\nTags: ${n.tags.join(',')}",
        )
        .join("\n\n---\n\n");

    final prompt = """ 
    You are a personal Note Assistant. Below are the user's saved notes: $notesContext
    User Question: $userInput

    Instructions: Use the notes provided above to answer the questions. 
    If the answer isn't in the notes, say you don't know based on their notes, but offer general help. 
        """;
    //Send to Gemini
    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? "I couldn't analyze your notes";
  }
}
