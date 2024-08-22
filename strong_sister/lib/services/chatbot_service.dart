import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ChatbotService {
  Future<List<Map<String, dynamic>>> loadResponses() async {
    final jsonString = await rootBundle.loadString('assets/strong_sister_dataset.jsonl');
    final lines = jsonString.split('\n');
    return lines
        .where((line) => line.isNotEmpty)
        .map((line) => json.decode(line) as Map<String, dynamic>)
        .toList();
  }

  Future<String?> getPredefinedResponse(String userInput) async {
    final responses = await loadResponses();

    for (var response in responses) {
      final messages = response['messages'] as List<dynamic>;

      // Search for user input in messages
      for (var message in messages) {
        if (message['role'] == 'user' && userInput.trim().toLowerCase() == message['content'].trim().toLowerCase()) {
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
}
