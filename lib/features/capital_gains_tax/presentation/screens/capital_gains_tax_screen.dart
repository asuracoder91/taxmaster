import 'package:flutter/material.dart';

import '../../../../core/constants/deduction_rates.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/tax_calculator_utils.dart';
import '../../../../shared/widgets/tax_input_field.dart';
import '../../../../shared/widgets/tax_result_card.dart';

/// 양도소득세 계산 화면
class CapitalGainsTaxScreen extends StatefulWidget {
  const CapitalGainsTaxScreen({super.key});

  @override
  State<CapitalGainsTaxScreen> createState() => _CapitalGainsTaxScreenState();
}

class _CapitalGainsTaxScreenState extends State<CapitalGainsTaxScreen> {
  final _formKey = GlobalKey<FormState>();

  final _acquisitionPriceController = TextEditingController();
  final _transferPriceController = TextEditingController();
  final _expensesController = TextEditingController();
  final _holdingYearsController = TextEditingController();
  final _residenceYearsController = TextEditingController();

  bool _isOneHouseOneFamily = false;

  TaxCalculationResult? _result;

  @override
  void dispose() {
    _acquisitionPriceController.dispose();
    _transferPriceController.dispose();
    _expensesController.dispose();
    _holdingYearsController.dispose();
    _residenceYearsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    // 만원 단위 입력을 원 단위로 변환
    final acquisitionPrice = TaxInputField.getValueInWon(_acquisitionPriceController);
    final transferPrice = TaxInputField.getValueInWon(_transferPriceController);
    final expenses = TaxInputField.getValueInWon(_expensesController);
    final holdingYears = int.tryParse(_holdingYearsController.text) ?? 0;
    final residenceYears = int.tryParse(_residenceYearsController.text) ?? 0;

    final result = TaxCalculatorUtils.calculateCapitalGainsTax(
      acquisitionPrice: acquisitionPrice,
      transferPrice: transferPrice,
      expenses: expenses,
      holdingYears: holdingYears,
      isOneHouseOneFamily: _isOneHouseOneFamily,
      residenceYears: residenceYears,
    );

    setState(() {
      _result = result;
    });
  }

  void _reset() {
    _acquisitionPriceController.clear();
    _transferPriceController.clear();
    _expensesController.clear();
    _holdingYearsController.clear();
    _residenceYearsController.clear();

    setState(() {
      _isOneHouseOneFamily = false;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('양도소득세 계산'),
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
              // 양도 정보
              _buildSectionTitle('양도 정보'),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _acquisitionPriceController,
                label: '취득가액',
                hint: '부동산 취득 시 가격',
                prefixIcon: Icons.shopping_cart,
                required: true,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _transferPriceController,
                label: '양도가액',
                hint: '부동산 양도(매도) 가격',
                prefixIcon: Icons.sell,
                required: true,
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _expensesController,
                label: '필요경비',
                hint: '취득세, 중개수수료 등',
                prefixIcon: Icons.receipt_long,
              ),

              const SizedBox(height: 24),

              // 보유 정보
              _buildSectionTitle('보유 정보'),
              const SizedBox(height: 12),
              YearsInputField(
                controller: _holdingYearsController,
                label: '보유기간',
                hint: '보유 연수',
                prefixIcon: Icons.calendar_today,
                required: true,
                maxYears: 100,
              ),

              const SizedBox(height: 16),

              // 1세대 1주택 옵션
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('1세대 1주택'),
                        subtitle: const Text('거주기간 공제 추가 적용'),
                        value: _isOneHouseOneFamily,
                        onChanged: (value) {
                          setState(() {
                            _isOneHouseOneFamily = value;
                          });
                        },
                      ),
                      if (_isOneHouseOneFamily) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: YearsInputField(
                            controller: _residenceYearsController,
                            label: '실제 거주기간',
                            hint: '거주 연수',
                            prefixIcon: Icons.home,
                            maxYears: 100,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

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

              // 양도소득세 세율표
              _buildRateTable(),

              const SizedBox(height: 16),

              // 장기보유특별공제율 표
              _buildLongTermDeductionTable(),
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
              color: Color(0xFF00796B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '양도소득세 계산 결과',
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
                      '납부할 세금',
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
                  label: '양도차익',
                  value: (details['capitalGain'] as double).toCurrencyWithUnit,
                ),
                SimpleResultRow(
                  label: '장기보유특별공제율',
                  value:
                      '${((details['longTermDeductionRate'] as double) * 100).toStringAsFixed(0)}%',
                  valueColor: Colors.blue[700],
                ),
                SimpleResultRow(
                  label: '장기보유특별공제액',
                  value:
                      '-${(details['longTermDeduction'] as double).toCurrencyWithUnit}',
                  valueColor: Colors.blue[700],
                ),
                SimpleResultRow(
                  label: '기본공제',
                  value:
                      '-${(details['basicDeduction'] as double).toCurrencyWithUnit}',
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

                // 세율 정보
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00796B).withOpacity(0.1),
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
                                  color: const Color(0xFF00796B),
                                ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFF00796B).withOpacity(0.3),
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
                                  color: const Color(0xFF00796B),
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

  Widget _buildRateTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '양도소득세 세율표 (2025년)',
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
                _buildTaxRateRow('1,400만원 이하', '6%', '-'),
                _buildTaxRateRow('1,400~5,000만원', '15%', '126만원'),
                _buildTaxRateRow('5,000~8,800만원', '24%', '576만원'),
                _buildTaxRateRow('8,800만원~1.5억원', '35%', '1,544만원'),
                _buildTaxRateRow('1.5억~3억원', '38%', '1,994만원'),
                _buildTaxRateRow('3억~5억원', '40%', '2,594만원'),
                _buildTaxRateRow('5억~10억원', '42%', '3,594만원'),
                _buildTaxRateRow('10억원 초과', '45%', '6,594만원'),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '특별세율',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSpecialRateItem('1년 미만 보유 (주택)', '70%'),
                  _buildSpecialRateItem('1~2년 보유 (주택)', '60%'),
                  _buildSpecialRateItem('비사업용 토지', '60%'),
                  _buildSpecialRateItem('미등기 양도', '70%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTaxRateRow(String bracket, String rate, String deduction) {
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

  Widget _buildSpecialRateItem(String label, String rate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(
            rate,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLongTermDeductionTable() {
    final rateTable = LongTermHoldingDeduction.getRateTable();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '장기보유특별공제율',
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
                        '보유기간',
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
