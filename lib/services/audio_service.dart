import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playSound(String soundName) async {
    final path = 'sounds/$soundName.mp3';
    await _player.stop();
    await _player.play(AssetSource(path));
  }

  Future<void> stop() async {
    await _player.stop();
  }
}