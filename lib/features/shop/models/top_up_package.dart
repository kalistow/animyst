class TopUpPackage {
  final int priceRp;
  final int gemsAmount;

  const TopUpPackage({
    required this.priceRp,
    required this.gemsAmount,
  });

  String get formattedPrice => 'Rp ${priceRp.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  String get formattedGems => '${gemsAmount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} Gems';

  static List<TopUpPackage> get packages => [
    const TopUpPackage(priceRp: 5000, gemsAmount: 1000),
    const TopUpPackage(priceRp: 10000, gemsAmount: 2500),
    const TopUpPackage(priceRp: 20000, gemsAmount: 5500),
    const TopUpPackage(priceRp: 50000, gemsAmount: 15000),
    const TopUpPackage(priceRp: 100000, gemsAmount: 35000),
  ];
}
