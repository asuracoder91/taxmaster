import '../../shared/models/deduction_item.dart';
import '../constants/deduction_rates.dart';

/// 세금 유형별 공제 상세 정보 생성 유틸리티
///
/// 각 세금 계산 결과에서 공제 항목별 금액과 계산식을 생성합니다.
class DeductionDetailsBuilder {
  DeductionDetailsBuilder._();

  // ==========================================================================
  // 종합소득세 공제
  // ==========================================================================

  /// 종합소득세 공제 상세 정보 생성
  static DeductionDetails buildIncomeTaxDeductions({
    required double earnedIncome,
    required double pensionIncome,
    required double earnedIncomeDeduction,
    required double pensionIncomeDeduction,
    required double personalDeductions,
    required bool hasSpouse,
    required int dependents,
    int elderlyCount = 0,
    int disabledCount = 0,
    bool isWomanDeductionEligible = false,
    bool isSingleParent = false,
  }) {
    final items = <DeductionItem>[];

    // 1. 근로소득공제
    if (earnedIncome > 0 && earnedIncomeDeduction > 0) {
      final info = EarnedIncomeDeduction.getDeductionInfo(earnedIncome);
      items.add(DeductionItem(
        name: '근로소득공제',
        amount: earnedIncomeDeduction,
        formula: _buildEarnedIncomeFormula(earnedIncome),
        description: info['description'] as String,
      ));
    }

    // 2. 연금소득공제
    if (pensionIncome > 0 && pensionIncomeDeduction > 0) {
      final info = PensionIncomeDeduction.getDeductionInfo(pensionIncome);
      items.add(DeductionItem(
        name: '연금소득공제',
        amount: pensionIncomeDeduction,
        formula: _buildPensionIncomeFormula(pensionIncome),
        description: info['description'] as String,
      ));
    }

    // 3. 인적공제 (하위 항목 포함)
    if (personalDeductions > 0) {
      items.add(_buildPersonalDeductionItem(
        totalAmount: personalDeductions,
        hasSpouse: hasSpouse,
        dependents: dependents,
        elderlyCount: elderlyCount,
        disabledCount: disabledCount,
        isWomanDeductionEligible: isWomanDeductionEligible,
        isSingleParent: isSingleParent,
      ));
    }

    return DeductionDetails(
      items: items,
      totalAmount: earnedIncomeDeduction + pensionIncomeDeduction + personalDeductions,
    );
  }

  /// 근로소득공제 계산식 생성
  static String _buildEarnedIncomeFormula(double earnedIncome) {
    if (earnedIncome <= 5000000) {
      return '${_formatMan(earnedIncome)} × 70%';
    } else if (earnedIncome <= 15000000) {
      return '350만원 + (${_formatMan(earnedIncome)} - 500만원) × 40%';
    } else if (earnedIncome <= 45000000) {
      return '750만원 + (${_formatMan(earnedIncome)} - 1,500만원) × 15%';
    } else if (earnedIncome <= 100000000) {
      return '1,200만원 + (${_formatMan(earnedIncome)} - 4,500만원) × 5%';
    } else {
      return '1,475만원 + (${_formatMan(earnedIncome)} - 1억원) × 2%';
    }
  }

  /// 연금소득공제 계산식 생성
  static String _buildPensionIncomeFormula(double pensionIncome) {
    if (pensionIncome <= 3500000) {
      return '${_formatMan(pensionIncome)} 전액공제';
    } else if (pensionIncome <= 7000000) {
      return '350만원 + (${_formatMan(pensionIncome)} - 350만원) × 40%';
    } else if (pensionIncome <= 14000000) {
      return '490만원 + (${_formatMan(pensionIncome)} - 700만원) × 20%';
    } else {
      return '630만원 + (${_formatMan(pensionIncome)} - 1,400만원) × 10%';
    }
  }

  /// 인적공제 상세 항목 생성
  static DeductionItem _buildPersonalDeductionItem({
    required double totalAmount,
    required bool hasSpouse,
    required int dependents,
    required int elderlyCount,
    required int disabledCount,
    required bool isWomanDeductionEligible,
    required bool isSingleParent,
  }) {
    final subItems = <DeductionItem>[];

    // 기본공제 - 본인
    subItems.add(const DeductionItem(
      name: '본인 기본공제',
      amount: 1500000,
      description: '1인당 150만원',
    ));

    // 배우자 공제
    if (hasSpouse) {
      subItems.add(const DeductionItem(
        name: '배우자공제',
        amount: 1500000,
        description: '1인당 150만원',
      ));
    }

    // 부양가족 공제
    if (dependents > 0) {
      subItems.add(DeductionItem(
        name: '부양가족공제',
        amount: 1500000.0 * dependents,
        formula: '150만원 × $dependents인',
        description: '1인당 150만원',
      ));
    }

    // 경로우대 추가공제
    if (elderlyCount > 0) {
      subItems.add(DeductionItem(
        name: '경로우대 추가공제',
        amount: 1000000.0 * elderlyCount,
        formula: '100만원 × $elderlyCount인',
        description: '70세 이상 1인당 100만원',
      ));
    }

    // 장애인 추가공제
    if (disabledCount > 0) {
      subItems.add(DeductionItem(
        name: '장애인 추가공제',
        amount: 2000000.0 * disabledCount,
        formula: '200만원 × $disabledCount인',
        description: '장애인 1인당 200만원',
      ));
    }

    // 부녀자 추가공제
    if (isWomanDeductionEligible) {
      subItems.add(const DeductionItem(
        name: '부녀자 추가공제',
        amount: 500000,
        description: '50만원',
      ));
    }

    // 한부모 추가공제
    if (isSingleParent) {
      subItems.add(const DeductionItem(
        name: '한부모 추가공제',
        amount: 1000000,
        description: '100만원',
      ));
    }

    return DeductionItem(
      name: '인적공제',
      amount: totalAmount,
      subItems: subItems,
    );
  }

  // ==========================================================================
  // 양도소득세 공제
  // ==========================================================================

  /// 양도소득세 공제 상세 정보 생성
  static DeductionDetails buildCapitalGainsTaxDeductions({
    required double capitalGain,
    required int holdingYears,
    required double longTermDeductionRate,
    required double longTermDeduction,
    required double basicDeduction,
    bool isOneHouseOneFamily = false,
    int residenceYears = 0,
  }) {
    final items = <DeductionItem>[];

    // 1. 장기보유특별공제
    if (longTermDeduction > 0) {
      String formula = '${_formatAuto(capitalGain)} × ${(longTermDeductionRate * 100).toStringAsFixed(0)}%';
      String description = '보유기간 $holdingYears년';

      if (isOneHouseOneFamily) {
        final holdingRate = LongTermHoldingDeduction.getRate(holdingYears);
        final residenceRate = LongTermHoldingDeduction.getResidenceRate(residenceYears);
        description = '보유 ${(holdingRate * 100).toStringAsFixed(0)}%';
        if (residenceRate > 0) {
          description += ' + 거주 ${(residenceRate * 100).toStringAsFixed(0)}%';
        }
        description += ' (1세대 1주택)';
      }

      items.add(DeductionItem(
        name: '장기보유특별공제',
        amount: longTermDeduction,
        formula: formula,
        description: description,
      ));
    }

    // 2. 기본공제
    if (basicDeduction > 0) {
      items.add(DeductionItem(
        name: '기본공제',
        amount: basicDeduction,
        description: '양도소득 기본공제 (연 250만원)',
      ));
    }

    return DeductionDetails(
      items: items,
      totalAmount: longTermDeduction + basicDeduction,
    );
  }

  // ==========================================================================
  // 상속세 공제
  // ==========================================================================

  /// 상속세 공제 상세 정보 생성
  static DeductionDetails buildInheritanceTaxDeductions({
    required double basicDeduction,
    required double spouseDeduction,
    required double childDeduction,
    required double financialDeduction,
    required double housingDeduction,
    required double reinheritanceDeduction,
    required bool hasSpouse,
    required int childrenCount,
    required int parentsCount,
    required int siblingsCount,
    required double financialAssets,
    required double housingValue,
    required int reinheritanceYears,
    bool usedLumpSum = false,
    double personalDeduction = 0,
  }) {
    final items = <DeductionItem>[];

    // 1. 일괄공제 또는 기초공제+인적공제
    if (usedLumpSum) {
      items.add(DeductionItem(
        name: '일괄공제',
        amount: basicDeduction,
        description: '일괄공제 5억원 적용 (기초+인적보다 유리)',
      ));
    } else {
      if (basicDeduction > 0) {
        items.add(DeductionItem(
          name: '기초공제',
          amount: basicDeduction,
          description: '상속세 기초공제 (2억원)',
        ));
      }

      // 인적공제 (자녀, 부모, 형제자매)
      if (personalDeduction > 0) {
        final totalPersons = childrenCount + parentsCount + siblingsCount;
        final subItems = <DeductionItem>[];

        if (childrenCount > 0) {
          subItems.add(DeductionItem(
            name: '자녀공제',
            amount: childrenCount * 50000000.0,
            formula: '5,000만원 × $childrenCount인',
          ));
        }

        if (parentsCount > 0) {
          subItems.add(DeductionItem(
            name: '직계존속공제',
            amount: parentsCount * 50000000.0,
            formula: '5,000만원 × $parentsCount인',
          ));
        }

        if (siblingsCount > 0) {
          subItems.add(DeductionItem(
            name: '형제자매공제',
            amount: siblingsCount * 50000000.0,
            formula: '5,000만원 × $siblingsCount인',
          ));
        }

        items.add(DeductionItem(
          name: '인적공제',
          amount: personalDeduction,
          formula: '5,000만원 × $totalPersons인',
          subItems: subItems,
        ));
      }
    }

    // 2. 배우자 공제
    if (hasSpouse && spouseDeduction > 0) {
      items.add(DeductionItem(
        name: '배우자 공제',
        amount: spouseDeduction,
        description: '법정상속지분 내 실제상속분 (5억~30억)',
      ));
    }

    // 4. 금융재산 공제
    if (financialDeduction > 0) {
      String formula;
      String description;

      if (financialAssets <= 20000000) {
        formula = '${_formatMan(financialAssets)} 전액공제';
        description = '순금융재산 2천만원 이하';
      } else if (financialAssets <= 100000000) {
        formula = '2,000만원 (정액공제)';
        description = '순금융재산 1억원 이하';
      } else {
        formula = '${_formatAuto(financialAssets)} × 20%';
        description = '순금융재산의 20% (최대 2억원)';
      }

      items.add(DeductionItem(
        name: '금융재산 공제',
        amount: financialDeduction,
        formula: formula,
        description: description,
      ));
    }

    // 5. 동거주택 공제
    if (housingDeduction > 0) {
      items.add(DeductionItem(
        name: '동거주택 상속공제',
        amount: housingDeduction,
        formula: housingValue > 600000000
            ? '6억원 (한도적용)'
            : _formatAuto(housingValue),
        description: '동거주택가액 (최대 6억원)',
      ));
    }

    // 6. 재상속 공제
    if (reinheritanceDeduction > 0) {
      final rate = ReinheritanceDeduction.getDeductionRate(reinheritanceYears);
      items.add(DeductionItem(
        name: '재상속 공제',
        amount: reinheritanceDeduction,
        formula: '전회상속재산 × ${(rate * 100).toStringAsFixed(0)}%',
        description: '상속 후 $reinheritanceYears년 이내 재상속',
      ));
    }

    final totalAmount = basicDeduction +
        spouseDeduction +
        childDeduction +
        financialDeduction +
        housingDeduction +
        reinheritanceDeduction;

    return DeductionDetails(
      items: items,
      totalAmount: totalAmount,
    );
  }

  // ==========================================================================
  // 증여세 공제
  // ==========================================================================

  /// 증여세 공제 상세 정보 생성
  static DeductionDetails buildGiftTaxDeductions({
    required GiftRelation relation,
    required double giftDeduction,
    required double giftValue,
    double previousGifts = 0,
  }) {
    final items = <DeductionItem>[];

    // 증여재산공제
    final relationName = _getGiftRelationName(relation);
    final deductionLimit = GiftTaxDeduction.getDeductionLimit(relation);

    items.add(DeductionItem(
      name: '증여재산공제',
      amount: giftDeduction,
      description: '$relationName으로부터 증여 (10년간 ${_formatAuto(deductionLimit.toDouble())} 한도)',
    ));

    // 10년 내 기증여 금액이 있는 경우 안내
    if (previousGifts > 0) {
      items.add(DeductionItem(
        name: '참고: 10년 내 기증여',
        amount: 0, // 표시용이므로 0
        description: '${_formatAuto(previousGifts)} (공제 한도에서 차감됨)',
      ));
    }

    return DeductionDetails(
      items: items.where((item) => item.amount > 0).toList(),
      totalAmount: giftDeduction,
    );
  }

  /// 증여자와의 관계명 반환
  static String _getGiftRelationName(GiftRelation relation) {
    switch (relation) {
      case GiftRelation.spouse:
        return '배우자';
      case GiftRelation.directDescendantAdult:
        return '직계존속 (성년)';
      case GiftRelation.directDescendantMinor:
        return '직계존속 (미성년)';
      case GiftRelation.directAscendant:
        return '직계비속';
      case GiftRelation.other:
        return '기타친족';
    }
  }

  // ==========================================================================
  // 퇴직소득세 공제
  // ==========================================================================

  /// 퇴직소득세 공제 상세 정보 생성
  static DeductionDetails buildRetirementIncomeTaxDeductions({
    required int serviceYears,
    required double serviceDeduction,
    required double convertedIncome,
    required double convertedDeduction,
    required double retirementPay,
  }) {
    final items = <DeductionItem>[];

    // 1. 근속연수 공제
    if (serviceDeduction > 0) {
      final info = RetirementServiceDeduction.getDeductionInfo(serviceYears);
      items.add(DeductionItem(
        name: '근속연수 공제',
        amount: serviceDeduction,
        formula: _buildServiceDeductionFormula(serviceYears),
        description: info['description'] as String,
      ));
    }

    // 2. 환산급여 공제
    if (convertedDeduction > 0) {
      items.add(DeductionItem(
        name: '환산급여 공제',
        amount: convertedDeduction,
        formula: _buildConvertedDeductionFormula(convertedIncome),
        description: '환산급여 ${_formatAuto(convertedIncome)} 기준',
      ));
    }

    return DeductionDetails(
      items: items,
      totalAmount: serviceDeduction + convertedDeduction,
    );
  }

  /// 근속연수공제 계산식 생성
  static String _buildServiceDeductionFormula(int serviceYears) {
    if (serviceYears <= 5) {
      return '100만원 × $serviceYears년';
    } else if (serviceYears <= 10) {
      return '500만원 + 200만원 × ($serviceYears년 - 5년)';
    } else if (serviceYears <= 20) {
      return '1,500만원 + 250만원 × ($serviceYears년 - 10년)';
    } else {
      return '4,000만원 + 300만원 × ($serviceYears년 - 20년)';
    }
  }

  /// 환산급여공제 계산식 생성
  static String _buildConvertedDeductionFormula(double convertedIncome) {
    if (convertedIncome <= 8000000) {
      return '${_formatAuto(convertedIncome)} 전액공제';
    } else if (convertedIncome <= 70000000) {
      return '800만원 + (${_formatAuto(convertedIncome)} - 800만원) × 60%';
    } else if (convertedIncome <= 100000000) {
      return '4,520만원 + (${_formatAuto(convertedIncome)} - 7,000만원) × 55%';
    } else if (convertedIncome <= 300000000) {
      return '6,170만원 + (${_formatAuto(convertedIncome)} - 1억원) × 45%';
    } else {
      return '1억5,170만원 + (${_formatAuto(convertedIncome)} - 3억원) × 35%';
    }
  }

  // ==========================================================================
  // 헬퍼 메서드
  // ==========================================================================

  /// 금액을 만원 단위로 포맷
  static String _formatMan(double value) {
    final inMan = value / 10000;
    if (inMan >= 10000) {
      final inEok = value / 100000000;
      if (inEok == inEok.roundToDouble()) {
        return '${inEok.toInt()}억원';
      }
      return '${inEok.toStringAsFixed(1)}억원';
    }
    if (inMan == inMan.roundToDouble()) {
      return '${inMan.toInt()}만원';
    }
    return '${inMan.toStringAsFixed(1)}만원';
  }

  /// 자동 단위 선택 포맷
  static String _formatAuto(double value) {
    if (value.abs() >= 100000000) {
      final inEok = value / 100000000;
      if (inEok == inEok.roundToDouble()) {
        return '${inEok.toInt()}억원';
      }
      return '${inEok.toStringAsFixed(1)}억원';
    } else if (value.abs() >= 10000) {
      final inMan = value / 10000;
      if (inMan == inMan.roundToDouble()) {
        return '${inMan.toInt()}만원';
      }
      return '${inMan.toStringAsFixed(1)}만원';
    } else {
      return '${value.toInt()}원';
    }
  }
}
