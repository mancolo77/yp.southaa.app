import 'package:flutter/material.dart';
import '../../services/gear_organizer_service.dart';
import '../../theme/app_theme.dart';

class PackingTab extends StatefulWidget {
  final VoidCallback onNavigateToKits;

  const PackingTab({super.key, required this.onNavigateToKits});

  @override
  State<PackingTab> createState() => _PackingTabState();
}

class _PackingTabState extends State<PackingTab> {
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

  void _confirmReset(GearKit kit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        title: const Text(
          'Сбросить отметки?',
          style: TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Все отметки о собранных вещах в наборе «${kit.title}» будут сняты.',
          style: const TextStyle(color: AppTheme.textSecondary),
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
              Navigator.pop(ctx);
              _service.resetPacked(kit.id);
            },
            child: const Text(
              'Сбросить',
              style: TextStyle(color: AppTheme.buttonTextDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Обувь':
        return Icons.hiking_rounded;
      case 'Одежда':
        return Icons.checkroom_rounded;
      case 'Инвентарь':
        return Icons.sports_tennis_rounded;
      case 'Аксессуары':
      default:
        return Icons.watch_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kits = _service.kits;
    final activeKit = _service.selectedKit;

    if (kits.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              const Text(
                'Нет доступных наборов',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: AppTheme.buttonTextDark,
                  minimumSize: const Size(160, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: widget.onNavigateToKits,
                child: const Text('Создать набор', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final kit = activeKit ?? kits.first;
    final totalItems = kit.itemIds.length;
    final packedCount = kit.packedItemIds.length;
    final progress = totalItems == 0 ? 0.0 : packedCount / totalItems;
    final isAllPacked = totalItems > 0 && packedCount == totalItems;

    // Resolve items
    final kitItems = _service.gear.where((g) => kit.itemIds.contains(g.id)).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Сборы',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Чек-лист подготовки экипировки',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (kitItems.isNotEmpty)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentOrangeText,
                        side: const BorderSide(color: AppTheme.accentOrange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: () => _confirmReset(kit),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Сбросить', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),

            // Kit Selector Dropdown / Chips
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kits.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final k = kits[index];
                  final isSelected = k.id == kit.id;
                  return InkWell(
                    onTap: () => _service.selectKit(k.id),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.navyDark : AppTheme.sectionBackground,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.navyDark : AppTheme.divider,
                        ),
                      ),
                      child: Text(
                        k.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : AppTheme.textDark,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Dark Blue Progress Banner (as required by prompt)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.navyDark,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navyDark.withAlpha(60),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          kit.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAllPacked
                                ? AppTheme.itemPacked
                                : AppTheme.accentOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAllPacked ? 'Готово к выходу!' : 'Собрано $packedCount из $totalItems',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAllPacked ? Colors.white : AppTheme.buttonTextDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white.withAlpha(40),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isAllPacked ? AppTheme.itemPacked : AppTheme.accentOrange,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          totalItems == 0
                              ? 'В наборе пока нет вещей'
                              : '${(progress * 100).toInt()}% укомплектовано',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        Text(
                          isAllPacked ? 'Все вещи с собой' : 'Осталось: ${totalItems - packedCount}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Checklist
            Expanded(
              child: totalItems == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_outlined, size: 56, color: AppTheme.textSecondary.withAlpha(120)),
                          const SizedBox(height: 10),
                          const Text(
                            'Набор пуст',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Добавьте вещи в этот набор во вкладке «Наборы»',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange,
                              foregroundColor: AppTheme.buttonTextDark,
                              minimumSize: const Size(180, AppTheme.buttonHeight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.buttonRadius)),
                            ),
                            onPressed: widget.onNavigateToKits,
                            child: const Text('Редактировать набор', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      itemCount: kitItems.length,
                      itemBuilder: (context, index) {
                        final item = kitItems[index];
                        final isPacked = kit.packedItemIds.contains(item.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isPacked ? AppTheme.itemPacked.withAlpha(12) : AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            border: Border.all(
                              color: isPacked ? AppTheme.itemPacked : AppTheme.divider,
                              width: isPacked ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(6),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () => _service.togglePacked(kit.id, item.id),
                            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isPacked ? AppTheme.itemPacked : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isPacked ? AppTheme.itemPacked : AppTheme.divider,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isPacked
                                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.sectionBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _iconForCategory(item.category),
                                      size: 20,
                                      color: isPacked ? AppTheme.itemPacked : AppTheme.navyDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isPacked ? AppTheme.itemPacked : AppTheme.textDark,
                                            decoration: isPacked ? TextDecoration.lineThrough : null,
                                            decorationColor: AppTheme.itemPacked,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.category} • ${item.sport}${item.note.isNotEmpty ? ' • ${item.note}' : ''}',
                                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isPacked ? AppTheme.itemPacked.withAlpha(25) : AppTheme.sectionBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isPacked ? 'Собрано' : 'Не готово',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isPacked ? AppTheme.itemPacked : AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
