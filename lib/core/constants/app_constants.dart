/// Constants untuk aplikasi Animyst Gacha Game
class AppConstants {
  // Supabase configuration
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  // Game constants
  static const int startingGems = 100;
  static const int startingDust = 0;
  static const int maxPityCounter = 69; // Guaranteed Ultra Rare at pull #70
  
  // Gacha rates (dalam persen)
  // Pity: Pull ke-70 (pity_counter >= 69) guaranteed Ultra Rare
  static const double normalRate = 50.0;     // 50% (50-100)
  static const double eliteRate = 30.0;      // 30% (20-50)
  static const double rareRate = 15.0;       // 15% (5-20)
  static const double superRareRate = 4.5;   // 4.5% (0.5-5.0)
  static const double ultraRareRate = 0.5;   // 0.5% (0-0.5)

  // Pull costs
  static const int singlePullCost = 100;     // Cost in gems
  static const int tenPullCost = 900;        // 10% discount
  
  // Dust values (override jika tidak diset di database)
  static const int normalDustValue = 5;
  static const int eliteDustValue = 15;
  static const int rareDustValue = 30;
  static const int superRareDustValue = 60;
  static const int ultraRareDustValue = 150;

  // Table names
  static const String profilesTable = 'profiles';
  static const String cardsTable = 'cards';
  static const String userCardsTable = 'user_cards';

  // Storage buckets
  static const String cardImagesBucket = 'card_images';

  // App info
  static const String appName = 'Animyst';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Gacha Game dengan Supabase';
}
