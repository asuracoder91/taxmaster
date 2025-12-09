import 'package:flutter/material.dart';

import '../../../../core/utils/tax_calculator_utils.dart';
import '../../../../shared/widgets/tax_input_field.dart';
import '../../../../shared/widgets/tax_result_card.dart';

/// 법인세 계산 화면
class CorporateTaxScreen extends StatefulWidget {
  const CorporateTaxScreen({super.key});

  @override
  State<CorporateTaxScreen> createState() => _CorporateTaxScreenState();
}

class _CorporateTaxScreenState extends State<CorporateTaxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taxableIncomeController = TextEditingController();

  TaxCalculationResult? _result;

  @override
  void dispose() {
    _taxableIncomeController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    // 만원 단위 입력을 원 단위로 변환
    final taxableIncome = TaxInputField.getValueInWon(_taxableIncomeController);

    final result = TaxCalculatorUtils.calculateCorporateTax(
      taxableIncome: taxableIncome,
    );

    setState(() {
      _result = result;
    });
  }

  void _reset() {
    _taxableIncomeController.clear();
    setState(() {
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('법인세 계산'),
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
              // 입력 섹션
              Text(
                '과세표준 입력',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12),
              TaxInputField(
                controller: _taxableIncomeController,
                label: '과세표준',
                hint: '법인 과세표준금액',
                prefixIcon: Icons.business,
                required: true,
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
                TaxResultCard(
                  result: _result!,
                  title: '법인세 계산 결과',
                  accentColor: const Color(0xFF7B1FA2),
                ),
              ],

              const SizedBox(height: 24),

              // 세율표
              _buildRateTable(),
            ],
          ),
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
              '법인세 세율표 (2025년)',
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
                  ],
                ),
                _buildRateRow('2억원 이하', '9%'),
                _buildRateRow('2억원 초과 ~ 200억원 이하', '19%'),
                _buildRateRow('200억원 초과 ~ 3,000억원 이하', '21%'),
                _buildRateRow('3,000억원 초과', '24%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildRateRow(String bracket, String rate) {
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
      ],
    );
  }
}
