enum SoundType {
  trill,
  meow,
  chirp,
  purr,
  call,
}

class CatSound {
  final String id;
  final String assetName;
  final String displayName;
  final SoundType type;
  final String energy;
  final String bestFor;

  CatSound({
    required this.id,
    required this.assetName,
    required this.displayName,
    required this.type,
    required this.energy,
    required this.bestFor,
  });
}