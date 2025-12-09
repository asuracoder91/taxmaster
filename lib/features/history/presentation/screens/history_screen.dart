import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';

/// 계산 기록 화면
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 임시 데이터 - 실제로는 Hive에서 로드
  final List<CalculationHistory> _histories = [
    CalculationHistory(
      id: '1',
      type: TaxType.income,
      title: '종합소득세',
      totalIncome: 80000000,
      calculatedTax: 12864000,
      effectiveRate: 0.1608,
      calculatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    CalculationHistory(
      id: '2',
      type: TaxType.corporate,
      title: '법인세',
      totalIncome: 500000000,
      calculatedTax: 74800000,
      effectiveRate: 0.1496,
      calculatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    CalculationHistory(
      id: '3',
      type: TaxType.capitalGains,
      title: '양도소득세',
      totalIncome: 200000000,
      calculatedTax: 32000000,
      effectiveRate: 0.16,
      calculatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  TaxType? _selectedFilter;

  List<CalculationHistory> get _filteredHistories {
    if (_selectedFilter == null) return _histories;
    return _histories.where((h) => h.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('계산 기록'),
        actions: [
          PopupMenuButton<TaxType?>(
            icon: const Icon(Icons.filter_list),
            tooltip: '필터',
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('전체'),
              ),
              const PopupMenuItem(
                value: TaxType.income,
                child: Text('종합소득세'),
              ),
              const PopupMenuItem(
                value: TaxType.corporate,
                child: Text('법인세'),
              ),
              const PopupMenuItem(
                value: TaxType.capitalGains,
                child: Text('양도소득세'),
              ),
              const PopupMenuItem(
                value: TaxType.inheritance,
                child: Text('상속세'),
              ),
              const PopupMenuItem(
                value: TaxType.gift,
                child: Text('증여세'),
              ),
              const PopupMenuItem(
                value: TaxType.retirement,
                child: Text('퇴직소득세'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _histories.isNotEmpty ? _showClearDialog : null,
            tooltip: '전체 삭제',
          ),
        ],
      ),
      body: _filteredHistories.isEmpty
          ? _buildEmptyState()
          : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '계산 기록이 없습니다',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '세금 계산을 하면 여기에 기록됩니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // 날짜별로 그룹화
    final Map<String, List<CalculationHistory>> groupedHistories = {};

    for (final history in _filteredHistories) {
      final dateKey = _getDateKey(history.calculatedAt);
      groupedHistories.putIfAbsent(dateKey, () => []).add(history);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedHistories.length,
      itemBuilder: (context, index) {
        final dateKey = groupedHistories.keys.elementAt(index);
        final histories = groupedHistories[dateKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                dateKey,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...histories.map((history) => _buildHistoryCard(history)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final historyDate = DateTime(date.year, date.month, date.day);

    if (historyDate == today) {
      return '오늘';
    } else if (historyDate == yesterday) {
      return '어제';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  Widget _buildHistoryCard(CalculationHistory history) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showHistoryDetail(history),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTaxTypeColor(history.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTaxTypeIcon(history.type),
                  color: _getTaxTypeColor(history.type),
                ),
              ),
              const SizedBox(width: 16),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '총소득: ${history.totalIncome.toCurrencyWithUnit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),

              // 세액
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    history.calculatedTax.toAutoUnit,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '실효세율 ${history.effectiveRate.toPercent}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTaxTypeColor(TaxType type) {
    switch (type) {
      case TaxType.income:
        return const Color(0xFF1976D2);
      case TaxType.corporate:
        return const Color(0xFF7B1FA2);
      case TaxType.capitalGains:
        return const Color(0xFF00796B);
      case TaxType.inheritance:
        return const Color(0xFF5D4037);
      case TaxType.gift:
        return const Color(0xFFE91E63);
      case TaxType.retirement:
        return const Color(0xFF795548);
    }
  }

  IconData _getTaxTypeIcon(TaxType type) {
    switch (type) {
      case TaxType.income:
        return Icons.person;
      case TaxType.corporate:
        return Icons.business;
      case TaxType.capitalGains:
        return Icons.real_estate_agent;
      case TaxType.inheritance:
        return Icons.family_restroom;
      case TaxType.gift:
        return Icons.card_giftcard;
      case TaxType.retirement:
        return Icons.elderly;
    }
  }

  void _showHistoryDetail(CalculationHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 헤더
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _getTaxTypeColor(history.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getTaxTypeIcon(history.type),
                      color: _getTaxTypeColor(history.type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        history.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        _formatDateTime(history.calculatedAt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 결과 요약
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getTaxTypeColor(history.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '총소득',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          history.totalIncome.toCurrencyWithUnit,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '산출세액',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          history.calculatedTax.toCurrencyWithUnit,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '실효세율',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          history.effectiveRate.toPercent,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getTaxTypeColor(history.type),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteHistory(history);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('삭제'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // 해당 세금 계산 화면으로 이동
                        _navigateToCalculator(history.type);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('다시 계산'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _deleteHistory(CalculationHistory history) {
    setState(() {
      _histories.removeWhere((h) => h.id == history.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('기록이 삭제되었습니다')),
    );
  }

  void _navigateToCalculator(TaxType type) {
    // GoRouter를 사용하여 이동 (향후 구현)
    // ignore: unused_local_variable
    final route = switch (type) {
      TaxType.income => '/income-tax',
      TaxType.corporate => '/corporate-tax',
      TaxType.capitalGains => '/capital-gains-tax',
      TaxType.inheritance => '/inheritance-tax',
      TaxType.gift => '/gift-tax',
      TaxType.retirement => '/retirement-income',
    };
    // context.go(route);
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 삭제'),
        content: const Text('모든 계산 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _histories.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('모든 기록이 삭제되었습니다')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// 세금 유형 enum
enum TaxType {
  income,
  corporate,
  capitalGains,
  inheritance,
  gift,
  retirement,
}

// 계산 기록 모델
class CalculationHistory {
  final String id;
  final TaxType type;
  final String title;
  final double totalIncome;
  final double calculatedTax;
  final double effectiveRate;
  final DateTime calculatedAt;
  final Map<String, dynamic>? details;

  CalculationHistory({
    required this.id,
    required this.type,
    required this.title,
    required this.totalIncome,
    required this.calculatedTax,
    required this.effectiveRate,
    required this.calculatedAt,
    this.details,
  });
}
