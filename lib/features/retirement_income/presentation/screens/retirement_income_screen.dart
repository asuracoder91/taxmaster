import 'package:flutter/material.dart';

import '../../../../core/constants/deduction_rates.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../core/utils/tax_calculator_utils.dart';
import '../../../../shared/widgets/tax_input_field.dart';
import '../../../../shared/widgets/tax_result_card.dart';

/// 퇴직소득세 계산 화면
class RetirementIncomeScreen extends StatefulWidget {
  const RetirementIncomeScreen({super.key});

  @override
  State<RetirementIncomeScreen> createState() => _RetirementIncomeScreenState();
}

class _RetirementIncomeScreenState extends State<RetirementIncomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _retirementPayController = TextEditingController();
  final _serviceYearsController = TextEditingController();
  final _serviceMonthsController = TextEditingController();

  TaxCalculationResult? _result;

  @override
  void dispose() {
    _retirementPayController.dispose();
    _serviceYearsController.dispose();
    _serviceMonthsController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final retirementPay =
        NumberFormatter.parseNumber(_retirementPayController.text) ?? 0;
    final years = int.tryParse(_serviceYearsController.text) ?? 0;
    final months = int.tryParse(_serviceMonthsController.text) ?? 0;

    final result = TaxCalculatorUtils.calculateRetirementIncomeTax(
      retirementPay: retirementPay,
      serviceYears: years,
      serviceMonths: months,
    );

    setState(() {
      _result = result;
    });
  }

  void _reset() {
    _retirementPayController.clear();
    _serviceYearsController.clear();
    _serviceMonthsController.clear();

    setState(() {
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퇴직소득세 계산'),
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
              // 퇴직금 입력
              _buildSectionTitle('퇴직금 정보'),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _retirementPayController,
                label: '퇴직급여',
                hint: '퇴직금 총액',
                prefixIcon: Icons.account_balance_wallet,
                required: true,
              ),

              const SizedBox(height: 24),

              // 근속연수 입력
              _buildSectionTitle('근속기간'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: YearsInputField(
                      controller: _serviceYearsController,
                      label: '근속연수',
                      hint: '근무 연수',
                      prefixIcon: Icons.calendar_today,
                      required: true,
                      maxYears: 50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _serviceMonthsController,
                      decoration: const InputDecoration(
                        labelText: '추가 월수',
                        hintText: '0~11',
                        prefixIcon: Icon(Icons.date_range),
                        suffixText: '개월',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final months = int.tryParse(value);
                          if (months == null || months < 0 || months > 11) {
                            return '0~11 사이';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 근속연수 계산 팁
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
                        '근속연수 = 입사일 ~ 퇴직일까지의 기간\n1년 미만 단수는 1년으로 계산',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
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

              // 근속연수공제표
              _buildServiceDeductionTable(),

              const SizedBox(height: 16),

              // 환산급여 공제표
              _buildConversionDeductionTable(),

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
              color: Color(0xFF795548),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              '퇴직소득세 계산 결과',
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '납부할 세금',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _result!.calculatedTax.toAutoUnit,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '세후 퇴직금',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _result!.netIncome.toAutoUnit,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[700],
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 32),

                // 상세 내역
                SimpleResultRow(
                  label: '퇴직급여',
                  value: _result!.totalIncome.toCurrencyWithUnit,
                ),
                SimpleResultRow(
                  label: '근속연수공제',
                  value:
                      '-${(details['serviceDeduction'] as double).toCurrencyWithUnit}',
                  valueColor: Colors.blue[700],
                ),
                SimpleResultRow(
                  label: '환산급여',
                  value:
                      (details['convertedIncome'] as double).toCurrencyWithUnit,
                ),
                SimpleResultRow(
                  label: '환산급여공제',
                  value:
                      '-${(details['convertedDeduction'] as double).toCurrencyWithUnit}',
                  valueColor: Colors.blue[700],
                ),
                const Divider(),
                SimpleResultRow(
                  label: '퇴직소득과세표준',
                  value:
                      (details['taxableConverted'] as double).toCurrencyWithUnit,
                ),
                SimpleResultRow(
                  label: '환산산출세액',
                  value:
                      (details['convertedTax'] as double).toCurrencyWithUnit,
                ),
                const Divider(),
                SimpleResultRow(
                  label: '산출세액',
                  value: _result!.calculatedTax.toCurrencyWithUnit,
                  valueColor: Colors.red[700],
                  isBold: true,
                ),

                const SizedBox(height: 16),

                // 계산 상세
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF795548).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '계산 과정',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildCalculationStep(
                        '1. 퇴직소득금액',
                        '퇴직급여 - 비과세소득',
                        _result!.totalIncome.toCurrencyWithUnit,
                      ),
                      _buildCalculationStep(
                        '2. 근속연수공제',
                        '근속연수에 따른 공제',
                        (details['serviceDeduction'] as double)
                            .toCurrencyWithUnit,
                      ),
                      _buildCalculationStep(
                        '3. 환산급여',
                        '(퇴직소득금액 - 근속연수공제) ÷ 근속연수 × 12',
                        (details['convertedIncome'] as double)
                            .toCurrencyWithUnit,
                      ),
                      _buildCalculationStep(
                        '4. 환산급여공제',
                        '환산급여 구간별 공제',
                        (details['convertedDeduction'] as double)
                            .toCurrencyWithUnit,
                      ),
                      _buildCalculationStep(
                        '5. 퇴직소득과세표준',
                        '환산급여 - 환산급여공제',
                        (details['taxableConverted'] as double)
                            .toCurrencyWithUnit,
                      ),
                      _buildCalculationStep(
                        '6. 산출세액',
                        '환산산출세액 ÷ 12 × 근속연수',
                        _result!.calculatedTax.toCurrencyWithUnit,
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

  Widget _buildCalculationStep(String step, String formula, String result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                step,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                result,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            formula,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDeductionTable() {
    final deductionTable = RetirementServiceDeduction.getDeductionTable();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '근속연수공제',
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
                        '근속연수',
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
                ...deductionTable.map((item) {
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item['years'] as String),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item['deduction'] as String),
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

  Widget _buildConversionDeductionTable() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '환산급여 공제',
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
                        '환산급여',
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
                _buildConversionRow('8백만원 이하', '전액'),
                _buildConversionRow('8백만~7천만원', '800만 + (초과 × 60%)'),
                _buildConversionRow('7천만~1억원', '4,520만 + (초과 × 55%)'),
                _buildConversionRow('1억~3억원', '6,170만 + (초과 × 45%)'),
                _buildConversionRow('3억원 초과', '15,170만 + (초과 × 35%)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildConversionRow(String income, String deduction) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(income),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(deduction),
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
              '퇴직소득 세율표',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '* 종합소득세 기본세율 적용',
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
                _buildRateRow('1,400만원 이하', '6%', '-'),
                _buildRateRow('1,400~5,000만원', '15%', '126만원'),
                _buildRateRow('5,000~8,800만원', '24%', '576만원'),
                _buildRateRow('8,800~1.5억원', '35%', '1,544만원'),
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
}
