import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static AudioPlayer? _player;

  static AudioPlayer get _instance {
    _player ??= AudioPlayer();
    return _player!;
  }

  static Future<void> playAlertSound() async {
    try {
      await _instance.stop(); // stop if already playing
      await _instance.play(AssetSource('sounds/alert.mp3'));
    } catch (e) {
      print("Error playing alert sound: $e");
    }
  }

  static Future<void> stopAlertSound() async {
    await _instance.stop();
  }
}
