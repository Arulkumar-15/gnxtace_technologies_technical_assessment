import 'package:flutter/material.dart';

/// Floating Android tab bar matching a pill + circle layout:
/// dark capsule with three destinations, white circular accent for the fourth.
class AndroidFloatingTabBar extends StatelessWidget {
  const AndroidFloatingTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _pillColor = Color(0xFF2A2A2A);
  static const _iconIdle = Color(0xFFBDBDBD);
  static const _iconActive = Colors.white;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottom + 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _pillColor,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _PillTab(
                      icon: Icons.grid_view_outlined,
                      selectedIcon: Icons.grid_view_rounded,
                      selected: currentIndex == 0,
                      onTap: () => onTap(0),
                      tooltip: 'Explore',
                    ),
                    _PillTab(
                      icon: Icons.search_outlined,
                      selectedIcon: Icons.search_rounded,
                      selected: currentIndex == 1,
                      onTap: () => onTap(1),
                      tooltip: 'Search',
                    ),
                    _PillTab(
                      icon: Icons.favorite_border_rounded,
                      selectedIcon: Icons.favorite_rounded,
                      selected: currentIndex == 2,
                      onTap: () => onTap(2),
                      tooltip: 'Favorites',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _CircleTab(
            icon: Icons.person_rounded,
            selected: currentIndex == 3,
            onTap: () => onTap(3),
            tooltip: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
          ),
          child: Icon(
            selected ? selectedIcon : icon,
            size: 24,
            color: selected
                ? AndroidFloatingTabBar._iconActive
                : AndroidFloatingTabBar._iconIdle,
          ),
        ),
      ),
    );
  }
}

class _CircleTab extends StatelessWidget {
  const _CircleTab({
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
              border: selected
                  ? Border.all(color: const Color(0xFF1B5E4A), width: 2.5)
                  : null,
            ),
            child: Icon(
              icon,
              size: 26,
              color: selected ? const Color(0xFF1B5E4A) : const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}
