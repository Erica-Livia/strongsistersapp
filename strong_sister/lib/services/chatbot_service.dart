import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class ChatbotService {
  final String openAiApiKey = 'YOUR_OPENAI_API_KEY';
  final String openAiModel = 'gpt-4'; // Or any other model like gpt-3.5-turbo

  Future<List<Map<String, dynamic>>> loadResponses() async {
    final jsonString =
        await rootBundle.loadString('assets/strong_sister_dataset.jsonl');
    final lines = jsonString.split('\n');
    return lines
        .where((line) => line.isNotEmpty)
        .map((line) => json.decode(line) as Map<String, dynamic>)
        .toList();
  }

  Future<String> getResponse(String userInput) async {
    final predefinedResponse = await getPredefinedResponse(userInput);

    if (predefinedResponse != null) {
      return predefinedResponse;
    } else {
      return await getAiGeneratedResponse(userInput);
    }
  }

  Future<String?> getPredefinedResponse(String userInput) async {
    final responses = await loadResponses();

    for (var response in responses) {
      final messages = response['messages'] as List<dynamic>;

      // Search for user input in messages
      for (var message in messages) {
        if (message['role'] == 'user' &&
            userInput.trim().toLowerCase() ==
                message['content'].trim().toLowerCase()) {
          // Find corresponding assistant response
          final assistantResponse = messages.firstWhere(
            (msg) => msg['role'] == 'assistant',
            orElse: () => null,
          );
          return assistantResponse?['content'] ?? 'No response found.';
        }
      }
    }

    return null; // No predefined response found
  }

  Future<String> getAiGeneratedResponse(String userInput) async {
    final url = Uri.https('api.openai.com', '/v1/chat/completions');
    final headers = {
      'Authorization': 'Bearer $openAiApiKey',
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      "model": openAiModel,
      "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
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
