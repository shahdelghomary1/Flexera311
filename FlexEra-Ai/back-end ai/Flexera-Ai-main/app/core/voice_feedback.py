import time
import threading
import pyttsx3


class VoiceFeedback:

    def __init__(self, rate=150, volume=0.9, cooldown=3.0, voice_gender='female'):
        self.engine = pyttsx3.init()
        self.engine.setProperty('rate', rate)
        self.engine.setProperty('volume', volume)
        self._set_voice_gender(voice_gender)
        self.enabled = True
        self.is_speaking = False
        self.last_messages = {}
        self.cooldown = cooldown
        self.lock = threading.Lock()

    def _set_voice_gender(self, gender='female'):
        voices = self.engine.getProperty('voices')
        if not voices:
            return

        target = gender.lower()
        variant = '+f3' if target == 'female' else '+m3'

        # First, try to find a voice whose gender property matches directly
        gender_matched = next(
            (v for v in voices if getattr(v, 'gender', None) and v.gender.lower() == target),
            None
        )
        if gender_matched:
            self.engine.setProperty('voice', gender_matched.id)
            return

        # Fall back to eSpeak variant suffixes
        english_ids = ['gmw/en-us', 'gmw/en', 'gmw/en-gb-x-rp', 'gmw/en-029']
        base_voice = next((v for v in voices if v.id.split('+')[0] in english_ids), voices[0])

        # Strip any existing variant before appending the new one
        base_id = base_voice.id.split('+')[0]
        self.engine.setProperty('voice', base_id + variant)

    def set_voice(self, gender):
        self._set_voice_gender(gender)

    def list_available_voices(self):
        return self.engine.getProperty('voices')

    def speak(self, text, force=False):
        if not self.enabled or not text:
            return False

        now = time.time()
        with self.lock:
            if not force and text in self.last_messages:
                if now - self.last_messages[text] < self.cooldown:
                    return False
            self.last_messages[text] = now

        thread = threading.Thread(target=self._speak_thread, args=(text,), daemon=True)
        thread.start()
        return True

    def _speak_thread(self, text):
        self.is_speaking = True
        try:
            self.engine.say(text)
            self.engine.runAndWait()
        except Exception:
            pass
        finally:
            self.is_speaking = False

    def enable(self):
        self.enabled = True

    def disable(self):
        self.enabled = False

    def clear_cooldown(self):
        with self.lock:
            self.last_messages.clear()

    def stop(self):
        try:
            self.engine.stop()
        except Exception:
            pass
