import 'package:flutter/material.dart';

class BottomNavigationItem {
  final String label;
  final IconData icon;
  final IconData? activeIcon;

  const BottomNavigationItem({
    required this.label,
    required this.icon,
    this.activeIcon,
  });
}

/// Reusable bottom navigation. The parent owns navigation state and actions.
class BottomNavigationComponent extends StatelessWidget {
  final List<BottomNavigationItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool showLabels;

  const BottomNavigationComponent({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final safeIndex = currentIndex.clamp(0, items.length - 1);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: onTap,
        labelBehavior: showLabels
            ? NavigationDestinationLabelBehavior.alwaysShow
            : NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          for (final item in items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            ),
        ],
      ),
    );
  }
}
