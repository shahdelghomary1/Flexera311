import time
import threading
import os
from gtts import gTTS

class VoiceFeedback:
    """
    Handles audio feedback generation for the FlexEra AI system using Google TTS.
    Designed for cloud environments where local audio drivers are unavailable.
    """
    def __init__(self, cooldown=3.0, voice_gender='female'):
        self.enabled = True
        self.cooldown = cooldown
        self.last_messages = {}
        self.lock = threading.Lock()
        
        # Directory for storing generated audio files
        self.temp_dir = "temp_audio"
        if not os.path.exists(self.temp_dir):
            os.makedirs(self.temp_dir)
            
        print("[FlexEra AI] Voice System Initialized.")

    def speak(self, text, force=False):
        """
        Processes text for voice feedback. In a cloud environment, it logs the 
        text and generates an MP3 file asynchronously.
        """
        if not self.enabled:
            return False

        # 1. Validation: Ensure text is not empty
        if not text or not text.strip():
            return False

        current_time = time.time()
        
        # 2. Cooldown Logic: Prevent spamming the same message
        with self.lock:
            if not force and text in self.last_messages:
                if current_time - self.last_messages[text] < self.cooldown:
                    return False
            self.last_messages[text] = current_time

        # 3. Logging: Print to server console for monitoring
        print(f"[FlexEra Voice]: {text}")

        # 4. Audio Generation: Run in a separate thread to avoid blocking the API
        thread = threading.Thread(target=self._generate_audio, args=(text,))
        thread.daemon = True # Ensures thread closes when server stops
        thread.start()
        
        return True

    def _generate_audio(self, text):
        """Internal method to generate MP3 using gTTS."""
        try:
            tts = gTTS(text=text, lang='en')
            filename = os.path.join(self.temp_dir, f"feedback_{int(time.time())}.mp3")
            tts.save(filename)
            print(f"[FlexEra AI] Audio saved: {filename}")
        except Exception as e:
            print(f"[FlexEra AI] Voice Generation Error: {e}")

    # Compatibility methods for the system architecture
    def enable(self):
        self.enabled = True

    def disable(self):
        self.enabled = False

    def clear_cooldown(self):
        with self.lock:
            self.last_messages.clear()

    def stop(self):
        pass