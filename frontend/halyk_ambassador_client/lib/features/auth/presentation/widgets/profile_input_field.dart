import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ProfileInputField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const ProfileInputField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: readOnly ? onTap : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: readOnly
                          ? Container(
                              height: 40,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                value?.isEmpty == true ? label : value ?? label,
                                style: AppTextStyles.bodyRegular.copyWith(
                                  color: value?.isEmpty == true
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                            )
                          : TextFormField(
                              initialValue: value,
                              onChanged: onChanged,
                              readOnly: readOnly,
                              keyboardType: keyboardType,
                              style: AppTextStyles.bodyRegular.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: label,
                                hintStyle: AppTextStyles.bodyRegular.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 9,
                                ),
                              ),
                            ),
                    ),
                    if (suffixIcon != null) suffixIcon!,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
