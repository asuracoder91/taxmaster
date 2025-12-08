/// 근로소득공제
class EarnedIncomeDeduction {
  /// 총급여액에 따른 근로소득공제 계산
  static double calculate(double totalSalary) {
    if (totalSalary <= 0) return 0;

    if (totalSalary <= 5000000) {
      return totalSalary * 0.70;
    } else if (totalSalary <= 15000000) {
      return 3500000 + (totalSalary - 5000000) * 0.40;
    } else if (totalSalary <= 45000000) {
      return 7500000 + (totalSalary - 15000000) * 0.15;
    } else if (totalSalary <= 100000000) {
      return 12000000 + (totalSalary - 45000000) * 0.05;
    } else {
      return 14750000 + (totalSalary - 100000000) * 0.02;
    }
  }

  /// 공제율 정보 반환
  static Map<String, dynamic> getDeductionInfo(double totalSalary) {
    if (totalSalary <= 5000000) {
      return {'rate': 0.70, 'base': 0, 'description': '500만원 이하: 70%'};
    } else if (totalSalary <= 15000000) {
      return {
        'rate': 0.40,
        'base': 3500000,
        'description': '500만원 초과 1,500만원 이하: 350만원 + (초과분×40%)'
      };
    } else if (totalSalary <= 45000000) {
      return {
        'rate': 0.15,
        'base': 7500000,
        'description': '1,500만원 초과 4,500만원 이하: 750만원 + (초과분×15%)'
      };
    } else if (totalSalary <= 100000000) {
      return {
        'rate': 0.05,
        'base': 12000000,
        'description': '4,500만원 초과 1억원 이하: 1,200만원 + (초과분×5%)'
      };
    } else {
      return {
        'rate': 0.02,
        'base': 14750000,
        'description': '1억원 초과: 1,475만원 + (초과분×2%)'
      };
    }
  }
}

/// 연금소득공제
class PensionIncomeDeduction {
  /// 총연금액에 따른 연금소득공제 계산
  static double calculate(double totalPension) {
    if (totalPension <= 0) return 0;

    if (totalPension <= 3500000) {
      return totalPension; // 전액 공제
    } else if (totalPension <= 7000000) {
      return 3500000 + (totalPension - 3500000) * 0.40;
    } else if (totalPension <= 14000000) {
      return 4900000 + (totalPension - 7000000) * 0.20;
    } else {
      return 6300000 + (totalPension - 14000000) * 0.10;
    }
  }

  /// 공제율 정보 반환
  static Map<String, dynamic> getDeductionInfo(double totalPension) {
    if (totalPension <= 3500000) {
      return {'rate': 1.00, 'base': 0, 'description': '350만원 이하: 전액공제'};
    } else if (totalPension <= 7000000) {
      return {
        'rate': 0.40,
        'base': 3500000,
        'description': '350만원 초과 700만원 이하: 350만원 + (초과분×40%)'
      };
    } else if (totalPension <= 14000000) {
      return {
        'rate': 0.20,
        'base': 4900000,
        'description': '700만원 초과 1,400만원 이하: 490만원 + (초과분×20%)'
      };
    } else {
      return {
        'rate': 0.10,
        'base': 6300000,
        'description': '1,400만원 초과: 630만원 + (초과분×10%)'
      };
    }
  }
}

/// 퇴직소득공제 (근속연수별)
class RetirementServiceDeduction {
  /// 근속연수에 따른 퇴직소득공제 계산
  static double calculate(int serviceYears) {
    if (serviceYears <= 0) return 0;

    if (serviceYears <= 5) {
      return 1000000.0 * serviceYears;
    } else if (serviceYears <= 10) {
      return 5000000 + 2000000.0 * (serviceYears - 5);
    } else if (serviceYears <= 20) {
      return 15000000 + 2500000.0 * (serviceYears - 10);
    } else {
      return 40000000 + 3000000.0 * (serviceYears - 20);
    }
  }

  /// 공제액 정보 반환
  static Map<String, dynamic> getDeductionInfo(int serviceYears) {
    if (serviceYears <= 5) {
      return {
        'formula': '100만원 × 근속연수',
        'description': '5년 이하'
      };
    } else if (serviceYears <= 10) {
      return {
        'formula': '500만원 + 200만원 × (근속연수 - 5년)',
        'description': '5년 초과 10년 이하'
      };
    } else if (serviceYears <= 20) {
      return {
        'formula': '1,500만원 + 250만원 × (근속연수 - 10년)',
        'description': '10년 초과 20년 이하'
      };
    } else {
      return {
        'formula': '4,000만원 + 300만원 × (근속연수 - 20년)',
        'description': '20년 초과'
      };
    }
  }

  /// 공제 테이블 반환
  static List<Map<String, String>> getDeductionTable() {
    return [
      {'years': '5년 이하', 'deduction': '100만원 × 근속연수'},
      {'years': '5년 초과 10년 이하', 'deduction': '500만원 + 200만원 × (근속연수 - 5년)'},
      {'years': '10년 초과 20년 이하', 'deduction': '1,500만원 + 250만원 × (근속연수 - 10년)'},
      {'years': '20년 초과', 'deduction': '4,000만원 + 300만원 × (근속연수 - 20년)'},
    ];
  }
}

/// 장기보유특별공제율 (양도소득세)
class LongTermHoldingDeduction {
  /// 보유기간에 따른 공제율 반환
  static double getRate(int holdingYears) {
    if (holdingYears < 3) return 0;
    if (holdingYears < 4) return 0.06;
    if (holdingYears < 5) return 0.08;
    if (holdingYears < 6) return 0.10;
    if (holdingYears < 7) return 0.12;
    if (holdingYears < 8) return 0.14;
    if (holdingYears < 9) return 0.16;
    if (holdingYears < 10) return 0.18;
    if (holdingYears < 11) return 0.20;
    if (holdingYears < 12) return 0.22;
    if (holdingYears < 13) return 0.24;
    if (holdingYears < 14) return 0.26;
    if (holdingYears < 15) return 0.28;
    return 0.30; // 15년 이상
  }

  /// 공제율 테이블 반환
  static List<Map<String, dynamic>> getRateTable() {
    return [
      {'years': '3년 이상 4년 미만', 'rate': 0.06},
      {'years': '4년 이상 5년 미만', 'rate': 0.08},
      {'years': '5년 이상 6년 미만', 'rate': 0.10},
      {'years': '6년 이상 7년 미만', 'rate': 0.12},
      {'years': '7년 이상 8년 미만', 'rate': 0.14},
      {'years': '8년 이상 9년 미만', 'rate': 0.16},
      {'years': '9년 이상 10년 미만', 'rate': 0.18},
      {'years': '10년 이상 11년 미만', 'rate': 0.20},
      {'years': '11년 이상 12년 미만', 'rate': 0.22},
      {'years': '12년 이상 13년 미만', 'rate': 0.24},
      {'years': '13년 이상 14년 미만', 'rate': 0.26},
      {'years': '14년 이상 15년 미만', 'rate': 0.28},
      {'years': '15년 이상', 'rate': 0.30},
    ];
  }

  /// 1세대 1주택 거주기간 공제율 (추가)
  static double getResidenceRate(int residenceYears) {
    if (residenceYears < 2) return 0;
    if (residenceYears < 3) return 0.08;
    if (residenceYears < 4) return 0.12;
    if (residenceYears < 5) return 0.16;
    if (residenceYears < 6) return 0.20;
    if (residenceYears < 7) return 0.24;
    if (residenceYears < 8) return 0.28;
    if (residenceYears < 9) return 0.32;
    if (residenceYears < 10) return 0.36;
    return 0.40; // 10년 이상
  }
}

/// 재상속 공제율 (상속세)
class ReinheritanceDeduction {
  /// 재상속 기간에 따른 공제율 반환
  static double getDeductionRate(int years) {
    if (years <= 1) return 1.00;
    if (years <= 2) return 0.90;
    if (years <= 3) return 0.80;
    if (years <= 4) return 0.70;
    if (years <= 5) return 0.60;
    if (years <= 6) return 0.50;
    if (years <= 7) return 0.40;
    if (years <= 8) return 0.30;
    if (years <= 9) return 0.20;
    if (years <= 10) return 0.10;
    return 0; // 10년 초과
  }

  /// 공제율 테이블 반환
  static List<Map<String, dynamic>> getRateTable() {
    return [
      {'years': '1년 이내', 'rate': 1.00},
      {'years': '2년 이내', 'rate': 0.90},
      {'years': '3년 이내', 'rate': 0.80},
      {'years': '4년 이내', 'rate': 0.70},
      {'years': '5년 이내', 'rate': 0.60},
      {'years': '6년 이내', 'rate': 0.50},
      {'years': '7년 이내', 'rate': 0.40},
      {'years': '8년 이내', 'rate': 0.30},
      {'years': '9년 이내', 'rate': 0.20},
      {'years': '10년 이내', 'rate': 0.10},
    ];
  }
}

/// 인적공제
class PersonalDeduction {
  /// 기본공제 (1인당)
  static const double basicDeduction = 1500000;

  /// 배우자 공제
  static const double spouseDeduction = 1500000;

  /// 부양가족 공제 (1인당)
  static const double dependentDeduction = 1500000;

  /// 경로우대 추가공제 (70세 이상)
  static const double elderlyDeduction = 1000000;

  /// 장애인 추가공제
  static const double disabledDeduction = 2000000;

  /// 부녀자 추가공제
  static const double womenDeduction = 500000;

  /// 한부모 추가공제
  static const double singleParentDeduction = 1000000;

  /// 인적공제 총액 계산
  static double calculate({
    required bool includeSelf,
    required bool hasSpouse,
    required int dependents,
    required int elderlyCount,
    required int disabledCount,
    required bool isWomanDeductionEligible,
    required bool isSingleParent,
  }) {
    double total = 0;

    // 기본공제
    if (includeSelf) total += basicDeduction;
    if (hasSpouse) total += spouseDeduction;
    total += dependentDeduction * dependents;

    // 추가공제
    total += elderlyDeduction * elderlyCount;
    total += disabledDeduction * disabledCount;
    if (isWomanDeductionEligible) total += womenDeduction;
    if (isSingleParent) total += singleParentDeduction;

    return total;
  }
}

/// 증여세 공제한도
class GiftTaxDeduction {
  /// 배우자로부터 증여 (10년간)
  static const double spouseDeduction = 600000000;

  /// 직계존속으로부터 증여 (성인, 10년간)
  static const double adultFromParentDeduction = 50000000;

  /// 직계존속으로부터 증여 (미성년, 10년간)
  static const double minorFromParentDeduction = 20000000;

  /// 직계비속으로부터 증여 (10년간)
  static const double fromChildDeduction = 50000000;

  /// 기타 친족으로부터 증여 (10년간)
  static const double otherRelativeDeduction = 10000000;

  /// 수증자 유형에 따른 공제한도 반환
  static double getDeductionLimit(GiftRelation relation) {
    switch (relation) {
      case GiftRelation.spouse:
        return spouseDeduction;
      case GiftRelation.directDescendantAdult:
        return adultFromParentDeduction;
      case GiftRelation.directDescendantMinor:
        return minorFromParentDeduction;
      case GiftRelation.directAscendant:
        return fromChildDeduction;
      case GiftRelation.other:
        return otherRelativeDeduction;
    }
  }
}

/// 증여자와의 관계
enum GiftRelation {
  spouse,              // 배우자
  directDescendantAdult, // 직계비속 (성년)
  directDescendantMinor, // 직계비속 (미성년)
  directAscendant,     // 직계존속
  other,               // 기타친족
}

/// 상속세 공제
class InheritanceTaxDeduction {
  /// 기초공제
  static const double basicDeduction = 200000000;

  /// 배우자 공제 (최소)
  static const double minSpouseDeduction = 500000000;

  /// 배우자 공제 (최대)
  static const double maxSpouseDeduction = 3000000000;

  /// 일괄공제
  static const double lumpSumDeduction = 500000000;

  /// 금융재산 공제 한도
  static const double maxFinancialAssetDeduction = 200000000;

  /// 금융재산 공제 계산
  static double calculateFinancialAssetDeduction(double financialAssets) {
    if (financialAssets <= 20000000) {
      return financialAssets; // 전액 공제
    } else if (financialAssets <= 100000000) {
      return 20000000; // 2천만원 공제
    } else {
      // 1억 초과: 20% 공제 (최대 2억)
      final deduction = financialAssets * 0.20;
      return deduction > maxFinancialAssetDeduction
          ? maxFinancialAssetDeduction
          : deduction;
    }
  }

  /// 동거주택 상속공제 한도
  static const double cohabitationHousingDeduction = 600000000;

  /// 가업상속 공제 한도 (10년 이상)
  static const double familyBusinessDeduction10Years = 20000000000;

  /// 가업상속 공제 한도 (20년 이상)
  static const double familyBusinessDeduction20Years = 30000000000;

  /// 가업상속 공제 한도 (30년 이상)
  static const double familyBusinessDeduction30Years = 60000000000;

  /// 영농상속 공제 한도
  static const double farmingDeduction = 1500000000;
}
