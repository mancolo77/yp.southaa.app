import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gear_models.dart';

class GearStorageService extends ChangeNotifier {
  static final GearStorageService _instance = GearStorageService._internal();
  factory GearStorageService() => _instance;
  GearStorageService._internal();

  List<GearItem> _items = [];
  List<GearKit> _kits = [];
  String _activeKitId = '';
  final Map<String, Set<String>> _kitPackedItems = {};
  bool _initialized = false;

  List<GearItem> get items => List.unmodifiable(_items);
  List<GearKit> get kits => List.unmodifiable(_kits);
  String get activeKitId => _activeKitId;

  GearKit? get activeKit {
    if (_activeKitId.isEmpty && _kits.isNotEmpty) {
      _activeKitId = _kits.first.id;
    }
    return _kits.firstWhere(
      (k) => k.id == _activeKitId,
      orElse: () => _kits.isNotEmpty ? _kits.first : const GearKit(id: '', name: '', sport: '', itemIds: []),
    );
  }

  Set<String> get packedItemIds {
    if (_activeKitId.isEmpty) return {};
    return _kitPackedItems[_activeKitId] ?? {};
  }

  Future<void> init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();

    final rawItems = prefs.getString('g_items_data');
    final rawKits = prefs.getString('g_kits_data');
    _activeKitId = prefs.getString('g_active_kit_id') ?? '';

    if (rawItems != null && rawItems.isNotEmpty) {
      try {
        final List list = jsonDecode(rawItems);
        _items = list.map((e) => GearItem.fromJson(e)).toList();
      } catch (_) {
        _loadDefaultData();
      }
    } else {
      _loadDefaultData();
    }

    if (rawKits != null && rawKits.isNotEmpty) {
      try {
        final List list = jsonDecode(rawKits);
        _kits = list.map((e) => GearKit.fromJson(e)).toList();
      } catch (_) {}
    }

    // Load packed states
    final rawPacked = prefs.getString('g_packed_states');
    if (rawPacked != null && rawPacked.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(rawPacked);
        map.forEach((kitId, list) {
          _kitPackedItems[kitId] = (list as List).map((e) => e.toString()).toSet();
        });
      } catch (_) {}
    }

    if (_activeKitId.isEmpty && _kits.isNotEmpty) {
      _activeKitId = _kits.first.id;
    }

    _initialized = true;
    notifyListeners();
  }

  void _loadDefaultData() {
    _items = [
      const GearItem(
        id: 'i_1',
        name: 'Road Running Shoes',
        category: 'Footwear',
        sport: 'Running',
        note: 'Cushioned daily trainers',
      ),
      const GearItem(
        id: 'i_2',
        name: 'Moisture-wicking T-Shirt',
        category: 'Apparel',
        sport: 'Running',
        note: 'Lightweight breathable fabric',
      ),
      const GearItem(
        id: 'i_3',
        name: 'Breathable Running Shorts',
        category: 'Apparel',
        sport: 'Running',
        note: 'With zippered key pocket',
      ),
      const GearItem(
        id: 'i_4',
        name: 'GPS Sports Watch',
        category: 'Accessories',
        sport: 'Running',
        note: 'Heart rate monitor and pace tracking',
      ),
      const GearItem(
        id: 'i_5',
        name: 'Insulated Water Bottle',
        category: 'Accessories',
        sport: 'General',
        note: '750ml stainless steel bottle',
      ),
      const GearItem(
        id: 'i_6',
        name: 'Swimming Goggles',
        category: 'Equipment',
        sport: 'Swimming',
        note: 'Anti-fog mirrored lenses',
      ),
      const GearItem(
        id: 'i_7',
        name: 'Microfiber Towel',
        category: 'Accessories',
        sport: 'Swimming',
        note: 'Fast-drying compact towel',
      ),
      const GearItem(
        id: 'i_8',
        name: 'Pool Slides / Flip Flops',
        category: 'Footwear',
        sport: 'Swimming',
        note: 'Slip-resistant grip',
      ),
      const GearItem(
        id: 'i_9',
        name: 'Gym Workout Gloves',
        category: 'Equipment',
        sport: 'Gym',
        note: 'Wrist support wrap',
      ),
      const GearItem(
        id: 'i_10',
        name: 'Resistance Bands Set',
        category: 'Equipment',
        sport: 'Gym',
        note: 'Light, medium and heavy bands',
      ),
    ];

    _kits = [
      const GearKit(
        id: 'k_running',
        name: 'Morning Run',
        sport: 'Running',
        itemIds: ['i_1', 'i_2', 'i_3', 'i_4', 'i_5'],
      ),
      const GearKit(
        id: 'k_swimming',
        name: 'Pool Session',
        sport: 'Swimming',
        itemIds: ['i_6', 'i_7', 'i_8', 'i_5'],
      ),
      const GearKit(
        id: 'k_gym',
        name: 'Gym Workout',
        sport: 'Gym',
        itemIds: ['i_9', 'i_10', 'i_7', 'i_5'],
      ),
    ];
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('g_items_data', jsonEncode(_items.map((e) => e.toJson()).toList()));
    await prefs.setString('g_kits_data', jsonEncode(_kits.map((e) => e.toJson()).toList()));
    await prefs.setString('g_active_kit_id', _activeKitId);

    final packedMap = <String, List<String>>{};
    _kitPackedItems.forEach((k, v) {
      packedMap[k] = v.toList();
    });
    await prefs.setString('g_packed_states', jsonEncode(packedMap));
  }

  // Gear Item Actions
  Future<void> addGearItem(GearItem item) async {
    _items.insert(0, item);
    await _save();
    notifyListeners();
  }

  Future<void> updateGearItem(GearItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      await _save();
      notifyListeners();
    }
  }

  List<String> getKitNamesContainingItem(String itemId) {
    return _kits.where((k) => k.itemIds.contains(itemId)).map((k) => k.name).toList();
  }

  Future<void> deleteGearItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    // Remove from all kits as well
    for (int i = 0; i < _kits.length; i++) {
      if (_kits[i].itemIds.contains(id)) {
        final updatedList = List<String>.from(_kits[i].itemIds)..remove(id);
        _kits[i] = _kits[i].copyWith(itemIds: updatedList);
      }
    }
    // Clean from packed state
    _kitPackedItems.forEach((_, set) {
      set.remove(id);
    });

    await _save();
    notifyListeners();
  }

  GearItem? getItemById(String id) {
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  // Kit Actions
  Future<void> addKit(GearKit kit) async {
    _kits.insert(0, kit);
    _activeKitId = kit.id;
    await _save();
    notifyListeners();
  }

  Future<void> updateKit(GearKit kit) async {
    final idx = _kits.indexWhere((k) => k.id == kit.id);
    if (idx != -1) {
      _kits[idx] = kit;
      await _save();
      notifyListeners();
    }
  }

  Future<void> deleteKit(String id) async {
    _kits.removeWhere((k) => k.id == id);
    _kitPackedItems.remove(id);
    if (_activeKitId == id) {
      _activeKitId = _kits.isNotEmpty ? _kits.first.id : '';
    }
    await _save();
    notifyListeners();
  }

  void setActiveKit(String kitId) {
    _activeKitId = kitId;
    _save();
    notifyListeners();
  }

  // Packing Actions
  void toggleItemPacked(String itemId) {
    if (_activeKitId.isEmpty) return;
    final set = _kitPackedItems.putIfAbsent(_activeKitId, () => <String>{});
    if (set.contains(itemId)) {
      set.remove(itemId);
    } else {
      set.add(itemId);
    }
    _save();
    notifyListeners();
  }

  void resetCurrentKitChecklist() {
    if (_activeKitId.isEmpty) return;
    _kitPackedItems[_activeKitId]?.clear();
    _save();
    notifyListeners();
  }
}
