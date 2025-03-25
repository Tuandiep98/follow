import 'package:groq/groq.dart';

class GroqAIUtils {
  static late Groq groq;

  static void initGroq() {
    groq = Groq(
      apiKey: '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',
      model: "llama-3.3-70b-versatile",
    );
    groq.startChat();
  }

  static void setCustomInstructions(String instructions) {
    groq.setCustomInstructionsWith(instructions);
  }

  static Future<String> sendMessage(String message) async {
    GroqResponse response = await groq.sendMessage(message);
    return response.choices.first.message.content;
  }

  static void clearChat() {
    groq.clearChat();
  }

  static void removeCustomInstructions() {
    groq.removeCustomInstructions();
  }
}
