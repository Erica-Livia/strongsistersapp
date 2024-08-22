import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chatbot_service.dart';


class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final ChatbotService _chatbotService = ChatbotService();

  Future<String> getChatbotResponse(String prompt) async {
    print('Received prompt: $prompt'); // Debugging line

    // Check for a predefined response first
    final predefinedResponse = await _chatbotService.getPredefinedResponse(prompt);
    print('Predefined response: $predefinedResponse'); // Debugging line

    if (predefinedResponse != null) {
      return predefinedResponse;
    } else {
      // If no predefined response, return a message stating the query is not supported
      return 'Sorry, I cannot answer that question. Please ask something related to our predefined topics.';
    }
  }
}
