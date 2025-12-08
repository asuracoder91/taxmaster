import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'app.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 시스템 UI 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 화면 방향 설정 (세로 모드만)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive 초기화
  await Hive.initFlutter();

  // Hive 어댑터 등록 (추후 모델 클래스 추가 시)
  // Hive.registerAdapter(CalculationHistoryAdapter());
  // Hive.registerAdapter(SettingsAdapter());

  // Hive 박스 열기
  // await Hive.openBox<CalculationHistory>('calculation_history');
  // await Hive.openBox('settings');

  // 앱 실행
  runApp(const TaxMasterApp());
}
