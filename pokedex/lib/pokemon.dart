class Pokemon {
  final String name;
  final List<String> types;
  final int spriteId;
  int level;

  Pokemon({
    required this.name,
    required this.types,
    required this.spriteId,
    required this.level,
  });

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$spriteId.png';
}
