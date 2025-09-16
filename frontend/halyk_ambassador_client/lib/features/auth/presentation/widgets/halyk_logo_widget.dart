import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HalykLogoWidget extends StatelessWidget {
  const HalykLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148.01,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 148.01,
            height: 42,
            child: Center(
              child: Image.asset(
                'assets/images/halyk_logo.png',
                width: 148.01,
                height: 42,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'терминалы',
            style: AppTextStyles.brandText.copyWith(
              color: AppColors.brandGreen,
              fontFamily: 'Ubuntu',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              height: 1.0,
              letterSpacing: 0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
