/// 세금 구간 정보
class TaxBracket {
  final double threshold;
  final double rate;
  final double deduction;

  const TaxBracket({
    required this.threshold,
    required this.rate,
    required this.deduction,
  });
}

/// 종합소득세 세율표 (2025년 기준)
class IncomeTaxRates {
  static const List<TaxBracket> brackets = [
    TaxBracket(threshold: 14000000, rate: 0.06, deduction: 0),
    TaxBracket(threshold: 50000000, rate: 0.15, deduction: 1260000),
    TaxBracket(threshold: 88000000, rate: 0.24, deduction: 5760000),
    TaxBracket(threshold: 150000000, rate: 0.35, deduction: 15440000),
    TaxBracket(threshold: 300000000, rate: 0.38, deduction: 19940000),
    TaxBracket(threshold: 500000000, rate: 0.40, deduction: 25940000),
    TaxBracket(threshold: 1000000000, rate: 0.42, deduction: 35940000),
    TaxBracket(threshold: double.infinity, rate: 0.45, deduction: 65940000),
  ];

  /// 과세표준에 대한 소득세 계산
  static double calculate(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return taxableIncome * bracket.rate - bracket.deduction;
      }
    }

    // 최고 구간
    final lastBracket = brackets.last;
    return taxableIncome * lastBracket.rate - lastBracket.deduction;
  }

  /// 세율 구간 정보 반환
  static TaxBracket getBracket(double taxableIncome) {
    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return bracket;
      }
    }
    return brackets.last;
  }
}

/// 법인세 세율표 (2025년 기준)
class CorporateTaxRates {
  static const List<TaxBracket> brackets = [
    TaxBracket(threshold: 200000000, rate: 0.09, deduction: 0),
    TaxBracket(threshold: 20000000000, rate: 0.19, deduction: 20000000),
    TaxBracket(threshold: 300000000000, rate: 0.21, deduction: 420000000),
    TaxBracket(threshold: double.infinity, rate: 0.24, deduction: 9420000000),
  ];

  /// 과세표준에 대한 법인세 계산
  static double calculate(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return taxableIncome * bracket.rate - bracket.deduction;
      }
    }

    final lastBracket = brackets.last;
    return taxableIncome * lastBracket.rate - lastBracket.deduction;
  }

  /// 세율 구간 정보 반환
  static TaxBracket getBracket(double taxableIncome) {
    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return bracket;
      }
    }
    return brackets.last;
  }
}

/// 상속세/증여세 세율표 (2025년 기준)
class InheritanceGiftTaxRates {
  static const List<TaxBracket> brackets = [
    TaxBracket(threshold: 100000000, rate: 0.10, deduction: 0),
    TaxBracket(threshold: 500000000, rate: 0.20, deduction: 10000000),
    TaxBracket(threshold: 1000000000, rate: 0.30, deduction: 60000000),
    TaxBracket(threshold: 3000000000, rate: 0.40, deduction: 160000000),
    TaxBracket(threshold: double.infinity, rate: 0.50, deduction: 460000000),
  ];

  /// 과세표준에 대한 상속세/증여세 계산
  static double calculate(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return taxableIncome * bracket.rate - bracket.deduction;
      }
    }

    final lastBracket = brackets.last;
    return taxableIncome * lastBracket.rate - lastBracket.deduction;
  }

  /// 세율 구간 정보 반환
  static TaxBracket getBracket(double taxableIncome) {
    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return bracket;
      }
    }
    return brackets.last;
  }
}

/// 양도소득세 세율표 (2025년 기준)
class CapitalGainsTaxRates {
  static const List<TaxBracket> brackets = [
    TaxBracket(threshold: 14000000, rate: 0.06, deduction: 0),
    TaxBracket(threshold: 50000000, rate: 0.15, deduction: 1260000),
    TaxBracket(threshold: 88000000, rate: 0.24, deduction: 5760000),
    TaxBracket(threshold: 150000000, rate: 0.35, deduction: 15440000),
    TaxBracket(threshold: 300000000, rate: 0.38, deduction: 19940000),
    TaxBracket(threshold: 500000000, rate: 0.40, deduction: 25940000),
    TaxBracket(threshold: 1000000000, rate: 0.42, deduction: 35940000),
    TaxBracket(threshold: double.infinity, rate: 0.45, deduction: 65940000),
  ];

  /// 기본세율 양도소득세 계산 (일반 부동산)
  static double calculate(double taxableIncome) {
    if (taxableIncome <= 0) return 0;

    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return taxableIncome * bracket.rate - bracket.deduction;
      }
    }

    final lastBracket = brackets.last;
    return taxableIncome * lastBracket.rate - lastBracket.deduction;
  }

  /// 세율 구간 정보 반환
  static TaxBracket getBracket(double taxableIncome) {
    for (final bracket in brackets) {
      if (taxableIncome <= bracket.threshold) {
        return bracket;
      }
    }
    return brackets.last;
  }

  /// 비사업용 토지 등 중과세율
  static const double heavyTaxRate = 0.60;

  /// 미등기 양도 중과세율
  static const double unregisteredTaxRate = 0.70;

  /// 1년 미만 보유 단기양도 세율 (주택)
  static const double shortTermHousingRate = 0.70;

  /// 1년 이상 2년 미만 보유 세율 (주택)
  static const double midTermHousingRate = 0.60;

  /// 분양권 단기양도 세율
  static const double presaleRightShortTermRate = 0.70;
}

/// 퇴직소득세 환산급여 세율표 (2025년 기준)
class RetirementIncomeTaxRates {
  static const List<TaxBracket> convertedSalaryBrackets = [
    TaxBracket(threshold: 8000000, rate: 1.00, deduction: 0), // 100% 공제
    TaxBracket(threshold: 70000000, rate: 0.60, deduction: 0), // 60% 공제
    TaxBracket(threshold: 100000000, rate: 0.55, deduction: 0), // 55% 공제
    TaxBracket(threshold: 300000000, rate: 0.45, deduction: 0), // 45% 공제
    TaxBracket(threshold: double.infinity, rate: 0.35, deduction: 0), // 35% 공제
  ];

  /// 환산급여별 공제액 계산
  static double calculateConvertedDeduction(double convertedSalary) {
    if (convertedSalary <= 8000000) {
      return convertedSalary; // 전액 공제
    } else if (convertedSalary <= 70000000) {
      return 8000000 + (convertedSalary - 8000000) * 0.60;
    } else if (convertedSalary <= 100000000) {
      return 45200000 + (convertedSalary - 70000000) * 0.55;
    } else if (convertedSalary <= 300000000) {
      return 61700000 + (convertedSalary - 100000000) * 0.45;
    } else {
      return 151700000 + (convertedSalary - 300000000) * 0.35;
    }
  }
}
