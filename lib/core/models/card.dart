import '../enums/rarity.dart';

/// Model untuk kartu dalam game Gacha
class Card {
  final String id;
  final String name;
  final String imageUrl;
  final Rarity rarity;
  final int recycleDustValue;

  Card({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rarity,
    this.recycleDustValue = 0,
  });

  /// --- PERBAIKAN UTAMA: Penambahan Getter Description ---
  /// Ini menambahkan properti 'description' secara dinamis
  /// untuk menghilangkan error di card_detail_dialog.dart
  String get description {
    // Mengembalikan deskripsi sederhana berdasarkan nama dan rarity
    return '$name adalah koleksi dengan tingkat kelangkaan ${rarity.toString().split('.').last}.';
  }

  /// Factory constructor untuk membuat Card dari JSON
  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      // Menggunakan .toString() agar aman jika DB mengirim format angka (BigInt)
      id: json['id'].toString(), 
      name: json['name'] as String,
      imageUrl: json['image_url'] as String,
      rarity: Rarity.fromString(json['rarity'] as String),
      recycleDustValue: json['recycle_dust_value'] as int? ?? 0,
    );
  }

  /// Konversi Card ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'rarity': rarity.toJson(),
      'recycle_dust_value': recycleDustValue,
    };
  }

  /// Copy with method untuk membuat instance baru dengan beberapa field yang diupdate
  Card copyWith({
    String? id,
    String? name,
    String? imageUrl,
    Rarity? rarity,
    int? recycleDustValue,
  }) {
    return Card(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      rarity: rarity ?? this.rarity,
      recycleDustValue: recycleDustValue ?? this.recycleDustValue,
    );
  }

  @override
  String toString() {
    // Pastikan rarity.displayName tersedia di Enum Rarity kamu, 
    // jika tidak, ganti dengan rarity.toString()
    return 'Card(id: $id, name: $name, rarity: $rarity, recycleDustValue: $recycleDustValue)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Card &&
      other.id == id &&
      other.name == name &&
      other.imageUrl == imageUrl &&
      other.rarity == rarity &&
      other.recycleDustValue == recycleDustValue;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      imageUrl.hashCode ^
      rarity.hashCode ^
      recycleDustValue.hashCode;
  }
}