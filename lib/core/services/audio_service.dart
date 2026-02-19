import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class AudioService {
  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;
  bool _isPlaying = false;

  AudioService() {
    // Setup player
    _bgmPlayer.setReleaseMode(ReleaseMode.loop); // Loop continuously
    _bgmPlayer.setVolume(0.5); // Default volume 50%
  }

  Future<void> playBgm() async {
    if (_isPlaying) return;
    
    try {
      // Assumes file is at assets/audio/bgm.mp3
      await _bgmPlayer.play(AssetSource('audio/bgm.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('Error playing BGM: $e');
    }
  }

  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
    _isPlaying = false;
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _bgmPlayer.setVolume(_isMuted ? 0 : 0.5);
  }

  bool get isMuted => _isMuted;
  bool get isPlaying => _isPlaying;
}
