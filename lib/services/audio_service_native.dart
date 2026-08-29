import 'package:audioplayers/audioplayers.dart';

class AudioService {
  AudioService._internal();

  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  Stream<void> get onComplete => _player.onPlayerComplete;

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Future<void> prepareSound(String soundName, {required double volume}) async {
    final path = 'sounds/$soundName.mp3';

    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(volume);
    await _player.setSource(AssetSource(path));
  }

  Future<void> stopSound() => _player.stop();

  Future<void> pauseSound() => _player.pause();

  Future<void> resumeSound() => _player.resume();
}
