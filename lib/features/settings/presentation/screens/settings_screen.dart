import 'package:flutter/material.dart';

/// 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 설정 값들 - 실제로는 Hive에서 로드
  bool _isDarkMode = false;
  bool _saveHistory = true;
  bool _showTips = true;
  String _defaultTaxYear = '2025';
  String _numberFormat = 'korean'; // korean, full

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        children: [
          // 외관 설정
          _buildSectionHeader('외관'),
          SwitchListTile(
            title: const Text('다크 모드'),
            subtitle: const Text('어두운 테마 사용'),
            secondary: Icon(
              _isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // 테마 변경 로직
            },
          ),
          const Divider(height: 1),

          // 데이터 설정
          _buildSectionHeader('데이터'),
          SwitchListTile(
            title: const Text('계산 기록 저장'),
            subtitle: const Text('계산 결과를 자동으로 저장'),
            secondary: Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.primary,
            ),
            value: _saveHistory,
            onChanged: (value) {
              setState(() {
                _saveHistory = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('계산 기록 삭제'),
            subtitle: const Text('모든 계산 기록 삭제'),
            onTap: _showDeleteHistoryDialog,
          ),
          const Divider(height: 1),

          // 계산 설정
          _buildSectionHeader('계산'),
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('기준 연도'),
            subtitle: Text('$_defaultTaxYear년'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showTaxYearDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.format_list_numbered,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('숫자 표시 형식'),
            subtitle: Text(_numberFormat == 'korean' ? '한글 단위 (만원, 억원)' : '전체 숫자'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showNumberFormatDialog,
          ),
          const Divider(height: 1),

          // 도움말 설정
          _buildSectionHeader('도움말'),
          SwitchListTile(
            title: const Text('계산 팁 표시'),
            subtitle: const Text('계산 화면에서 도움말 표시'),
            secondary: Icon(
              Icons.lightbulb_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            value: _showTips,
            onChanged: (value) {
              setState(() {
                _showTips = value;
              });
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('사용 가이드'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showUsageGuide,
          ),
          const Divider(height: 1),

          // 정보
          _buildSectionHeader('정보'),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('앱 정보'),
            subtitle: const Text('버전 1.0.0'),
            onTap: _showAppInfo,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.gavel,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('세법 기준'),
            subtitle: const Text('2025년 세법 기준'),
            onTap: _showTaxLawInfo,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.privacy_tip_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('개인정보 처리방침'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 개인정보 처리방침 화면으로 이동
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('오픈소스 라이선스'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'Tax Master',
                applicationVersion: '1.0.0',
              );
            },
          ),
          const SizedBox(height: 24),

          // 면책 조항
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Text(
                        '면책 조항',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '본 앱의 계산 결과는 참고용으로만 사용하시기 바랍니다. '
                    '실제 세금 신고 및 납부는 반드시 세무사 또는 국세청의 '
                    '공식 안내를 따라주시기 바랍니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber[900],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showDeleteHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계산 기록 삭제'),
        content: const Text('모든 계산 기록을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 기록 삭제 로직
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

  void _showTaxYearDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('기준 연도 선택'),
        children: ['2025', '2024', '2023'].map((year) {
          return RadioListTile<String>(
            title: Text('$year년'),
            value: year,
            groupValue: _defaultTaxYear,
            onChanged: (value) {
              setState(() {
                _defaultTaxYear = value!;
              });
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  void _showNumberFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('숫자 표시 형식'),
        children: [
          RadioListTile<String>(
            title: const Text('한글 단위'),
            subtitle: const Text('예: 1억 2,345만원'),
            value: 'korean',
            groupValue: _numberFormat,
            onChanged: (value) {
              setState(() {
                _numberFormat = value!;
              });
              Navigator.pop(context);
            },
          ),
          RadioListTile<String>(
            title: const Text('전체 숫자'),
            subtitle: const Text('예: 123,450,000원'),
            value: 'full',
            groupValue: _numberFormat,
            onChanged: (value) {
              setState(() {
                _numberFormat = value!;
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showUsageGuide() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                '사용 가이드',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              _buildGuideItem(
                icon: Icons.calculate,
                title: '세금 계산하기',
                description: '홈 화면에서 원하는 세금 유형을 선택하고, 필요한 정보를 입력한 후 계산 버튼을 누르세요.',
              ),
              _buildGuideItem(
                icon: Icons.history,
                title: '계산 기록 확인',
                description: '하단의 기록 탭에서 이전 계산 내역을 확인할 수 있습니다. 필터 기능으로 특정 세금 유형만 볼 수 있습니다.',
              ),
              _buildGuideItem(
                icon: Icons.table_chart,
                title: '세율표 참고',
                description: '각 계산 화면 하단에 해당 세금의 세율표가 표시됩니다. 계산 결과를 이해하는 데 참고하세요.',
              ),
              _buildGuideItem(
                icon: Icons.auto_awesome,
                title: '자동 공제 계산',
                description: '인적공제, 근로소득공제 등 법정 공제 항목은 자동으로 계산됩니다.',
              ),
              _buildGuideItem(
                icon: Icons.info_outline,
                title: '실효세율 vs 한계세율',
                description: '실효세율은 실제 납부 세금의 비율이고, 한계세율은 추가 소득에 적용되는 세율입니다.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAppInfo() {
    showAboutDialog(
      context: context,
      applicationName: 'Tax Master',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.calculate,
          color: Colors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          '대한민국 세법에 기반한 종합 세금 계산기입니다.\n\n'
          '종합소득세, 법인세, 양도소득세, 상속세, 증여세, 퇴직소득세를 간편하게 계산할 수 있습니다.',
        ),
      ],
    );
  }

  void _showTaxLawInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('세법 기준'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '본 앱은 다음 법률을 기준으로 세금을 계산합니다:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• 소득세법 (2025년 기준)'),
              Text('• 소득세법 시행령'),
              SizedBox(height: 8),
              Text('• 법인세법 (2025년 기준)'),
              Text('• 법인세법 시행령'),
              SizedBox(height: 8),
              Text('• 상속세 및 증여세법 (2025년 기준)'),
              Text('• 상속세 및 증여세법 시행령'),
              SizedBox(height: 16),
              Text(
                '세법 개정 시 앱 업데이트를 통해 반영됩니다.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
