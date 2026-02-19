/// Enum untuk mendefinisikan tingkat kelangkaan (rarity) kartu
enum Rarity {
  normal('Normal'),
  elite('Elite'),
  rare('Rare'),
  superRare('Super Rare'),
  ultraRare('Ultra Rare');

  final String displayName;
  
  const Rarity(this.displayName);

  /// Konversi dari string ke enum
  static Rarity fromString(String value) {
    switch (value.toLowerCase()) {
      case 'normal':
        return Rarity.normal;
      case 'elite':
        return Rarity.elite;
      case 'rare':
        return Rarity.rare;
      case 'super rare':
      case 'superrare':
        return Rarity.superRare;
      case 'ultra rare':
      case 'ultrarare':
        return Rarity.ultraRare;
      default:
        return Rarity.normal;
    }
  }

  /// Konversi ke string untuk database
  String toJson() {
    return displayName; // Returns "Ultra Rare", "Super Rare", etc. to match DB
  }
}
