import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';

class PhoneInputField extends StatefulWidget {
  final Function(String) onChanged;
  final VoidCallback? onSubmitted;
  final String? initialValue;

  const PhoneInputField({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.initialValue,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '+7 ');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 354,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.phoneInput.copyWith(
                color: _controller.text == '+7 '
                    ? AppColors.inputPlaceholder
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                hintText: '+7 000 000 0000',
                hintStyle: AppTextStyles.phoneInput.copyWith(
                  color: AppColors.inputPlaceholder,
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
                _PhoneInputFormatter(),
              ],
              onChanged: (value) {
                setState(() {});
                widget.onChanged(value);
              },
              onSubmitted: (_) => widget.onSubmitted?.call(),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 14),
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.iconGray,
              borderRadius: BorderRadius.circular(13),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.isEmpty) {
      return const TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    if (!newText.startsWith('+7')) {
      return const TextEditingValue(
        text: '+7 ',
        selection: TextSelection.collapsed(offset: 3),
      );
    }

    final formatted = Validators.formatKazakhstanPhone(newText);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
