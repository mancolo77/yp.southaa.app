import 'package:flutter/material.dart';
import '../../services/gear_organizer_service.dart';
import '../../theme/app_theme.dart';

class GearListTab extends StatefulWidget {
  const GearListTab({super.key});

  @override
  State<GearListTab> createState() => _GearListTabState();
}

class _GearListTabState extends State<GearListTab> {
  final GearOrganizerService _service = GearOrganizerService();
  String _selectedCategory = 'Все';
  String _searchQuery = '';
  final List<String> _categories = ['Все', 'Одежда', 'Обувь', 'Инвентарь', 'Аксессуары'];

  void _showAddEditDialog([GearItem? itemToEdit]) {
    final nameCtrl = TextEditingController(text: itemToEdit?.name ?? '');
    String cat = itemToEdit?.category ?? 'Одежда';
    final sportCtrl = TextEditingController(text: itemToEdit?.sport ?? 'Общий');
    final noteCtrl = TextEditingController(text: itemToEdit?.note ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.cardRadius)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppTheme.screenPadding,
                right: AppTheme.screenPadding,
                top: AppTheme.screenPadding,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.screenPadding,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      itemToEdit == null ? 'Новая вещь' : 'Редактировать вещь',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Название вещи *',
                        filled: true,
                        fillColor: AppTheme.surfaceSection,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Категория', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: ['Одежда', 'Обувь', 'Инвентарь', 'Аксессуары'].map((c) {
                        final isSel = cat == c;
                        return ChoiceChip(
                          label: Text(c),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setModalState(() => cat = c);
                          },
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceSection,
                          labelStyle: TextStyle(
                            color: isSel ? AppTheme.darkNavy : AppTheme.darkNavy,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                            side: BorderSide(color: isSel ? AppTheme.primary : AppTheme.border),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sportCtrl,
                      decoration: InputDecoration(
                        labelText: 'Вид спорта',
                        filled: true,
                        fillColor: AppTheme.surfaceSection,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: 'Заметка (необязательно)',
                        filled: true,
                        fillColor: AppTheme.surfaceSection,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: AppTheme.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          if (itemToEdit == null) {
                            _service.addGearItem(
                              name: name,
                              category: cat,
                              sport: sportCtrl.text.trim().isEmpty ? 'Спорт' : sportCtrl.text.trim(),
                              note: noteCtrl.text.trim(),
                            );
                          } else {
                            _service.updateGearItem(
                              itemToEdit.copyWith(
                                name: name,
                                category: cat,
                                sport: sportCtrl.text.trim().isEmpty ? 'Спорт' : sportCtrl.text.trim(),
                                note: noteCtrl.text.trim(),
                              ),
                            );
                          }
                          Navigator.of(ctx).pop();
                        },
                        child: Text(itemToEdit == null ? 'Добавить' : 'Сохранить'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(GearItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cardRadius)),
        title: const Text('Удалить вещь?', style: TextStyle(color: AppTheme.darkNavy, fontWeight: FontWeight.bold)),
        content: Text('«${item.name}» будет также удалена из всех наборов, где она используется.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              _service.deleteGearItem(item.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Одежда':
        return Icons.checkroom_rounded;
      case 'Обувь':
        return Icons.snowshoeing_rounded;
      case 'Инвентарь':
        return Icons.fitness_center_rounded;
      case 'Аксессуары':
        return Icons.backpack_rounded;
      default:
        return Icons.sports_score_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        final allGear = _service.gear;
        final filtered = allGear.where((item) {
          if (_selectedCategory != 'Все' && item.category != _selectedCategory) return false;
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            return item.name.toLowerCase().contains(q) ||
                item.sport.toLowerCase().contains(q) ||
                item.note.toLowerCase().contains(q);
          }
          return true;
        }).toList();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppTheme.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Мои вещи',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddEditDialog(),
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primary, size: 20),
                    label: const Text(
                      'Добавить',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Каталог спортивной экипировки и аксессуаров',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              // Search field
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSection,
                  borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: AppTheme.darkNavy, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Поиск по названию или спорту...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.primary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Category chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((c) {
                    final isSel = _selectedCategory == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: isSel,
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = c);
                        },
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceSection,
                        labelStyle: TextStyle(
                          color: isSel ? AppTheme.darkNavy : AppTheme.darkNavy,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                          side: BorderSide(color: isSel ? AppTheme.primary : AppTheme.border),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // List of gear items
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSection,
                    borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: const [
                      Icon(Icons.inventory_2_outlined, size: 48, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text('Вещи не найдены', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              else
                ...filtered.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceSection,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getCategoryIcon(item.category), color: AppTheme.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkNavy),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(item.category, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textAccent)),
                                  const SizedBox(width: 8),
                                  Text('•  ${item.sport}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                              if (item.note.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(item.note, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showAddEditDialog(item);
                            } else if (val == 'delete') {
                              _showDeleteConfirm(item);
                            }
                          },
                          itemBuilder: (ctx) => [
                            const PopupMenuItem(value: 'edit', child: Text('Редактировать')),
                            const PopupMenuItem(value: 'delete', child: Text('Удалить', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

