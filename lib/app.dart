import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// 앱의 루트 위젯
class TaxMasterApp extends StatelessWidget {
  const TaxMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tax Master',
      debugShowCheckedModeBanner: false,

      // 테마 설정
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 라우터 설정
      routerConfig: appRouter,

      // 한국어 로케일 설정
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
    );
  }
}
