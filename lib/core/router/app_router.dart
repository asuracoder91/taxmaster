import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/income_tax/presentation/screens/income_tax_screen.dart';
import '../../features/corporate_tax/presentation/screens/corporate_tax_screen.dart';
import '../../features/capital_gains_tax/presentation/screens/capital_gains_tax_screen.dart';
import '../../features/inheritance_tax/presentation/screens/inheritance_tax_screen.dart';
import '../../features/gift_tax/presentation/screens/gift_tax_screen.dart';
import '../../features/retirement_income/presentation/screens/retirement_income_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// 라우트 경로 상수
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String incomeTax = '/income-tax';
  static const String corporateTax = '/corporate-tax';
  static const String capitalGainsTax = '/capital-gains-tax';
  static const String inheritanceTax = '/inheritance-tax';
  static const String giftTax = '/gift-tax';
  static const String retirementIncome = '/retirement-income';
  static const String history = '/history';
  static const String settings = '/settings';
}

/// 앱 라우터 설정
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: true,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HomeScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.incomeTax,
            name: 'incomeTax',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: IncomeTaxScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.corporateTax,
            name: 'corporateTax',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: CorporateTaxScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.capitalGainsTax,
            name: 'capitalGainsTax',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: CapitalGainsTaxScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.inheritanceTax,
            name: 'inheritanceTax',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: InheritanceTaxScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.giftTax,
            name: 'giftTax',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: GiftTaxScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.retirementIncome,
            name: 'retirementIncome',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: RetirementIncomeScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.history,
            name: 'history',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HistoryScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: 'settings',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: SettingsScreen(),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text('페이지를 찾을 수 없습니다: ${state.uri}'),
        ),
      );
    },
  );
}

/// 홈 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Master'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '세금 계산기',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '계산하실 세금 유형을 선택해주세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _TaxTypeCard(
                      title: '종합소득세',
                      icon: Icons.account_balance_wallet,
                      color: const Color(0xFF1565C0),
                      onTap: () => context.go(AppRoutes.incomeTax),
                    ),
                    _TaxTypeCard(
                      title: '법인세',
                      icon: Icons.business,
                      color: const Color(0xFF7B1FA2),
                      onTap: () => context.go(AppRoutes.corporateTax),
                    ),
                    _TaxTypeCard(
                      title: '양도소득세',
                      icon: Icons.home_work,
                      color: const Color(0xFF00796B),
                      onTap: () => context.go(AppRoutes.capitalGainsTax),
                    ),
                    _TaxTypeCard(
                      title: '상속세',
                      icon: Icons.family_restroom,
                      color: const Color(0xFFC62828),
                      onTap: () => context.go(AppRoutes.inheritanceTax),
                    ),
                    _TaxTypeCard(
                      title: '증여세',
                      icon: Icons.card_giftcard,
                      color: const Color(0xFFEF6C00),
                      onTap: () => context.go(AppRoutes.giftTax),
                    ),
                    _TaxTypeCard(
                      title: '퇴직소득세',
                      icon: Icons.elderly,
                      color: const Color(0xFF558B2F),
                      onTap: () => context.go(AppRoutes.retirementIncome),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TaxTypeCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
