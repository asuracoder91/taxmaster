/// 개별 공제 항목 정보
class DeductionItem {
  /// 공제 항목명 (예: "근로소득공제", "배우자공제")
  final String name;

  /// 공제 금액 (원 단위)
  final double amount;

  /// 계산식 (예: "750만원 + (3,000만원-1,500만원)×15%")
  final String? formula;

  /// 부가 설명 (예: "1,500만원 초과 4,500만원 이하 구간")
  final String? description;

  /// 하위 항목 (인적공제 상세 등)
  final List<DeductionItem>? subItems;

  const DeductionItem({
    required this.name,
    required this.amount,
    this.formula,
    this.description,
    this.subItems,
  });

  /// 금액이 0보다 큰지 확인
  bool get hasAmount => amount > 0;

  /// 하위 항목이 있는지 확인
  bool get hasSubItems => subItems != null && subItems!.isNotEmpty;

  @override
  String toString() {
    return 'DeductionItem(name: $name, amount: $amount, formula: $formula)';
  }
}

/// 세금 유형별 전체 공제 정보
class DeductionDetails {
  /// 공제 항목 목록
  final List<DeductionItem> items;

  /// 공제 총액
  final double totalAmount;

  const DeductionDetails({
    required this.items,
    required this.totalAmount,
  });

  /// 공제 항목이 있는지 확인
  bool get hasItems => items.isNotEmpty;

  /// 유효한 공제 항목만 필터링 (금액 > 0)
  List<DeductionItem> get validItems =>
      items.where((item) => item.hasAmount).toList();

  @override
  String toString() {
    return 'DeductionDetails(items: ${items.length}, totalAmount: $totalAmount)';
  }
}
