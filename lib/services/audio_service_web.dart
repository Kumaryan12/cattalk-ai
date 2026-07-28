import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Browser audio implementation that never waits for Safari's preload event.
class AudioService {
  AudioService._internal() {
    _player.preload = 'auto';
    _player.onEnded.listen((_) => _completionController.add(null));
  }

  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  final web.HTMLAudioElement _player = web.HTMLAudioElement();
  final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  String? _preparedSound;

  Stream<void> get onComplete => _completionController.stream;

  Future<void> setVolume(double volume) {
    _player.volume = volume;
    return Future.value();
  }

  Future<void> prepareSound(String soundName, {required double volume}) {
    _player.volume = volume;
    if (_preparedSound == soundName) return Future.value();

    _player.pause();
    _player.src = 'assets/assets/sounds/$soundName.mp3';
    _player.load();
    _preparedSound = soundName;
    return Future.value();
  }

  Future<void> stopSound() {
    _player.pause();
    _player.currentTime = 0;
    return Future.value();
  }

  Future<void> pauseSound() {
    _player.pause();
    return Future.value();
  }

  Future<void> resumeSound() async {
    // Invoke play synchronously inside the tap handler. Converting and awaiting
    // the returned promise happens only after the browser has accepted it.
    final playRequest = _player.play();
    await playRequest.toDart;
  }
}
