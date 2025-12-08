import 'package:flutter/material.dart';

import '../../core/utils/number_formatter.dart';
import '../../core/utils/tax_calculator_utils.dart';

/// 세금 계산 결과 카드 위젯
class TaxResultCard extends StatelessWidget {
  final TaxCalculationResult result;
  final String? title;
  final Color? accentColor;

  const TaxResultCard({
    super.key,
    required this.result,
    this.title,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;

    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              title ?? '계산 결과',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 결과 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 주요 결과
                _buildMainResult(context),
                const Divider(height: 32),

                // 상세 내역
                _buildDetailRows(context),

                const SizedBox(height: 16),

                // 실효세율
                _buildEffectiveRate(context, color),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResult(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '납부할 세금',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.calculatedTax.toAutoUnit,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '세후 금액',
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.netIncome.toAutoUnit,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRows(BuildContext context) {
    return Column(
      children: [
        _ResultRow(
          label: '총소득',
          value: result.totalIncome.toCurrencyWithUnit,
        ),
        const SizedBox(height: 8),
        _ResultRow(
          label: '공제합계',
          value: '-${result.deductions.toCurrencyWithUnit}',
          valueColor: Colors.blue[700],
        ),
        const SizedBox(height: 8),
        _ResultRow(
          label: '과세표준',
          value: result.taxableIncome.toCurrencyWithUnit,
          isBold: true,
        ),
        const SizedBox(height: 8),
        _ResultRow(
          label: '산출세액',
          value: result.calculatedTax.toCurrencyWithUnit,
          valueColor: Colors.red[700],
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildEffectiveRate(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RateInfo(
            label: '실효세율',
            value: result.effectiveRate.toPercent,
          ),
          Container(
            width: 1,
            height: 40,
            color: color.withOpacity(0.3),
          ),
          _RateInfo(
            label: '한계세율',
            value: result.marginalRate.toPercent,
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _RateInfo extends StatelessWidget {
  final String label;
  final String value;

  const _RateInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// 간단한 결과 행 위젯
class SimpleResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;
  final bool isBold;

  const SimpleResultRow({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: labelColor ?? Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
