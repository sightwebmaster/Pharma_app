import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class PharmaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PharmaNavItem> items;

  const PharmaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final active = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Pill indicator wrapping the icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        width: active ? 48 : 40,
                        height: 28,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.greenSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          active ? item.activeIcon : item.icon,
                          size: 21,
                          color:
                              active ? AppColors.primaryGreen : AppColors.textFaint,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.w500,
                          color: active
                              ? AppColors.primaryGreen
                              : AppColors.textFaint,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class PharmaNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;

  const PharmaNavItem({
    required this.icon,
    required this.label,
    IconData? activeIcon,
  }) : activeIcon = activeIcon ?? icon;
}
