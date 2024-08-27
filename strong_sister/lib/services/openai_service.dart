import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'chatbot_service.dart';

class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final ChatbotService _chatbotService = ChatbotService();
  final String openAiModel =
      'gpt-4o-mini'; // You can change to the desired model, e.g., 'gpt-3.5-turbo'

  Future<String> getChatbotResponse(String prompt) async {
    print('Received prompt: $prompt'); // Debugging line

    // Check for a predefined response first
    final predefinedResponse =
        await _chatbotService.getPredefinedResponse(prompt);
    print('Predefined response: $predefinedResponse'); // Debugging line

    if (predefinedResponse != null) {
      return predefinedResponse;
    } else {
      // If no predefined response, generate a response using OpenAI
      return await _getAiGeneratedResponse(prompt);
    }
  }

  Future<String> _getAiGeneratedResponse(String userInput) async {
    final url = Uri.https('api.openai.com', '/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $_apiKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "model": openAiModel,
      "messages": [
        {
          "role": "system",
          "content":
              "You are a helpful assistant focused on women empowerment and the Strong Sister missions."
        },
        {"role": "user", "content": userInput}
      ],
      "max_tokens": 100,
      "temperature": 0.7,
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final String aiResponse =
          jsonResponse['choices'][0]['message']['content'];
      return aiResponse.trim();
    } else {
      return 'I am not sure how to respond to that. Please try asking something else.';
    }
  }
}
