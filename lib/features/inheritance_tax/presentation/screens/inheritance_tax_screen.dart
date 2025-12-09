import 'package:flutter/material.dart';

import '../../../../core/constants/deduction_rates.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/tax_calculator_utils.dart';
import '../../../../shared/widgets/tax_input_field.dart';
import '../../../../shared/widgets/tax_result_card.dart';

/// 상속세 계산 화면
class InheritanceTaxScreen extends StatefulWidget {
  const InheritanceTaxScreen({super.key});

  @override
  State<InheritanceTaxScreen> createState() => _InheritanceTaxScreenState();
}

class _InheritanceTaxScreenState extends State<InheritanceTaxScreen> {
  final _formKey = GlobalKey<FormState>();

  final _totalAssetsController = TextEditingController();
  final _debtsController = TextEditingController();
  final _funeralExpensesController = TextEditingController();

  // 상속공제 옵션
  bool _hasSpouse = false;
  int _childrenCount = 0;
  int _parentsCount = 0;
  int _siblingsCount = 0;
  bool _isFinancialAssetDeduction = false;
  final _financialAssetsController = TextEditingController();
  bool _hasHousingDeduction = false;
  final _housingValueController = TextEditingController();

  // 재상속 공제
  bool _hasReinheritance = false;
  final _reinheritanceValueController = TextEditingController();
  int _reinheritanceYears = 0;

  TaxCalculationResult? _result;

  @override
  void dispose() {
    _totalAssetsController.dispose();
    _debtsController.dispose();
    _funeralExpensesController.dispose();
    _financialAssetsController.dispose();
    _housingValueController.dispose();
    _reinheritanceValueController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    // 만원 단위 입력을 원 단위로 변환
    final totalAssets = TaxInputField.getValueInWon(_totalAssetsController);
    final debts = TaxInputField.getValueInWon(_debtsController);
    final funeralExpenses = TaxInputField.getValueInWon(_funeralExpensesController);
    final financialAssets = TaxInputField.getValueInWon(_financialAssetsController);
    final housingValue = TaxInputField.getValueInWon(_housingValueController);
    final reinheritanceValue = TaxInputField.getValueInWon(_reinheritanceValueController);

    final result = TaxCalculatorUtils.calculateInheritanceTax(
      totalAssets: totalAssets,
      debts: debts,
      funeralExpenses: funeralExpenses,
      hasSpouse: _hasSpouse,
      childrenCount: _childrenCount,
      parentsCount: _parentsCount,
      siblingsCount: _siblingsCount,
      financialAssets: _isFinancialAssetDeduction ? financialAssets : 0,
      housingValue: _hasHousingDeduction ? housingValue : 0,
      reinheritanceValue: _hasReinheritance ? reinheritanceValue : 0,
      reinheritanceYears: _hasReinheritance ? _reinheritanceYears : 0,
    );

    setState(() {
      _result = result;
    });
  }

  void _reset() {
    _totalAssetsController.clear();
    _debtsController.clear();
    _funeralExpensesController.clear();
    _financialAssetsController.clear();
    _housingValueController.clear();
    _reinheritanceValueController.clear();

    setState(() {
      _hasSpouse = false;
      _childrenCount = 0;
      _parentsCount = 0;
      _siblingsCount = 0;
      _isFinancialAssetDeduction = false;
      _hasHousingDeduction = false;
      _hasReinheritance = false;
      _reinheritanceYears = 0;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상속세 계산'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: '초기화',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상속재산 입력
              _buildSectionTitle('상속재산'),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _totalAssetsController,
                label: '상속재산 총액',
                hint: '피상속인의 전체 재산',
                prefixIcon: Icons.account_balance,
                required: true,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _debtsController,
                label: '채무',
                hint: '피상속인의 채무',
                prefixIcon: Icons.money_off,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _funeralExpensesController,
                label: '장례비용',
                hint: '장례 관련 비용',
                prefixIcon: Icons.local_florist,
              ),

              const SizedBox(height: 24),

              // 기초공제 및 인적공제
              _buildSectionTitle('상속공제'),
              const SizedBox(height: 12),
              _buildDeductionOptions(),

              const SizedBox(height: 16),

              // 금융재산 공제
              _buildFinancialAssetDeduction(),

              const SizedBox(height: 16),

              // 동거주택 공제
              _buildHousingDeduction(),

              const SizedBox(height: 16),

              // 재상속 공제
              _buildReinheritanceDeduction(),

              const SizedBox(height: 24),

              // 계산 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('계산하기'),
                  ),
                ),
              ),

              // 결과 표시
              if (_result != null) ...[
                const SizedBox(height: 24),
                _buildResultCard(),
              ],

              const SizedBox(height: 24),

              // 세율표
              _buildRateTable(),

              const SizedBox(height: 16),

              // 재상속 공제율표
              _buildReinheritanceTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildDeductionOptions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기초공제 안내
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '기초공제: 2억원 (자동 적용)',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 배우자 공제
            SwitchListTile(
              title: const Text('배우자 공제'),
              subtitle: const Text('최소 5억원 (법정상속분 한도)'),
              value: _hasSpouse,
              onChanged: (value) {
                setState(() {
                  _hasSpouse = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            // 자녀 수
            _buildCounterTile(
              title: '자녀 수',
              subtitle: '1인당 5천만원',
              count: _childrenCount,
              onDecrement: () => setState(() => _childrenCount--),
              onIncrement: () => setState(() => _childrenCount++),
            ),
            const Divider(),

            // 직계존속 수
            _buildCounterTile(
              title: '직계존속 수',
              subtitle: '1인당 5천만원',
              count: _parentsCount,
              onDecrement: () => setState(() => _parentsCount--),
              onIncrement: () => setState(() => _parentsCount++),
            ),
            const Divider(),

            // 형제자매 수
            _buildCounterTile(
              title: '형제자매 수',
              subtitle: '1인당 5천만원',
              count: _siblingsCount,
              onDecrement: () => setState(() => _siblingsCount--),
              onIncrement: () => setState(() => _siblingsCount++),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterTile({
    required String title,
    required String subtitle,
    required int count,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: count > 0 ? onDecrement : null,
          ),
          Text(
            '$count명',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onIncrement,
          ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFinancialAssetDeduction() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('금융재산 상속공제'),
              subtitle: const Text('순금융재산의 20% (최대 2억원)'),
              value: _isFinancialAssetDeduction,
              onChanged: (value) {
                setState(() {
                  _isFinancialAssetDeduction = value;
                });
              },
            ),
            if (_isFinancialAssetDeduction) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TaxInputField(
                  controller: _financialAssetsController,
                  label: '순금융재산',
                  hint: '금융재산 - 금융부채',
                  prefixIcon: Icons.account_balance_wallet,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHousingDeduction() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('동거주택 상속공제'),
              subtitle: const Text('10년 이상 동거, 최대 6억원'),
              value: _hasHousingDeduction,
              onChanged: (value) {
                setState(() {
                  _hasHousingDeduction = value;
                });
              },
            ),
            if (_hasHousingDeduction) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TaxInputField(
                  controller: _housingValueController,
                  label: '동거주택 가액',
                  hint: '주택 상속가액',
                  prefixIcon: Icons.home,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReinheritanceDeduction() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('단기 재상속 공제'),
              subtitle: const Text('10년 내 재상속 시 공제'),
              value: _hasReinheritance,
              onChanged: (value) {
                setState(() {
                  _hasReinheritance = value;
                });
              },
            ),
            if (_hasReinheritance) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  children: [
                    TaxInputField(
                      controller: _reinheritanceValueController,
                      label: '전 상속세액',
                      hint: '이전 상속 시 납부한 세액',
                      prefixIcon: Icons.receipt,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        const Text('재상속 경과 기간:'),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _reinheritanceYears,
                          items: List.generate(11, (index) {
                            return DropdownMenuItem(
                              value: index,
                              child: Text('$index년'),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              _reinheritanceYears = value ?? 0;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '공제율: ${(ReinheritanceDeduction.getDeductionRate(_reinheritanceYears) * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final details = _result!.details;

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF5D4037),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '상속세 계산 결과',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 납부세액
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '납부할 상속세',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    Text(
                      _result!.calculatedTax.toAutoUnit,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                  ],
                ),
                const Divider(height: 32),

                // 상세 내역
                SimpleResultRow(
                  label: '상속재산 총액',
                  value: _result!.totalIncome.toCurrencyWithUnit,
                ),
                SimpleResultRow(
                  label: '채무 및 비용',
                  value:
                      '-${(details['debtsAndExpenses'] as double).toCurrencyWithUnit}',
                  valueColor: Colors.blue[700],
                ),
                SimpleResultRow(
                  label: '상속공제 합계',
                  value:
                      '-${(details['totalDeductions'] as double).toCurrencyWithUnit}',
                  valueColor: Colors.blue[700],
                ),
                const Divider(),
                SimpleResultRow(
                  label: '과세표준',
                  value: _result!.taxableIncome.toCurrencyWithUnit,
                  isBold: true,
                ),
                SimpleResultRow(
                  label: '산출세액',
                  value: _result!.calculatedTax.toCurrencyWithUnit,
                  valueColor: Colors.red[700],
                  isBold: true,
                ),

                const SizedBox(height: 16),

                // 공제 상세
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5D4037).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '공제 상세',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      _buildDeductionDetail(
                          '기초공제', details['basicDeduction'] as double),
                      if (details['spouseDeduction'] as double > 0)
                        _buildDeductionDetail(
                            '배우자공제', details['spouseDeduction'] as double),
                      if (details['childDeduction'] as double > 0)
                        _buildDeductionDetail(
                            '자녀공제', details['childDeduction'] as double),
                      if (details['financialDeduction'] as double > 0)
                        _buildDeductionDetail(
                            '금융재산공제', details['financialDeduction'] as double),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionDetail(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value.toCurrencyWithUnit,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRateTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '상속세 세율표',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '과세표준',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '세율',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '누진공제',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                _buildRateRow('1억원 이하', '10%', '-'),
                _buildRateRow('1억~5억원', '20%', '1천만원'),
                _buildRateRow('5억~10억원', '30%', '6천만원'),
                _buildRateRow('10억~30억원', '40%', '1억6천만원'),
                _buildRateRow('30억원 초과', '50%', '4억6천만원'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRateRow(String bracket, String rate, String deduction) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(bracket),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            rate,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            deduction,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildReinheritanceTable() {
    final rateTable = ReinheritanceDeduction.getRateTable();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '단기 재상속 공제율',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(
                color: Colors.grey[300]!,
                width: 1,
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '경과 기간',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '공제율',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                ...rateTable.map((item) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item['years'] as String),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${((item['rate'] as double) * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
