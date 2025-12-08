import '../constants/tax_rates.dart';
import '../constants/deduction_rates.dart';

/// 세금 계산 유틸리티 클래스
class TaxCalculatorUtils {
  TaxCalculatorUtils._();

  /// 종합소득세 계산
  static TaxCalculationResult calculateIncomeTax({
    required double earnedIncome,
    double businessIncome = 0,
    double interestIncome = 0,
    double dividendIncome = 0,
    double pensionIncome = 0,
    double otherIncome = 0,
    required int dependents,
    required bool hasSpouse,
    int elderlyCount = 0,
    int disabledCount = 0,
    bool isWomanDeductionEligible = false,
    bool isSingleParent = false,
  }) {
    // 1. 근로소득공제 계산
    final earnedIncomeDeduction =
        EarnedIncomeDeduction.calculate(earnedIncome);
    final earnedIncomeAmount = earnedIncome - earnedIncomeDeduction;

    // 2. 연금소득공제 계산
    final pensionIncomeDeduction =
        PensionIncomeDeduction.calculate(pensionIncome);
    final pensionIncomeAmount = pensionIncome - pensionIncomeDeduction;

    // 3. 종합소득금액
    final comprehensiveIncome = earnedIncomeAmount +
        businessIncome +
        interestIncome +
        dividendIncome +
        pensionIncomeAmount +
        otherIncome;

    // 4. 인적공제 계산
    final personalDeductions = PersonalDeduction.calculate(
      includeSelf: true,
      hasSpouse: hasSpouse,
      dependents: dependents,
      elderlyCount: elderlyCount,
      disabledCount: disabledCount,
      isWomanDeductionEligible: isWomanDeductionEligible,
      isSingleParent: isSingleParent,
    );

    // 5. 과세표준
    final taxableIncome = (comprehensiveIncome - personalDeductions)
        .clamp(0, double.infinity);

    // 6. 산출세액
    final calculatedTax = IncomeTaxRates.calculate(taxableIncome);

    // 7. 세율 구간 정보
    final bracket = IncomeTaxRates.getBracket(taxableIncome);

    return TaxCalculationResult(
      totalIncome: earnedIncome +
          businessIncome +
          interestIncome +
          dividendIncome +
          pensionIncome +
          otherIncome,
      deductions: earnedIncomeDeduction +
          pensionIncomeDeduction +
          personalDeductions,
      taxableIncome: taxableIncome,
      calculatedTax: calculatedTax,
      effectiveRate: taxableIncome > 0 ? calculatedTax / taxableIncome : 0,
      marginalRate: bracket.rate,
      details: {
        'earnedIncomeDeduction': earnedIncomeDeduction,
        'pensionIncomeDeduction': pensionIncomeDeduction,
        'personalDeductions': personalDeductions,
        'comprehensiveIncome': comprehensiveIncome,
      },
    );
  }

  /// 법인세 계산
  static TaxCalculationResult calculateCorporateTax({
    required double taxableIncome,
  }) {
    final calculatedTax = CorporateTaxRates.calculate(taxableIncome);
    final bracket = CorporateTaxRates.getBracket(taxableIncome);

    return TaxCalculationResult(
      totalIncome: taxableIncome,
      deductions: 0,
      taxableIncome: taxableIncome,
      calculatedTax: calculatedTax,
      effectiveRate: taxableIncome > 0 ? calculatedTax / taxableIncome : 0,
      marginalRate: bracket.rate,
      details: {},
    );
  }

  /// 양도소득세 계산 (일반)
  static TaxCalculationResult calculateCapitalGainsTax({
    required double acquisitionPrice,
    required double transferPrice,
    required double expenses,
    required int holdingYears,
    bool isOneHouseOneFamily = false,
    int residenceYears = 0,
  }) {
    // 1. 양도차익
    final capitalGain = transferPrice - acquisitionPrice - expenses;
    if (capitalGain <= 0) {
      return TaxCalculationResult(
        totalIncome: 0,
        deductions: 0,
        taxableIncome: 0,
        calculatedTax: 0,
        effectiveRate: 0,
        marginalRate: 0,
        details: {'capitalGain': capitalGain},
      );
    }

    // 2. 장기보유특별공제
    double longTermDeductionRate = LongTermHoldingDeduction.getRate(holdingYears);

    // 1세대 1주택인 경우 거주기간 공제 추가
    if (isOneHouseOneFamily) {
      longTermDeductionRate +=
          LongTermHoldingDeduction.getResidenceRate(residenceYears);
      // 최대 80%
      longTermDeductionRate = longTermDeductionRate.clamp(0, 0.80);
    }

    final longTermDeduction = capitalGain * longTermDeductionRate;

    // 3. 양도소득금액
    final capitalGainAmount = capitalGain - longTermDeduction;

    // 4. 기본공제 (연 250만원)
    const basicDeduction = 2500000.0;
    final taxableIncome =
        (capitalGainAmount - basicDeduction).clamp(0, double.infinity);

    // 5. 산출세액
    final calculatedTax = CapitalGainsTaxRates.calculate(taxableIncome);
    final bracket = CapitalGainsTaxRates.getBracket(taxableIncome);

    return TaxCalculationResult(
      totalIncome: capitalGain,
      deductions: longTermDeduction + basicDeduction,
      taxableIncome: taxableIncome,
      calculatedTax: calculatedTax,
      effectiveRate: capitalGain > 0 ? calculatedTax / capitalGain : 0,
      marginalRate: bracket.rate,
      details: {
        'capitalGain': capitalGain,
        'longTermDeductionRate': longTermDeductionRate,
        'longTermDeduction': longTermDeduction,
        'basicDeduction': basicDeduction,
        'capitalGainAmount': capitalGainAmount,
      },
    );
  }

  /// 상속세 계산
  static TaxCalculationResult calculateInheritanceTax({
    required double totalAssets,
    required double debts,
    required double funeralExpenses,
    required bool hasSpouse,
    int childrenCount = 0,
    int parentsCount = 0,
    int siblingsCount = 0,
    double financialAssets = 0,
    double housingValue = 0,
    double reinheritanceValue = 0,
    int reinheritanceYears = 0,
  }) {
    // 1. 상속재산가액
    final debtsAndExpenses = debts + funeralExpenses;
    final inheritanceValue = totalAssets - debtsAndExpenses;
    if (inheritanceValue <= 0) {
      return TaxCalculationResult(
        totalIncome: totalAssets,
        deductions: 0,
        taxableIncome: 0,
        calculatedTax: 0,
        effectiveRate: 0,
        marginalRate: 0,
        details: {
          'inheritanceValue': inheritanceValue,
          'debtsAndExpenses': debtsAndExpenses,
          'totalDeductions': 0.0,
          'basicDeduction': 0.0,
          'spouseDeduction': 0.0,
          'childDeduction': 0.0,
          'financialDeduction': 0.0,
        },
      );
    }

    // 2. 공제 계산
    double totalDeductions = 0;

    // 기초공제 2억원
    const double basicDeduction = 200000000;
    totalDeductions += basicDeduction;

    // 배우자 공제 (최소 5억원)
    double spouseDeduction = 0;
    if (hasSpouse) {
      spouseDeduction = 500000000;
      totalDeductions += spouseDeduction;
    }

    // 인적공제 (자녀, 부모, 형제자매 각 5천만원)
    final childDeduction = childrenCount * 50000000.0;
    final parentDeduction = parentsCount * 50000000.0;
    final siblingDeduction = siblingsCount * 50000000.0;
    totalDeductions += childDeduction + parentDeduction + siblingDeduction;

    // 금융재산 공제
    double financialDeduction = 0;
    if (financialAssets > 0) {
      financialDeduction = InheritanceTaxDeduction.calculateFinancialAssetDeduction(financialAssets);
      totalDeductions += financialDeduction;
    }

    // 동거주택 공제 (최대 6억원)
    double housingDeduction = 0;
    if (housingValue > 0) {
      housingDeduction = housingValue.clamp(0, 600000000);
      totalDeductions += housingDeduction;
    }

    // 재상속 공제
    double reinheritanceDeduction = 0;
    if (reinheritanceValue > 0 && reinheritanceYears <= 10) {
      final rate = ReinheritanceDeduction.getDeductionRate(reinheritanceYears);
      reinheritanceDeduction = reinheritanceValue * rate;
      totalDeductions += reinheritanceDeduction;
    }

    // 3. 과세표준
    final taxableIncome =
        (inheritanceValue - totalDeductions).clamp(0, double.infinity);

    // 4. 산출세액
    final calculatedTax = InheritanceGiftTaxRates.calculate(taxableIncome);
    final bracket = InheritanceGiftTaxRates.getBracket(taxableIncome);

    return TaxCalculationResult(
      totalIncome: totalAssets,
      deductions: totalDeductions,
      taxableIncome: taxableIncome,
      calculatedTax: calculatedTax,
      effectiveRate:
          inheritanceValue > 0 ? calculatedTax / inheritanceValue : 0,
      marginalRate: bracket.rate,
      details: {
        'debtsAndExpenses': debtsAndExpenses,
        'totalDeductions': totalDeductions,
        'basicDeduction': basicDeduction,
        'spouseDeduction': spouseDeduction,
        'childDeduction': childDeduction + parentDeduction + siblingDeduction,
        'financialDeduction': financialDeduction,
        'housingDeduction': housingDeduction,
        'reinheritanceDeduction': reinheritanceDeduction,
      },
    );
  }

  /// 증여세 계산
  static TaxCalculationResult calculateGiftTax({
    required double giftValue,
    required GiftRelation relation,
    double previousGiftsIn10Years = 0,
  }) {
    // 1. 증여재산가액 (이전 10년간 증여 합산)
    final totalGiftValue = giftValue + previousGiftsIn10Years;

    // 2. 증여재산공제
    final giftDeduction = GiftTaxDeduction.getDeductionLimit(relation);

    // 3. 과세표준
    final taxableIncome =
        (totalGiftValue - giftDeduction).clamp(0, double.infinity);

    // 4. 산출세액
    final calculatedTax = InheritanceGiftTaxRates.calculate(taxableIncome);
    final bracket = InheritanceGiftTaxRates.getBracket(taxableIncome);

    // 5. 기납부 세액 공제 (이전 증여분에 대해 납부한 세액 - 추정)
    double previousTaxPaid = 0;
    if (previousGiftsIn10Years > giftDeduction) {
      previousTaxPaid = InheritanceGiftTaxRates.calculate(previousGiftsIn10Years - giftDeduction);
    }
    final finalTax = (calculatedTax - previousTaxPaid).clamp(0, double.infinity);

    return TaxCalculationResult(
      totalIncome: giftValue,
      deductions: giftDeduction,
      taxableIncome: taxableIncome,
      calculatedTax: finalTax,
      effectiveRate: giftValue > 0 ? finalTax / giftValue : 0,
      marginalRate: bracket.rate,
      details: {
        'totalGiftValue': totalGiftValue,
        'giftDeduction': giftDeduction,
        'previousGifts': previousGiftsIn10Years,
        'previousTaxPaid': previousTaxPaid,
        'calculatedTax': calculatedTax,
      },
    );
  }

  /// 퇴직소득세 계산
  static TaxCalculationResult calculateRetirementIncomeTax({
    required double retirementPay,
    required int serviceYears,
    required int serviceMonths,
  }) {
    // 근속연수 (1년 미만은 1년으로)
    final totalMonths = serviceYears * 12 + serviceMonths;
    final years = (totalMonths / 12).ceil();
    if (years <= 0) {
      return TaxCalculationResult(
        totalIncome: retirementPay,
        deductions: 0,
        taxableIncome: retirementPay,
        calculatedTax: 0,
        effectiveRate: 0,
        marginalRate: 0,
        details: {
          'serviceDeduction': 0.0,
          'convertedIncome': 0.0,
          'convertedDeduction': 0.0,
          'taxableConverted': 0.0,
          'convertedTax': 0.0,
        },
      );
    }

    // 1. 퇴직소득공제 (근속연수 공제)
    final serviceDeduction = RetirementServiceDeduction.calculate(years);

    // 2. 환산급여
    final taxableRetirement =
        (retirementPay - serviceDeduction).clamp(0, double.infinity);
    final convertedIncome = years > 0 ? (taxableRetirement / years) * 12 : 0.0;

    // 3. 환산급여 공제
    final convertedDeduction =
        RetirementIncomeTaxRates.calculateConvertedDeduction(convertedIncome);

    // 4. 환산 과세표준
    final taxableConverted =
        (convertedIncome - convertedDeduction).clamp(0, double.infinity);

    // 5. 환산 산출세액
    final convertedTax = IncomeTaxRates.calculate(taxableConverted);

    // 6. 실제 산출세액
    final calculatedTax = years > 0 ? convertedTax * years / 12 : 0.0;

    return TaxCalculationResult(
      totalIncome: retirementPay,
      deductions: serviceDeduction + convertedDeduction,
      taxableIncome: taxableRetirement,
      calculatedTax: calculatedTax,
      effectiveRate: retirementPay > 0 ? calculatedTax / retirementPay : 0,
      marginalRate: IncomeTaxRates.getBracket(taxableConverted).rate,
      details: {
        'serviceYears': years.toDouble(),
        'serviceDeduction': serviceDeduction,
        'convertedIncome': convertedIncome,
        'convertedDeduction': convertedDeduction,
        'taxableConverted': taxableConverted,
        'convertedTax': convertedTax,
      },
    );
  }
}

/// 세금 계산 결과
class TaxCalculationResult {
  final double totalIncome;
  final double deductions;
  final double taxableIncome;
  final double calculatedTax;
  final double effectiveRate;
  final double marginalRate;
  final Map<String, dynamic> details;

  const TaxCalculationResult({
    required this.totalIncome,
    required this.deductions,
    required this.taxableIncome,
    required this.calculatedTax,
    required this.effectiveRate,
    required this.marginalRate,
    required this.details,
  });

  /// 순소득 (세후)
  double get netIncome => totalIncome - calculatedTax;

  @override
  String toString() {
    return 'TaxCalculationResult('
        'totalIncome: $totalIncome, '
        'deductions: $deductions, '
        'taxableIncome: $taxableIncome, '
        'calculatedTax: $calculatedTax, '
        'effectiveRate: ${(effectiveRate * 100).toStringAsFixed(2)}%, '
        'marginalRate: ${(marginalRate * 100).toStringAsFixed(2)}%'
        ')';
  }
}
