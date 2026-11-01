import 'package:flutter/material.dart';
import '../../models/gear_models.dart';
import '../../services/gear_storage_service.dart';
import '../../theme/app_theme.dart';

class PackTab extends StatefulWidget {
  final VoidCallback? onSwitchToKits;

  const PackTab({super.key, this.onSwitchToKits});

  @override
  State<PackTab> createState() => _PackTabState();
}

class _PackTabState extends State<PackTab> {
  final GearStorageService _storage = GearStorageService();

  @override
  void initState() {
    super.initState();
    _storage.addListener(_onStorageUpdate);
  }

  @override
  void dispose() {
    _storage.removeListener(_onStorageUpdate);
    super.dispose();
  }

  void _onStorageUpdate() {
    if (mounted) setState(() {});
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Footwear':
        return Icons.hiking_rounded;
      case 'Equipment':
        return Icons.sports_tennis_rounded;
      case 'Accessories':
        return Icons.watch_later_outlined;
      case 'Apparel':
      default:
        return Icons.checkroom_rounded;
    }
  }

  void _confirmReset(GearKit kit) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        ),
        title: const Text(
          'Reset Checklist?',
          style: TextStyle(
            color: AppTheme.darkNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Text(
          'Are you sure you want to uncheck all items for "${kit.name}"?',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 15,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.orangeAccent,
              foregroundColor: AppTheme.darkNavy,
              minimumSize: const Size(90, 42),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _storage.resetCurrentKitChecklist();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checklist reset successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kits = _storage.kits;
    final activeKit = _storage.activeKit;

    if (kits.isEmpty || activeKit == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Pack Checklist',
            style: TextStyle(
              color: AppTheme.darkNavy,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.backpack_outlined,
                  size: 64,
                  color: AppTheme.decorStripes,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Kits Available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkNavy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an activity kit first to start packing your sports equipment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.onSwitchToKits != null)
                  ElevatedButton.icon(
                    onPressed: widget.onSwitchToKits,
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Go to Activity Kits'),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final packedIds = _storage.packedItemIds;
    final kitItemIds = activeKit.itemIds;
    final totalItems = kitItemIds.length;
    final packedCount = kitItemIds.where((id) => packedIds.contains(id)).length;
    final progress = totalItems > 0 ? (packedCount / totalItems) : 0.0;
    final isFullyPacked = totalItems > 0 && packedCount == totalItems;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Pack Checklist',
          style: TextStyle(
            color: AppTheme.darkNavy,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Kit Selector horizontal chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.screenPadding,
                right: AppTheme.screenPadding,
                top: 4,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Activity Kit',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: kits.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final kit = kits[index];
                        final isSelected = kit.id == activeKit.id;
                        return ChoiceChip(
                          label: Text(kit.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              _storage.setActiveKit(kit.id);
                            }
                          },
                          backgroundColor: AppTheme.sectionBg,
                          selectedColor: AppTheme.orangeAccent,
                          labelStyle: TextStyle(
                            color: isSelected ? AppTheme.darkNavy : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.orangeAccent : AppTheme.border,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dark Navy Status Card with Diagonal Stripe Decor & Progress
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.screenPadding,
                vertical: 6,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.darkNavy,
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  child: Stack(
                    children: [
                      // Subtle diagonal stripes accent
                      Positioned(
                        right: -20,
                        top: -20,
                        width: 140,
                        height: 140,
                        child: Opacity(
                          opacity: 0.12,
                          child: CustomPaint(
                            painter: GearDiagonalPainter(
                              stripeColor: Colors.white,
                              stripeWidth: 6,
                              gap: 12,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.secondaryBlue,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          activeKit.sport.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        activeKit.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isFullyPacked
                                        ? AppTheme.statusCompleted.withAlpha(200)
                                        : Colors.white.withAlpha(25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isFullyPacked
                                            ? Icons.check_circle_rounded
                                            : Icons.backpack_outlined,
                                        color: isFullyPacked
                                            ? Colors.white
                                            : AppTheme.orangeAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${(progress * 100).toInt()}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.white.withAlpha(40),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.orangeAccent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Packed $packedCount of $totalItems',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (isFullyPacked)
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: Color(0xFF81C784),
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Ready to Go',
                                        style: TextStyle(
                                          color: Color(0xFF81C784),
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    '${totalItems - packedCount} items remaining',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Reset checklist action button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.screenPadding,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: packedCount > 0 ? () => _confirmReset(activeKit) : null,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Start Over'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.darkNavy,
                        disabledForegroundColor: AppTheme.decorStripes,
                        side: BorderSide(
                          color: packedCount > 0 ? AppTheme.border : AppTheme.border.withAlpha(80),
                        ),
                        minimumSize: const Size(0, AppTheme.buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Items list or empty state
          if (kitItemIds.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.screenPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 56,
                        color: AppTheme.decorStripes,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Items in this Kit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Edit this kit in the Kits tab to add gear from your inventory.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (widget.onSwitchToKits != null)
                        ElevatedButton.icon(
                          onPressed: widget.onSwitchToKits,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit Kit Items'),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.screenPadding,
                4,
                AppTheme.screenPadding,
                32,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final itemId = kitItemIds[index];
                    final item = _storage.getItemById(itemId);
                    final isPacked = packedIds.contains(itemId);

                    if (item == null) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isPacked ? AppTheme.sectionBg : AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                        border: Border.all(
                          color: isPacked
                              ? AppTheme.statusCompleted.withAlpha(60)
                              : AppTheme.border,
                          width: 1.2,
                        ),
                        boxShadow: isPacked ? null : AppTheme.cardShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                          onTap: () {
                            _storage.toggleItemPacked(item.id);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Checkbox circle
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isPacked
                                        ? AppTheme.statusCompleted
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isPacked
                                          ? AppTheme.statusCompleted
                                          : AppTheme.decorStripes,
                                      width: 2,
                                    ),
                                  ),
                                  child: isPacked
                                      ? const Icon(
                                          Icons.check,
                                          size: 20,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                // Category Icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isPacked
                                        ? AppTheme.border.withAlpha(100)
                                        : AppTheme.sectionBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _categoryIcon(item.category),
                                    color: isPacked
                                        ? AppTheme.textSecondary
                                        : AppTheme.darkNavy,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Title and tags
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isPacked
                                              ? AppTheme.textSecondary
                                              : AppTheme.darkNavy,
                                          decoration: isPacked
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                          decorationColor: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.sectionBg,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.category,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.sectionBg,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              item.sport,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (item.note.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          item.note,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: isPacked
                                                ? AppTheme.decorStripes
                                                : AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Text Status badge ("Packed" or "Pending")
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPacked
                                        ? AppTheme.statusCompleted.withAlpha(25)
                                        : AppTheme.sectionBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isPacked
                                          ? AppTheme.statusCompleted.withAlpha(120)
                                          : AppTheme.border,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isPacked) ...[
                                        const Icon(
                                          Icons.check,
                                          size: 13,
                                          color: AppTheme.statusCompleted,
                                        ),
                                        const SizedBox(width: 3),
                                      ],
                                      Text(
                                        isPacked ? 'Packed' : 'Pending',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isPacked
                                              ? AppTheme.statusCompleted
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: kitItemIds.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
