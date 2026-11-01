import 'package:flutter/material.dart';
import '../../models/gear_models.dart';
import '../../services/gear_storage_service.dart';
import '../../theme/app_theme.dart';

class KitsTab extends StatefulWidget {
  final void Function(int tabIndex)? onNavigateTab;

  const KitsTab({super.key, this.onNavigateTab});

  @override
  State<KitsTab> createState() => _KitsTabState();
}

class _KitsTabState extends State<KitsTab> {
  final _service = GearStorageService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _confirmDeleteKit(GearKit kit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text(
          'Delete Kit?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
        ),
        content: Text(
          'Are you sure you want to remove "${kit.name}"?',
          style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              _service.deleteKit(kit.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddEditKitSheet([GearKit? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final sportCtrl = TextEditingController(text: existing?.sport ?? 'Running');
    final selectedItemIds = Set<String>.from(existing?.itemIds ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isEditing ? 'Edit Kit' : 'Create New Kit',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
                const SizedBox(height: 16),

                // Name Input
                const Text(
                  'Kit Name',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Marathon Race Day, Swim Training...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.sectionBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Sport Input
                const Text(
                  'Sport / Activity',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: sportCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Running, Swimming, Gym, Tennis',
                    hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.sectionBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      borderSide: const BorderSide(color: AppTheme.border),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Multi-select Items from Inventory
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Include Equipment',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                    ),
                    Text(
                      '${selectedItemIds.length} selected',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.orangeAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_service.items.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.sectionBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No items in inventory. Add items in "My Gear" first.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  )
                else
                  Container(
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: AppTheme.sectionBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      itemCount: _service.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.border),
                      itemBuilder: (context, idx) {
                        final item = _service.items[idx];
                        final isIncluded = selectedItemIds.contains(item.id);

                        return CheckboxListTile(
                          value: isIncluded,
                          activeColor: AppTheme.orangeAccent,
                          checkColor: AppTheme.darkNavy,
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                          subtitle: Text(
                            '${item.category} • ${item.sport}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                          onChanged: (val) {
                            setSheetState(() {
                              if (val == true) {
                                selectedItemIds.add(item.id);
                              } else {
                                selectedItemIds.remove(item.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),

                // Save Kit Button
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;

                      if (isEditing) {
                        await _service.updateKit(
                          existing.copyWith(
                            name: name,
                            sport: sportCtrl.text.trim().isEmpty ? 'General' : sportCtrl.text.trim(),
                            itemIds: selectedItemIds.toList(),
                          ),
                        );
                      } else {
                        await _service.addKit(
                          GearKit(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            sport: sportCtrl.text.trim().isEmpty ? 'General' : sportCtrl.text.trim(),
                            itemIds: selectedItemIds.toList(),
                          ),
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      foregroundColor: AppTheme.darkNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Create Kit',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Kits',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkNavy,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pre-assembled checklists for your sports sessions',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditKitSheet(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.orangeAccent,
                      foregroundColor: AppTheme.darkNavy,
                      elevation: 0,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'New Kit',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Kits List
            Expanded(
              child: _service.kits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.backpack_outlined, size: 54, color: AppTheme.textSecondary.withAlpha(90)),
                          const SizedBox(height: 12),
                          const Text(
                            'No kits created yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "New Kit" to create a workout checklist.',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _service.kits.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final kit = _service.kits[index];
                        final itemsInKit = kit.itemIds
                            .map((id) => _service.getItemById(id))
                            .whereType<GearItem>()
                            .toList();

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: AppTheme.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.sectionBg,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      kit.sport.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textAccent,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    color: AppTheme.textSecondary,
                                    onPressed: () => _showAddEditKitSheet(kit),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                                    color: Colors.red.shade600,
                                    onPressed: () => _confirmDeleteKit(kit),
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                kit.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.darkNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${itemsInKit.length} items configured',
                                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 12),

                              // Items Pills Preview
                              if (itemsInKit.isEmpty)
                                const Text(
                                  'No equipment assigned. Edit kit to select items.',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                )
                              else
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: itemsInKit.map((item) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.sectionBg,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.border),
                                      ),
                                      child: Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.darkNavy,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 14),

                              // Pack this Kit Action Button (Height >= 48)
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _service.setActiveKit(kit.id);
                                    widget.onNavigateTab?.call(2); // Jump to Pack Tab
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.sectionBg,
                                    foregroundColor: AppTheme.darkNavy,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                                      side: const BorderSide(color: AppTheme.border),
                                    ),
                                  ),
                                  icon: const Icon(Icons.checklist_rounded, size: 18, color: AppTheme.orangeAccent),
                                  label: const Text(
                                    'Pack this Kit →',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
