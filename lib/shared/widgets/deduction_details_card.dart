import 'package:flutter/material.dart';

import '../../core/utils/number_formatter.dart';
import '../models/deduction_item.dart';

/// 공제 상세내역 카드 위젯
///
/// 세금 계산 시 적용된 공제 항목별 금액과 계산식을 표시합니다.
/// 항상 펼쳐진 상태로 모든 공제 항목을 보여줍니다.
class DeductionDetailsCard extends StatelessWidget {
  /// 공제 상세 정보
  final DeductionDetails details;

  /// 카드 제목 (기본값: "공제 상세내역")
  final String title;

  /// 세금 유형별 테마 색상
  final Color? accentColor;

  const DeductionDetailsCard({
    super.key,
    required this.details,
    this.title = '공제 상세내역',
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    // 유효한 공제 항목이 없으면 표시하지 않음
    if (!details.hasItems || details.totalAmount <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final color = accentColor ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.3 : 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: color,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // 공제 항목 목록
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 개별 공제 항목
                ...details.validItems.map(
                  (item) => _DeductionItemRow(item: item),
                ),

                const Divider(height: 24),

                // 공제 합계
                _TotalRow(totalAmount: details.totalAmount),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 개별 공제 항목 행 위젯
class _DeductionItemRow extends StatelessWidget {
  final DeductionItem item;

  const _DeductionItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 메인 행: 항목명 + 금액
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 항목 정보 (좌측)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 항목명
                    Text(
                      item.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    // 계산식
                    if (item.formula != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey[800]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.formula!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            color: isDark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],

                    // 부가 설명
                    if (item.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 금액 (우측)
              Text(
                '-${item.amount.toAutoUnit}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),

          // 하위 항목 (들여쓰기)
          if (item.hasSubItems) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: item.subItems!
                    .where((sub) => sub.hasAmount)
                    .map((sub) => _SubItemRow(item: sub))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 하위 공제 항목 행 위젯
class _SubItemRow extends StatelessWidget {
  final DeductionItem item;

  const _SubItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 들여쓰기 표시
          Text(
            '└ ',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),

          // 항목 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                if (item.formula != null)
                  Text(
                    item.formula!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: isDark ? Colors.grey[400] : Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),

          // 금액
          Text(
            '-${item.amount.toAutoUnit}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// 공제 합계 행 위젯
class _TotalRow extends StatelessWidget {
  final double totalAmount;

  const _TotalRow({required this.totalAmount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '공제 합계',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '-${totalAmount.toAutoUnit}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    );
  }
}
