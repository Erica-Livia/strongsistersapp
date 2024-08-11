import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  final String _apiKey = 'YOUR_API_KEY';  

  Future<String> getChatbotResponse(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant."},
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 150,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      print('Failed to get response: ${response.body}');
      return 'Sorry, something went wrong. Please try again later.';
    }
  }
}
