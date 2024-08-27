from flask import Flask, request, jsonify
from datasets import load_dataset

app = Flask(__name__)

# Load the dataset
ds = load_dataset("alexandreteles/mental-health-conversational-data")

@app.route('/chat', methods=['POST'])
def chat():
    user_input = request.json.get('message')
    # Logic to get the response based on the user input from the dataset
    response = get_response(user_input)
    return jsonify({'response': response})

def get_response(user_input):
    # Basic logic to match user_input with dataset entries
    for example in ds['train']:
        if user_input.lower() in example['utterance'].lower():
            return example['response']

    # If no match is found, return a default message
    return "Sorry, I can't provide an answer to that. Please ask something else."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
