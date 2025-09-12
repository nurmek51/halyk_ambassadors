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
import '../widgets/phone_input_field.dart';
import 'otp_verification_page.dart';

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
            if (state is OtpSent) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<AuthBloc>(),
                    child: OtpVerificationPage(phoneNumber: state.phoneNumber),
                  ),
                ),
              );
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
                  const SizedBox(height: 208.5),
                  // Halyk Logo
                  SizedBox(
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
                              'assets/images/halyk_logo-a0a422.png',
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
                  ),
                  const SizedBox(height: 70),
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
