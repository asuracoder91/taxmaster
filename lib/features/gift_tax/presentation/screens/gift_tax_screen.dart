import 'package:flutter/material.dart';

import '../../../../core/constants/deduction_rates.dart';
import '../../../../core/constants/tax_rates.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/tax_calculator_utils.dart';
import '../../../../shared/widgets/tax_input_field.dart';
import '../../../../shared/widgets/tax_result_card.dart';

/// 증여세 계산 화면
class GiftTaxScreen extends StatefulWidget {
  const GiftTaxScreen({super.key});

  @override
  State<GiftTaxScreen> createState() => _GiftTaxScreenState();
}

class _GiftTaxScreenState extends State<GiftTaxScreen> {
  final _formKey = GlobalKey<FormState>();

  final _giftValueController = TextEditingController();

  // 증여자 관계
  GiftRelation _selectedRelation = GiftRelation.spouse;

  // 10년 내 증여 합산
  bool _hasPreviousGifts = false;
  final _previousGiftsController = TextEditingController();

  TaxCalculationResult? _result;

  @override
  void dispose() {
    _giftValueController.dispose();
    _previousGiftsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final giftValue =
        NumberFormatter.parseNumber(_giftValueController.text) ?? 0;
    final previousGifts =
        NumberFormatter.parseNumber(_previousGiftsController.text) ?? 0;

    final result = TaxCalculatorUtils.calculateGiftTax(
      giftValue: giftValue,
      relation: _selectedRelation,
      previousGiftsIn10Years: _hasPreviousGifts ? previousGifts : 0,
    );

    setState(() {
      _result = result;
    });
  }

  void _reset() {
    _giftValueController.clear();
    _previousGiftsController.clear();

    setState(() {
      _selectedRelation = GiftRelation.spouse;
      _hasPreviousGifts = false;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('증여세 계산'),
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
              // 증여재산 입력
              _buildSectionTitle('증여재산'),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _giftValueController,
                label: '증여재산 가액',
                hint: '증여받은 재산의 시가',
                prefixIcon: Icons.card_giftcard,
                required: true,
              ),

              const SizedBox(height: 24),

              // 증여자 관계
              _buildSectionTitle('증여자와의 관계'),
              const SizedBox(height: 12),
              _buildRelationSelector(),

              const SizedBox(height: 24),

              // 10년 내 증여
              _buildPreviousGifts(),

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

              // 공제한도표
              _buildDeductionTable(),

              const SizedBox(height: 16),

              // 세율표
              _buildRateTable(),
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

  Widget _buildRelationSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: GiftRelation.values.map((relation) {
            final deduction = GiftTaxDeduction.getDeductionLimit(relation);
            return RadioListTile<GiftRelation>(
              title: Text(_getRelationName(relation)),
              subtitle: Text('공제한도: ${deduction.toCurrencyWithUnit}'),
              value: relation,
              groupValue: _selectedRelation,
              onChanged: (value) {
                setState(() {
                  _selectedRelation = value!;
                });
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getRelationName(GiftRelation relation) {
    switch (relation) {
      case GiftRelation.spouse:
        return '배우자';
      case GiftRelation.directDescendantAdult:
        return '직계비속 (성년)';
      case GiftRelation.directDescendantMinor:
        return '직계비속 (미성년)';
      case GiftRelation.directAscendant:
        return '직계존속';
      case GiftRelation.other:
        return '기타친족';
    }
  }

  Widget _buildPreviousGifts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('10년 내 증여 합산'),
              subtitle: const Text('동일인에게 받은 증여 합산'),
              value: _hasPreviousGifts,
              onChanged: (value) {
                setState(() {
                  _hasPreviousGifts = value;
                });
              },
            ),
            if (_hasPreviousGifts) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TaxInputField(
                  controller: _previousGiftsController,
                  label: '10년 내 증여 합계',
                  hint: '이전 증여받은 재산 합계',
                  prefixIcon: Icons.history,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '동일인으로부터 10년 이내 받은 증여재산은 합산하여 과세됩니다.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
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
              color: Color(0xFFE91E63),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '증여세 계산 결과',
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
                      '납부할 증여세',
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
                  label: '증여재산 가액',
                  value: _result!.totalIncome.toCurrencyWithUnit,
                ),
                if (_hasPreviousGifts)
                  SimpleResultRow(
                    label: '10년 내 증여 합산',
                    value:
                        '+${(details['previousGifts'] as double).toCurrencyWithUnit}',
                    valueColor: Colors.orange[700],
                  ),
                SimpleResultRow(
                  label: '증여공제',
                  value:
                      '-${(details['giftDeduction'] as double).toCurrencyWithUnit}',
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
                  value: (details['calculatedTax'] as double).toCurrencyWithUnit,
                ),
                if (_hasPreviousGifts &&
                    (details['previousTaxPaid'] as double) > 0)
                  SimpleResultRow(
                    label: '기납부세액 공제',
                    value:
                        '-${(details['previousTaxPaid'] as double).toCurrencyWithUnit}',
                    valueColor: Colors.blue[700],
                  ),
                SimpleResultRow(
                  label: '납부할 세액',
                  value: _result!.calculatedTax.toCurrencyWithUnit,
                  valueColor: Colors.red[700],
                  isBold: true,
                ),

                const SizedBox(height: 16),

                // 적용세율 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '실효세율',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _result!.effectiveRate.toPercent,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE91E63),
                                ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFFE91E63).withOpacity(0.3),
                      ),
                      Column(
                        children: [
                          Text(
                            '한계세율',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _result!.marginalRate.toPercent,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE91E63),
                                ),
                          ),
                        ],
                      ),
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

  Widget _buildDeductionTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '증여세 공제한도 (10년간 합산)',
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
                1: FlexColumnWidth(1.5),
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
                        '증여자',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '공제한도',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                _buildDeductionRow('배우자', '6억원'),
                _buildDeductionRow('직계존속 (성년자 수증)', '5천만원'),
                _buildDeductionRow('직계존속 (미성년자 수증)', '2천만원'),
                _buildDeductionRow('직계비속', '5천만원'),
                _buildDeductionRow('기타친족', '1천만원'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildDeductionRow(String relation, String limit) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(relation),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            limit,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
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
              '증여세 세율표',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '* 상속세와 동일한 세율 적용',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
}
