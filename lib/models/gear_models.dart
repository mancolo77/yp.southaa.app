class GearItem {
  final String id;
  final String name;
  final String category; // 'Apparel', 'Footwear', 'Equipment', 'Accessories'
  final String sport;
  final String note;

  const GearItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sport,
    this.note = '',
  });

  GearItem copyWith({
    String? id,
    String? name,
    String? category,
    String? sport,
    String? note,
  }) {
    return GearItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sport: sport ?? this.sport,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sport': sport,
        'note': note,
      };

  factory GearItem.fromJson(Map<String, dynamic> json) => GearItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        sport: json['sport'] as String? ?? 'General',
        note: json['note'] as String? ?? '',
      );
}

class GearKit {
  final String id;
  final String name;
  final String sport;
  final List<String> itemIds;

  const GearKit({
    required this.id,
    required this.name,
    required this.sport,
    required this.itemIds,
  });

  GearKit copyWith({
    String? id,
    String? name,
    String? sport,
    List<String>? itemIds,
  }) {
    return GearKit(
      id: id ?? this.id,
      name: name ?? this.name,
      sport: sport ?? this.sport,
      itemIds: itemIds ?? this.itemIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sport': sport,
        'itemIds': itemIds,
      };

  factory GearKit.fromJson(Map<String, dynamic> json) => GearKit(
        id: json['id'] as String,
        name: json['name'] as String,
        sport: json['sport'] as String? ?? 'General',
        itemIds: (json['itemIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}
