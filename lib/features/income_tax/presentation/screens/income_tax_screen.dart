import 'package:flutter/material.dart';

import '../../../../core/utils/tax_calculator_utils.dart';
import '../../../../shared/widgets/tax_input_field.dart';
import '../../../../shared/widgets/tax_result_card.dart';

/// 종합소득세 계산 화면
class IncomeTaxScreen extends StatefulWidget {
  const IncomeTaxScreen({super.key});

  @override
  State<IncomeTaxScreen> createState() => _IncomeTaxScreenState();
}

class _IncomeTaxScreenState extends State<IncomeTaxScreen> {
  final _formKey = GlobalKey<FormState>();

  // 소득 입력 컨트롤러
  final _earnedIncomeController = TextEditingController();
  final _businessIncomeController = TextEditingController();
  final _interestIncomeController = TextEditingController();
  final _dividendIncomeController = TextEditingController();
  final _pensionIncomeController = TextEditingController();
  final _otherIncomeController = TextEditingController();

  // 공제 관련
  int _dependents = 0;
  bool _hasSpouse = false;
  int _elderlyCount = 0;
  int _disabledCount = 0;
  bool _isWomanDeductionEligible = false;
  bool _isSingleParent = false;

  // 계산 결과
  TaxCalculationResult? _result;

  @override
  void dispose() {
    _earnedIncomeController.dispose();
    _businessIncomeController.dispose();
    _interestIncomeController.dispose();
    _dividendIncomeController.dispose();
    _pensionIncomeController.dispose();
    _otherIncomeController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    // 만원 단위 입력을 원 단위로 변환
    final earnedIncome = TaxInputField.getValueInWon(_earnedIncomeController);
    final businessIncome = TaxInputField.getValueInWon(_businessIncomeController);
    final interestIncome = TaxInputField.getValueInWon(_interestIncomeController);
    final dividendIncome = TaxInputField.getValueInWon(_dividendIncomeController);
    final pensionIncome = TaxInputField.getValueInWon(_pensionIncomeController);
    final otherIncome = TaxInputField.getValueInWon(_otherIncomeController);

    final result = TaxCalculatorUtils.calculateIncomeTax(
      earnedIncome: earnedIncome,
      businessIncome: businessIncome,
      interestIncome: interestIncome,
      dividendIncome: dividendIncome,
      pensionIncome: pensionIncome,
      otherIncome: otherIncome,
      dependents: _dependents,
      hasSpouse: _hasSpouse,
      elderlyCount: _elderlyCount,
      disabledCount: _disabledCount,
      isWomanDeductionEligible: _isWomanDeductionEligible,
      isSingleParent: _isSingleParent,
    );

    setState(() {
      _result = result;
    });
  }

  void _reset() {
    _earnedIncomeController.clear();
    _businessIncomeController.clear();
    _interestIncomeController.clear();
    _dividendIncomeController.clear();
    _pensionIncomeController.clear();
    _otherIncomeController.clear();

    setState(() {
      _dependents = 0;
      _hasSpouse = false;
      _elderlyCount = 0;
      _disabledCount = 0;
      _isWomanDeductionEligible = false;
      _isSingleParent = false;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종합소득세 계산'),
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
              // 소득 입력 섹션
              _buildSectionTitle('소득 입력'),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _earnedIncomeController,
                label: '근로소득',
                hint: '연간 총급여액',
                prefixIcon: Icons.work,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _businessIncomeController,
                label: '사업소득',
                hint: '사업소득금액',
                prefixIcon: Icons.store,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _interestIncomeController,
                label: '이자소득',
                hint: '이자소득금액',
                prefixIcon: Icons.savings,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _dividendIncomeController,
                label: '배당소득',
                hint: '배당소득금액',
                prefixIcon: Icons.trending_up,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _pensionIncomeController,
                label: '연금소득',
                hint: '연금소득금액',
                prefixIcon: Icons.elderly,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _otherIncomeController,
                label: '기타소득',
                hint: '기타소득금액',
                prefixIcon: Icons.more_horiz,
              ),

              const SizedBox(height: 24),

              // 인적공제 섹션
              _buildSectionTitle('인적공제'),
              const SizedBox(height: 12),
              _buildDeductionOptions(),

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
                TaxResultCard(result: _result!),
              ],

              const SizedBox(height: 24),

              // 세율표
              _buildRateTable(),

              const SizedBox(height: 16),

              // 근로소득공제표
              _buildEarnedIncomeDeductionTable(),

              const SizedBox(height: 16),

              // 인적공제 참조표
              _buildPersonalDeductionTable(),
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
          children: [
            // 배우자 공제
            SwitchListTile(
              title: const Text('배우자 공제'),
              subtitle: const Text('150만원'),
              value: _hasSpouse,
              onChanged: (value) {
                setState(() {
                  _hasSpouse = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            // 부양가족 수
            ListTile(
              title: const Text('부양가족 수'),
              subtitle: const Text('1인당 150만원'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _dependents > 0
                        ? () => setState(() => _dependents--)
                        : null,
                  ),
                  Text(
                    '$_dependents명',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _dependents++),
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            // 경로우대 수
            ListTile(
              title: const Text('경로우대자 수'),
              subtitle: const Text('70세 이상, 1인당 100만원'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _elderlyCount > 0
                        ? () => setState(() => _elderlyCount--)
                        : null,
                  ),
                  Text(
                    '$_elderlyCount명',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _elderlyCount++),
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            // 장애인 수
            ListTile(
              title: const Text('장애인 수'),
              subtitle: const Text('1인당 200만원'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _disabledCount > 0
                        ? () => setState(() => _disabledCount--)
                        : null,
                  ),
                  Text(
                    '$_disabledCount명',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setState(() => _disabledCount++),
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),

            // 부녀자 공제
            SwitchListTile(
              title: const Text('부녀자 공제'),
              subtitle: const Text('50만원'),
              value: _isWomanDeductionEligible,
              onChanged: (value) {
                setState(() {
                  _isWomanDeductionEligible = value;
                  if (value) _isSingleParent = false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            // 한부모 공제
            SwitchListTile(
              title: const Text('한부모 공제'),
              subtitle: const Text('100만원'),
              value: _isSingleParent,
              onChanged: (value) {
                setState(() {
                  _isSingleParent = value;
                  if (value) _isWomanDeductionEligible = false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
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
              '종합소득세 세율표 (2025년)',
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
                _buildRateRow('1,400만원 이하', '6%', '-'),
                _buildRateRow('1,400~5,000만원', '15%', '126만원'),
                _buildRateRow('5,000~8,800만원', '24%', '576만원'),
                _buildRateRow('8,800만원~1.5억원', '35%', '1,544만원'),
                _buildRateRow('1.5억~3억원', '38%', '1,994만원'),
                _buildRateRow('3억~5억원', '40%', '2,594만원'),
                _buildRateRow('5억~10억원', '42%', '3,594만원'),
                _buildRateRow('10억원 초과', '45%', '6,594만원'),
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
          child: Text(bracket, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            rate,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            deduction,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildEarnedIncomeDeductionTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '근로소득공제',
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
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(2),
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
                        '총급여액',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '공제액',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                _buildDeductionRow('500만원 이하', '70%'),
                _buildDeductionRow('500만~1,500만원', '350만원 + (초과분×40%)'),
                _buildDeductionRow('1,500만~4,500만원', '750만원 + (초과분×15%)'),
                _buildDeductionRow('4,500만~1억원', '1,200만원 + (초과분×5%)'),
                _buildDeductionRow('1억원 초과', '1,475만원 + (초과분×2%)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildDeductionRow(String income, String deduction) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(income, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            deduction,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDeductionTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '인적공제 금액',
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
                        '구분',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '금액',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                _buildPersonalRow('기본공제 (본인)', '150만원'),
                _buildPersonalRow('배우자 공제', '150만원'),
                _buildPersonalRow('부양가족 (1인당)', '150만원'),
                _buildPersonalRow('경로우대 (70세 이상)', '100만원'),
                _buildPersonalRow('장애인', '200만원'),
                _buildPersonalRow('부녀자', '50만원'),
                _buildPersonalRow('한부모', '100만원'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '* 부녀자 공제와 한부모 공제는 중복 적용 불가',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildPersonalRow(String category, String amount) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(category, style: const TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            amount,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
