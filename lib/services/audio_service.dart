import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._internal();

  static final AudioService _instance = AudioService._internal();

  factory AudioService() {
    return _instance;
  }

  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String soundName) async {
    final path = 'sounds/$soundName.mp3';

    await _player.stop();
    await _player.play(
      AssetSource(path),
    );
  }

  Future<void> stopSound() async {
    await _player.stop();
  }

  Future<void> pauseSound() async {
    await _player.pause();
  }

  Future<void> resumeSound() async {
    await _player.resume();
  }
}