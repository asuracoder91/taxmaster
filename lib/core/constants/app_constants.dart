/// 앱 상수
class AppConstants {
  AppConstants._();

  /// 앱 이름
  static const String appName = 'Tax Master';

  /// 앱 버전
  static const String appVersion = '1.0.0';

  /// 세법 기준 연도
  static const int taxLawYear = 2025;

  /// Hive 박스 이름
  static const String calculationHistoryBox = 'calculation_history';
  static const String settingsBox = 'settings';
  static const String userPreferencesBox = 'user_preferences';

  /// 계산 히스토리 최대 저장 개수
  static const int maxHistoryCount = 100;

  /// 숫자 포맷
  static const String currencySymbol = '₩';
  static const String percentSymbol = '%';

  /// 세금 유형
  static const String incomeTax = '종합소득세';
  static const String corporateTax = '법인세';
  static const String capitalGainsTax = '양도소득세';
  static const String inheritanceTax = '상속세';
  static const String giftTax = '증여세';
  static const String retirementIncomeTax = '퇴직소득세';
}

/// 세금 유형 열거형
enum TaxType {
  incomeTax('종합소득세', 'income'),
  corporateTax('법인세', 'corporate'),
  capitalGainsTax('양도소득세', 'capital_gains'),
  inheritanceTax('상속세', 'inheritance'),
  giftTax('증여세', 'gift'),
  retirementIncomeTax('퇴직소득세', 'retirement');

  final String displayName;
  final String code;

  const TaxType(this.displayName, this.code);
}

/// 소득 유형 열거형
enum IncomeType {
  earned('근로소득', 'earned'),
  business('사업소득', 'business'),
  interest('이자소득', 'interest'),
  dividend('배당소득', 'dividend'),
  pension('연금소득', 'pension'),
  other('기타소득', 'other'),
  rental('임대소득', 'rental');

  final String displayName;
  final String code;

  const IncomeType(this.displayName, this.code);
}

/// 양도 자산 유형
enum AssetType {
  realEstate('부동산', 'real_estate'),
  stock('주식', 'stock'),
  otherAsset('기타자산', 'other');

  final String displayName;
  final String code;

  const AssetType(this.displayName, this.code);
}

/// 부동산 유형
enum RealEstateType {
  house('주택', 'house'),
  land('토지', 'land'),
  building('건물', 'building'),
  officetel('오피스텔', 'officetel'),
  presaleRight('분양권', 'presale_right');

  final String displayName;
  final String code;

  const RealEstateType(this.displayName, this.code);
}

/// 주식 유형
enum StockType {
  listed('상장주식', 'listed'),
  unlisted('비상장주식', 'unlisted'),
  majorShareholder('대주주', 'major_shareholder');

  final String displayName;
  final String code;

  const StockType(this.displayName, this.code);
}

/// 가족관계 유형 (상속/증여용)
enum FamilyRelationType {
  spouse('배우자', 'spouse'),
  child('자녀', 'child'),
  parent('부모', 'parent'),
  grandchild('손자녀', 'grandchild'),
  grandparent('조부모', 'grandparent'),
  sibling('형제자매', 'sibling'),
  other('기타친족', 'other');

  final String displayName;
  final String code;

  const FamilyRelationType(this.displayName, this.code);
}
