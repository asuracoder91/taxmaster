import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/number_formatter.dart';

/// 세금 입력 필드 위젯
class TaxInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final String? suffix;
  final bool required;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const TaxInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffix = '원',
    this.required = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CurrencyInputFormatter(),
      ],
      validator: validator ??
          (value) {
            if (required && (value == null || value.isEmpty)) {
              return '$label을(를) 입력해주세요';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

/// 통화 입력 포매터
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // 숫자만 추출
    final numericString = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (numericString.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // 포맷팅
    final number = int.parse(numericString);
    final formatted = NumberFormatter.formatCurrency(number.toDouble());

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// 퍼센트 입력 필드
class PercentInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool required;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PercentInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.required = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: '%',
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      validator: validator ??
          (value) {
            if (required && (value == null || value.isEmpty)) {
              return '$label을(를) 입력해주세요';
            }
            if (value != null && value.isNotEmpty) {
              final percent = double.tryParse(value);
              if (percent == null || percent < 0 || percent > 100) {
                return '0~100 사이의 값을 입력해주세요';
              }
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

/// 연수 입력 필드
class YearsInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool required;
  final int? maxYears;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const YearsInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.required = false,
    this.maxYears,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixText: '년',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator ??
          (value) {
            if (required && (value == null || value.isEmpty)) {
              return '$label을(를) 입력해주세요';
            }
            if (value != null && value.isNotEmpty) {
              final years = int.tryParse(value);
              if (years == null || years < 0) {
                return '올바른 연수를 입력해주세요';
              }
              if (maxYears != null && years > maxYears!) {
                return '최대 $maxYears년까지 입력 가능합니다';
              }
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}
