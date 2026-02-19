
  Widget _buildCardImage(String imageUrl, Rarity rarity, Color color) {
    if (imageUrl.isEmpty) {
      return Icon(
        _getCardIcon(rarity),
        size: 80,
        color: color,
      );
    }

    // Cek jika URL adalah remote (http/https)
    if (imageUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(75), // Half of width/height (150/2)
        child: Image.network(
          imageUrl,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Icon(
            _getCardIcon(rarity),
            size: 80,
            color: color,
          ),
        ),
      );
    }
    
    // Asumsi asset lokal
    // Pastikan path assets sudah didaftarkan di pubspec.yaml
    // Contoh path di DB: "dragon.png", kita prefix dengan "assets/images/"
    return ClipRRect(
      borderRadius: BorderRadius.circular(75),
      child: Image.asset(
        'assets/images/$imageUrl',
        width: 150,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Icon(
          _getCardIcon(rarity),
          size: 80,
          color: color,
        ),
      ),
    );
  }
