import 'package:intl/intl.dart';

/// 숫자 포맷팅 유틸리티
class NumberFormatter {
  NumberFormatter._();

  static final _currencyFormat = NumberFormat('#,###', 'ko_KR');
  static final _percentFormat = NumberFormat('0.##', 'ko_KR');
  static final _decimalFormat = NumberFormat('#,###.##', 'ko_KR');

  /// 통화 형식으로 포맷 (예: 1,234,567)
  static String formatCurrency(double value) {
    return _currencyFormat.format(value.round());
  }

  /// 통화 형식 + 원 단위 (예: 1,234,567원)
  static String formatCurrencyWithUnit(double value) {
    return '${formatCurrency(value)}원';
  }

  /// 만원 단위로 포맷 (예: 123.4만원)
  static String formatInTenThousand(double value) {
    final inTenThousand = value / 10000;
    if (inTenThousand >= 10000) {
      // 1억 이상이면 억 단위로
      return formatInHundredMillion(value);
    }
    return '${_decimalFormat.format(inTenThousand)}만원';
  }

  /// 억원 단위로 포맷 (예: 1.23억원)
  static String formatInHundredMillion(double value) {
    final inHundredMillion = value / 100000000;
    return '${_decimalFormat.format(inHundredMillion)}억원';
  }

  /// 자동 단위 선택 포맷
  static String formatAutoUnit(double value) {
    if (value.abs() >= 100000000) {
      return formatInHundredMillion(value);
    } else if (value.abs() >= 10000) {
      return formatInTenThousand(value);
    } else {
      return formatCurrencyWithUnit(value);
    }
  }

  /// 퍼센트 형식으로 포맷 (예: 15.5%)
  static String formatPercent(double value) {
    return '${_percentFormat.format(value * 100)}%';
  }

  /// 퍼센트 값 그대로 포맷 (예: 15.5%)
  static String formatPercentValue(double value) {
    return '${_percentFormat.format(value)}%';
  }

  /// 소수점 포함 포맷 (예: 1,234.56)
  static String formatDecimal(double value) {
    return _decimalFormat.format(value);
  }

  /// 문자열을 숫자로 변환 (콤마 제거)
  static double? parseNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^\d.-]'), '');
    return double.tryParse(cleaned);
  }

  /// 입력값 포맷팅 (실시간 입력용)
  static String formatInput(String value) {
    final number = parseNumber(value);
    if (number == null) return '';
    return formatCurrency(number);
  }

  /// 세율 표시 형식 (예: 6% ~ 45%)
  static String formatTaxRateRange(double minRate, double maxRate) {
    return '${formatPercentValue(minRate * 100)} ~ ${formatPercentValue(maxRate * 100)}';
  }

  /// 금액 범위 표시 (예: 1,400만원 ~ 5,000만원)
  static String formatAmountRange(double minAmount, double maxAmount) {
    return '${formatInTenThousand(minAmount)} ~ ${formatInTenThousand(maxAmount)}';
  }

  /// 연수 표시 (예: 5년)
  static String formatYears(int years) {
    return '$years년';
  }

  /// 개월 표시 (예: 36개월)
  static String formatMonths(int months) {
    return '$months개월';
  }

  /// 연월 변환 표시 (예: 3년 6개월)
  static String formatYearsAndMonths(int totalMonths) {
    final years = totalMonths ~/ 12;
    final months = totalMonths % 12;

    if (years == 0) {
      return '$months개월';
    } else if (months == 0) {
      return '$years년';
    } else {
      return '$years년 $months개월';
    }
  }
}

/// 숫자 확장 메서드
extension NumberFormatExtension on num {
  /// 통화 형식으로 변환
  String get toCurrency => NumberFormatter.formatCurrency(toDouble());

  /// 통화 + 원 단위
  String get toCurrencyWithUnit =>
      NumberFormatter.formatCurrencyWithUnit(toDouble());

  /// 자동 단위 선택
  String get toAutoUnit => NumberFormatter.formatAutoUnit(toDouble());

  /// 퍼센트 형식 (0.15 -> 15%)
  String get toPercent => NumberFormatter.formatPercent(toDouble());

  /// 퍼센트 값 형식 (15 -> 15%)
  String get toPercentValue => NumberFormatter.formatPercentValue(toDouble());
}
