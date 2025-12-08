import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

/// 메인 스캐폴드 (바텀 네비게이션 포함)
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();

    return NavigationBar(
      selectedIndex: _calculateSelectedIndex(currentLocation),
      onDestinationSelected: (index) {
        _onItemTapped(context, index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '홈',
        ),
        NavigationDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate),
          label: '소득세',
        ),
        NavigationDestination(
          icon: Icon(Icons.home_work_outlined),
          selectedIcon: Icon(Icons.home_work),
          label: '양도세',
        ),
        NavigationDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: '기록',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: '설정',
        ),
      ],
    );
  }

  int _calculateSelectedIndex(String location) {
    if (location == AppRoutes.home) return 0;
    if (location == AppRoutes.incomeTax) return 1;
    if (location == AppRoutes.capitalGainsTax) return 2;
    if (location == AppRoutes.history) return 3;
    if (location == AppRoutes.settings) return 4;

    // 기타 세금 관련 페이지는 홈으로
    if (location.contains('tax')) return 0;

    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.incomeTax);
        break;
      case 2:
        context.go(AppRoutes.capitalGainsTax);
        break;
      case 3:
        context.go(AppRoutes.history);
        break;
      case 4:
        context.go(AppRoutes.settings);
        break;
    }
  }
}
