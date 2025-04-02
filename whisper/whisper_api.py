import os
import whisper
import requests
from flask import Flask, request, jsonify
import tempfile
from pydub import AudioSegment

app = Flask(__name__)

# Load the Whisper model
model = whisper.load_model("base")

host = os.environ.get('HOST')
LM_STUDIO_URL = os.environ.get('LM_STUDIO_URL')

@app.route("/transcribe", methods=["POST"])
def transcribe_audio():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No audio file provided"}), 400

        audio_file = request.files["file"]
        print(f"sent file: {audio_file.filename}")

        # Save the audio file to a temporary location
        temp_dir = tempfile.TemporaryDirectory()
        temp_path = os.path.join(temp_dir.name, audio_file.filename)
        audio_file.save(temp_path)

        if not os.path.exists(temp_path):
            return jsonify({"error": "File does not exist"}), 500

        # Load the audio for Whisper
        audio = whisper.load_audio(temp_path)
        print("Loading audio for Whisper...")

        # Transcribe the audio
        result = model.transcribe(audio, verbose=True, language="en")
        transcribed_text = result["text"]
        print(f"Transcription: {transcribed_text}")

        # Get AI response after transcription
        ai_response = generate_ai_response(transcribed_text)
        print(f"AI Response: {ai_response}")

        # return jsonify({"transcribed_text": transcribed_text, "ai_response": ai_response})
        return jsonify({"transcribed_text": transcribed_text})

    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500

def generate_ai_response(transcribed_text):
    print("Send transcription to LM Studio.")
    payload = {
        "model": "meta-llama-3-8b-instruct",
        "messages": [{"role": "user", "content": transcribed_text}],
        "max_tokens": 200
    }

    response = requests.post(LM_STUDIO_URL, json=payload)
    print(f"Response: {response.status_code}")
    if response.status_code == 200:
        return response.json().get("choices", [{}])[0].get("message", {}).get("content", "")
    else:
        return "Error in AI response."
    

if __name__ == "__main__":
    app.run(host=host, port=7006, debug=True)