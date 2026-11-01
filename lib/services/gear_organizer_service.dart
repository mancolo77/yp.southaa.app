import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GearItem {
  final String id;
  final String name;
  final String category; // 'Одежда', 'Обувь', 'Инвентарь', 'Аксессуары'
  final String sport;
  final String note;

  GearItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sport,
    required this.note,
  });

  GearItem copyWith({
    String? name,
    String? category,
    String? sport,
    String? note,
  }) {
    return GearItem(
      id: id,
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
        sport: json['sport'] as String? ?? 'Спорт',
        note: json['note'] as String? ?? '',
      );
}

class GearKit {
  final String id;
  final String title;
  final List<String> itemIds;
  final Set<String> packedItemIds;

  GearKit({
    required this.id,
    required this.title,
    required this.itemIds,
    required this.packedItemIds,
  });

  GearKit copyWith({
    String? title,
    List<String>? itemIds,
    Set<String>? packedItemIds,
  }) {
    return GearKit(
      id: id,
      title: title ?? this.title,
      itemIds: itemIds ?? this.itemIds,
      packedItemIds: packedItemIds ?? this.packedItemIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'itemIds': itemIds,
        'packedItemIds': packedItemIds.toList(),
      };

  factory GearKit.fromJson(Map<String, dynamic> json) => GearKit(
        id: json['id'] as String,
        title: json['title'] as String,
        itemIds: (json['itemIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        packedItemIds: (json['packedItemIds'] as List<dynamic>?)?.map((e) => e.toString()).toSet() ?? {},
      );
}

class GearOrganizerService with ChangeNotifier {
  static final GearOrganizerService _instance = GearOrganizerService._internal();
  factory GearOrganizerService() => _instance;
  GearOrganizerService._internal();

  final List<GearItem> _gear = [];
  final List<GearKit> _kits = [];
  String _selectedKitId = 'kit_pool';

  List<GearItem> get gear => List.unmodifiable(_gear);
  List<GearKit> get kits => List.unmodifiable(_kits);
  String get selectedKitId => _selectedKitId;

  GearKit? get selectedKit {
    final idx = _kits.indexWhere((k) => k.id == _selectedKitId);
    if (idx != -1) return _kits[idx];
    return _kits.isNotEmpty ? _kits.first : null;
  }

  void selectKit(String id) {
    _selectedKitId = id;
    notifyListeners();
  }

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawGear = prefs.getString('gear_items');
      final rawKits = prefs.getString('gear_kits');

      _gear.clear();
      _kits.clear();

      if (rawGear != null && rawGear.isNotEmpty) {
        final List<dynamic> list = json.decode(rawGear);
        _gear.addAll(list.map((e) => GearItem.fromJson(e as Map<String, dynamic>)));
      } else {
        // Starter default gear
        _gear.addAll([
          GearItem(id: 'g_1', name: 'Беговые кроссовки', category: 'Обувь', sport: 'Бег', note: 'Амортизация для асфальта'),
          GearItem(id: 'g_2', name: 'Спортивные плавки', category: 'Одежда', sport: 'Плавание', note: 'Быстросохнущие'),
          GearItem(id: 'g_3', name: 'Очки для плавания', category: 'Аксессуары', sport: 'Плавание', note: 'Антифог покрытие'),
          GearItem(id: 'g_4', name: 'Силиконовая шапочка', category: 'Аксессуары', sport: 'Плавание', note: 'Для тренировок'),
          GearItem(id: 'g_5', name: 'Полотенце из микрофибры', category: 'Аксессуары', sport: 'Общий', note: 'Компактное'),
          GearItem(id: 'g_6', name: 'Бутылка для воды 750мл', category: 'Инвентарь', sport: 'Общий', note: 'Без BPA'),
          GearItem(id: 'g_7', name: 'Спортивные шорты', category: 'Одежда', sport: 'Фитнес', note: 'Дышащие'),
          GearItem(id: 'g_8', name: 'Футбольный мяч', category: 'Инвентарь', sport: 'Футбол', note: 'Размер 5'),
          GearItem(id: 'g_9', name: 'Эластичные бинты', category: 'Инвентарь', sport: 'Спортзал', note: 'Поддержка суставов'),
        ]);
        await _saveGear();
      }

      if (rawKits != null && rawKits.isNotEmpty) {
        final List<dynamic> list = json.decode(rawKits);
        _kits.addAll(list.map((e) => GearKit.fromJson(e as Map<String, dynamic>)));
      } else {
        // Starter editable kits
        _kits.addAll([
          GearKit(
            id: 'kit_pool',
            title: 'Бассейн',
            itemIds: ['g_2', 'g_3', 'g_4', 'g_5', 'g_6'],
            packedItemIds: {'g_2', 'g_5'},
          ),
          GearKit(
            id: 'kit_run',
            title: 'Пробежка',
            itemIds: ['g_1', 'g_7', 'g_6'],
            packedItemIds: {'g_1'},
          ),
          GearKit(
            id: 'kit_gym',
            title: 'Спортзал',
            itemIds: ['g_1', 'g_7', 'g_5', 'g_6', 'g_9'],
            packedItemIds: {},
          ),
        ]);
        await _saveKits();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveGear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gear_items', json.encode(_gear.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> _saveKits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gear_kits', json.encode(_kits.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  void addGearItem({
    required String name,
    required String category,
    required String sport,
    required String note,
  }) {
    final item = GearItem(
      id: 'gear_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      sport: sport,
      note: note,
    );
    _gear.insert(0, item);
    _saveGear();
    notifyListeners();
  }

  void updateGearItem(GearItem updated) {
    final idx = _gear.indexWhere((e) => e.id == updated.id);
    if (idx != -1) {
      _gear[idx] = updated;
      _saveGear();
      notifyListeners();
    }
  }

  void deleteGearItem(String id) {
    _gear.removeWhere((e) => e.id == id);
    for (int i = 0; i < _kits.length; i++) {
      final kit = _kits[i];
      final newItems = List<String>.from(kit.itemIds)..remove(id);
      final newPacked = Set<String>.from(kit.packedItemIds)..remove(id);
      _kits[i] = kit.copyWith(itemIds: newItems, packedItemIds: newPacked);
    }
    _saveGear();
    _saveKits();
    notifyListeners();
  }

  void toggleItemInKit(String kitId, String itemId) {
    final kitIdx = _kits.indexWhere((k) => k.id == kitId);
    if (kitIdx == -1) return;
    final kit = _kits[kitIdx];
    final items = List<String>.from(kit.itemIds);
    final packed = Set<String>.from(kit.packedItemIds);

    if (items.contains(itemId)) {
      items.remove(itemId);
      packed.remove(itemId);
    } else {
      items.add(itemId);
    }

    _kits[kitIdx] = kit.copyWith(itemIds: items, packedItemIds: packed);
    _saveKits();
    notifyListeners();
  }

  void togglePacked(String kitId, String itemId) {
    final kitIdx = _kits.indexWhere((k) => k.id == kitId);
    if (kitIdx == -1) return;
    final kit = _kits[kitIdx];
    final packed = Set<String>.from(kit.packedItemIds);

    if (packed.contains(itemId)) {
      packed.remove(itemId);
    } else {
      packed.add(itemId);
    }

    _kits[kitIdx] = kit.copyWith(packedItemIds: packed);
    _saveKits();
    notifyListeners();
  }

  void resetPacked(String kitId) {
    final kitIdx = _kits.indexWhere((k) => k.id == kitId);
    if (kitIdx == -1) return;
    final kit = _kits[kitIdx];
    _kits[kitIdx] = kit.copyWith(packedItemIds: {});
    _saveKits();
    notifyListeners();
  }

  void addKit(String title) {
    final newKit = GearKit(
      id: 'kit_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      itemIds: [],
      packedItemIds: {},
    );
    _kits.add(newKit);
    _selectedKitId = newKit.id;
    _saveKits();
    notifyListeners();
  }

  void deleteKit(String kitId) {
    _kits.removeWhere((k) => k.id == kitId);
    if (_selectedKitId == kitId && _kits.isNotEmpty) {
      _selectedKitId = _kits.first.id;
    }
    _saveKits();
    notifyListeners();
  }
}

