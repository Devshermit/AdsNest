import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../widgets/app_logo.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        // --- Tablet Layout: Side Navigation Rail ---
        if (isTablet) {
          return Scaffold(
            body: Row(
              children: [
                _buildNavigationRail(context),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: AppColors.borderGrey,
                ),
                Expanded(child: navigationShell),
              ],
            ),
          );
        }

        // --- Mobile Layout: Bottom Navigation Bar ---
        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: _buildBottomNavBar(),
        );
      },
    );
  }

  // เมนู Navigation ด้านข้างสำหรับ Tablet
  Widget _buildNavigationRail(BuildContext context) {
    final isExpanded = MediaQuery.of(context).size.width >= 900;

    return Container(
      color: AppColors.backgroundDark,
      child: SafeArea(
        child: NavigationRail(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          backgroundColor: AppColors.backgroundDark,
          indicatorColor: AppColors.primaryRed.withValues(alpha: 0.15),
          extended: isExpanded,
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: isExpanded
                ? const AppLogo(fontSize: 22, iconSize: 26)
                : const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFFFD700), // สายฟ้าสีทองแบบย่อเมื่อปิดแถบ
                    size: 28,
                  ),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.grid_view_rounded, color: AppColors.textGrey),
              selectedIcon: Icon(
                Icons.grid_view_rounded,
                color: AppColors.primaryRed,
              ),
              label: Text(
                'Dashboard',
                style: TextStyle(color: AppColors.textWhite),
              ),
            ),
            NavigationRailDestination(
              icon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.textGrey,
              ),
              selectedIcon: Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryRed,
              ),
              label: Text('Chat', style: TextStyle(color: AppColors.textWhite)),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.link_rounded, color: AppColors.textGrey),
              selectedIcon: Icon(
                Icons.link_rounded,
                color: AppColors.primaryRed,
              ),
              label: Text(
                'Affiliate',
                style: TextStyle(color: AppColors.textWhite),
              ),
            ),
            NavigationRailDestination(
              icon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textGrey,
              ),
              selectedIcon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.primaryRed,
              ),
              label: Text(
                'Profile',
                style: TextStyle(color: AppColors.textWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // เมนู Navigation ด้านล่างสำหรับ Mobile
  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: AppColors.borderGrey, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavItem(0, Icons.grid_view_rounded, 'Dashboard'),
            _buildBottomNavItem(1, Icons.chat_bubble_outline_rounded, 'Chat'),
            _buildBottomNavItem(2, Icons.link_rounded, 'Affiliate'),
            _buildBottomNavItem(3, Icons.person_outline_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(int index, IconData icon, String label) {
    final isSelected = navigationShell.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryRed.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryRed : AppColors.textGrey,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
