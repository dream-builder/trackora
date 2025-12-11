import 'package:flutter_tts/flutter_tts.dart';

final FlutterTts _tts = FlutterTts();

Future<void> initTTS() async {
  _tts.setLanguage("en-CA"); //"bn-BD","en-US", ar-AE = Arabic, en-CA = Canada , es-MX = Spanish
  _tts.setSpeechRate(0.5);
  _tts.setVolume(1.0);
  await _tts.setPitch(1.0);
}

Future speak(String text) async {
  await _tts.speak(text);
}