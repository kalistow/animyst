/// Model untuk profil user
class Profile {
  final String id;
  final String username;
  final int gems;
  final int dust;
  final int freeDust;
  final int pityCounter;
  final DateTime? lastLogin;

  Profile({
    required this.id,
    required this.username,
    this.gems = 0,
    this.dust = 0,
    this.freeDust = 3000,
    this.pityCounter = 0,
    this.lastLogin,
  });

  /// Factory constructor untuk membuat Profile dari JSON
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      username: json['username'] as String,
      gems: json['gems'] as int? ?? 0,
      dust: json['dust'] as int? ?? 0,
      freeDust: json['free_dust'] as int? ?? 3000,
      pityCounter: json['pity_counter'] as int? ?? 0,
      lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  /// Konversi Profile ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'gems': gems,
      'dust': dust,
      'free_dust': freeDust,
      'pity_counter': pityCounter,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Copy with method untuk membuat instance baru dengan beberapa field yang diupdate
  Profile copyWith({
    String? id,
    String? username,
    int? gems,
    int? dust,
    int? freeDust,
    int? pityCounter,
    DateTime? lastLogin,
  }) {
    return Profile(
      id: id ?? this.id,
      username: username ?? this.username,
      gems: gems ?? this.gems,
      dust: dust ?? this.dust,
      freeDust: freeDust ?? this.freeDust,
      pityCounter: pityCounter ?? this.pityCounter,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'Profile(id: $id, username: $username, gems: $gems, dust: $dust, pityCounter: $pityCounter)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Profile &&
      other.id == id &&
      other.username == username &&
      other.gems == gems &&
      other.dust == dust &&
      other.pityCounter == pityCounter &&
      other.lastLogin == lastLogin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      username.hashCode ^
      gems.hashCode ^
      dust.hashCode ^
      pityCounter.hashCode ^
      lastLogin.hashCode;
  }
}
