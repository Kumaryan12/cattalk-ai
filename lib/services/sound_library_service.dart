import '../models/cat_sound.dart';

class SoundLibraryService {
  List<CatSound> getAllSounds() {
    return [
      CatSound(
        id: 'soft_trill_01',
        assetName: 'soft_trill_01',
        displayName: 'Soft Trill',
        type: SoundType.trill,
        energy: 'low',
        bestFor: 'Build trust / friendly greeting',
      ),
      CatSound(
        id: 'short_meow_01',
        assetName: 'short_meow_01',
        displayName: 'Short Meow',
        type: SoundType.meow,
        energy: 'medium',
        bestFor: 'Call cat / get attention',
      ),
      CatSound(
        id: 'food_call_01',
        assetName: 'food_call_01',
        displayName: 'Food Call',
        type: SoundType.call,
        energy: 'medium',
        bestFor: 'Food soon',
      ),
      CatSound(
        id: 'play_chirp_01',
        assetName: 'play_chirp_01',
        displayName: 'Play Chirp',
        type: SoundType.chirp,
        energy: 'high',
        bestFor: 'Playful interaction',
      ),
      CatSound(
        id: 'calm_purr_01',
        assetName: 'calm_purr_01',
        displayName: 'Calm Purr',
        type: SoundType.purr,
        energy: 'low',
        bestFor: 'Calm / relax',
      ),
    ];
  }
}
