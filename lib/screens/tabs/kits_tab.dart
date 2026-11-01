import 'package:flutter/material.dart';
import '../../services/gear_organizer_service.dart';
import '../../theme/app_theme.dart';

class KitsTab extends StatefulWidget {
  final VoidCallback onNavigateToPacking;

  const KitsTab({super.key, required this.onNavigateToPacking});

  @override
  State<KitsTab> createState() => _KitsTabState();
}

class _KitsTabState extends State<KitsTab> {
  final _service = GearOrganizerService();

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

  void _showAddKitDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        title: const Text(
          'Новый набор',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Название набора (напр. Йога)',
            hintStyle: const TextStyle(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.sectionBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                _service.addKit(title);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Создать', style: TextStyle(color: AppTheme.buttonTextDark, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditKitItemsSheet(GearKit kit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final allGear = _service.gear;
          final kitCurrent = _service.kits.firstWhere((k) => k.id == kit.id, orElse: () => kit);

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Вещи для набора: ${kitCurrent.title}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Выбрано: ${kitCurrent.itemIds.length} из ${allGear.length}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 12),
                if (allGear.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Сначала добавьте вещи во вкладке «Мои вещи»',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: allGear.length,
                      separatorBuilder: (_, _) => const Divider(height: 1, color: AppTheme.divider),
                      itemBuilder: (context, idx) {
                        final item = allGear[idx];
                        final isIncluded = kitCurrent.itemIds.contains(item.id);

                        return CheckboxListTile(
                          activeColor: AppTheme.accentOrange,
                          checkColor: AppTheme.buttonTextDark,
                          value: isIncluded,
                          title: Text(
                            item.name,
                            style: TextStyle(
                              color: AppTheme.textDark,
                              fontWeight: isIncluded ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${item.category} • ${item.sport}',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          onChanged: (_) {
                            _service.toggleItemInKit(kitCurrent.id, item.id);
                            setSheetState(() {});
                          },
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: AppTheme.buttonHeight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Готово',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.buttonTextDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kits = _service.kits;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Наборы',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Комплекты экипировки для тренировок',
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentOrange,
                      foregroundColor: AppTheme.buttonTextDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: _showAddKitDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(
                      'Создать',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: kits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 64, color: AppTheme.textSecondary.withAlpha(120)),
                          const SizedBox(height: 12),
                          const Text(
                            'Нет созданных наборов',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Создайте набор для бассейна или пробежки',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: kits.length,
                      itemBuilder: (context, index) {
                        final kit = kits[index];
                        final itemsCount = kit.itemIds.length;
                        final packedCount = kit.packedItemIds.length;
                        final isSelected = _service.selectedKitId == kit.id;

                        // resolve actual items
                        final kitItems = _service.gear.where((g) => kit.itemIds.contains(g.id)).toList();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentOrange : AppTheme.divider,
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(8),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.navyDark.withAlpha(15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.backpack_outlined,
                                        color: AppTheme.navyDark,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kit.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            itemsCount == 0
                                                ? 'Вещи не добавлены'
                                                : '$itemsCount вещей • Собрано $packedCount',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: itemsCount == 0 ? AppTheme.accentOrangeText : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditKitItemsSheet(kit);
                                        } else if (value == 'delete') {
                                          _service.deleteKit(kit.id);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.checklist_rounded, size: 20, color: AppTheme.navyDark),
                                              SizedBox(width: 8),
                                              Text('Выбрать вещи'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Удалить набор'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (kitItems.isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: kitItems.take(5).map((item) {
                                      final isPacked = kit.packedItemIds.contains(item.id);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPacked ? AppTheme.itemPacked.withAlpha(20) : AppTheme.sectionBackground,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isPacked ? AppTheme.itemPacked : AppTheme.divider,
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isPacked) ...[
                                              const Icon(Icons.check, size: 12, color: AppTheme.itemPacked),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              item.name,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isPacked ? AppTheme.itemPacked : AppTheme.textDark,
                                                fontWeight: isPacked ? FontWeight.w600 : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList()
                                      ..addAll([
                                        if (kitItems.length > 5)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppTheme.sectionBackground,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '+${kitItems.length - 5}',
                                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                            ),
                                          ),
                                      ]),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.sectionBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Добавьте вещи в этот набор',
                                      style: TextStyle(fontSize: 12, color: AppTheme.accentOrangeText),
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.navyDark,
                                          side: const BorderSide(color: AppTheme.divider),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          minimumSize: const Size(0, 44),
                                        ),
                                        onPressed: () => _showEditKitItemsSheet(kit),
                                        child: const Text('Состав набора'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.accentOrange,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          minimumSize: const Size(0, 44),
                                          elevation: 0,
                                        ),
                                        onPressed: () {
                                          _service.selectKit(kit.id);
                                          widget.onNavigateToPacking();
                                        },
                                        child: const Text(
                                          'Собрать',
                                          style: TextStyle(
                                            color: AppTheme.buttonTextDark,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
