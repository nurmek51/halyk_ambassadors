import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/halyk_logo_widget.dart';
import '../widgets/phone_input_field.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  String _phoneNumber = '+7 ';
  bool _isValidPhone = false;

  void _onPhoneChanged(String phone) {
    setState(() {
      _phoneNumber = phone;
      _isValidPhone = Validators.isValidKazakhstanPhone(phone);
    });
  }

  void _onSendOtp() {
    if (_isValidPhone) {
      final cleanPhone = _phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      context.read<AuthBloc>().add(RequestOtpEvent(cleanPhone));
    }
  }

  void _onHelpPressed() {
    // TODO: Implement help functionality
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is UserProfileExists) {
              // AuthWrapper will handle navigation automatically
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 200.5),
                  // Halyk Logo
                  const HalykLogoWidget(),
                  const SizedBox(height: 20),
                  // Title
                  Container(
                    width: 235,
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      'Введите номер телефона для авторизации',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Phone Input
                  PhoneInputField(
                    onChanged: _onPhoneChanged,
                    onSubmitted: _onSendOtp,
                    initialValue: '+7 ',
                  ),
                  const SizedBox(height: 21),
                  // Send Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Выслать код',
                        onPressed: _isValidPhone ? _onSendOtp : null,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const Spacer(),
                  // Help Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 52),
                    child: TextButton(
                      onPressed: _onHelpPressed,
                      child: Text(
                        'Помощь',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
