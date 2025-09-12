import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/otp_input_field.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  late Timer _timer;
  int _secondsRemaining = 80; // 01:20
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _onOtpCompleted(String code) {
    context.read<AuthBloc>().add(
      VerifyOtpEvent(phoneNumber: widget.phoneNumber, otpCode: code),
    );
  }

  void _onResendOtp() {
    if (_canResend) {
      setState(() {
        _secondsRemaining = 80;
        _canResend = false;
      });
      _startTimer();
      context.read<AuthBloc>().add(ResendOtpEvent(widget.phoneNumber));
    }
  }

  void _onCannotLogin() {
    // TODO: Implement cannot login functionality
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              // TODO: Navigate to main app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Авторизация успешна!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is OtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
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
                    height: 59,
                    child: Column(
                      children: [
                        Container(
                          width: 148.01,
                          height: 42,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/halyk_logo-a0a422.png',
                              ),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'терминалы',
                          style: AppTextStyles.brandText.copyWith(
                            color: AppColors.brandGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 53),
                  // Title
                  Container(
                    width: 164,
                    height: 22,
                    alignment: Alignment.center,
                    child: Text(
                      'Введите код из СМС',
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 39),
                  // OTP Input
                  OtpInputField(onCompleted: _onOtpCompleted),
                  const SizedBox(height: 21),
                  // Continue Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        text: 'Продолжить',
                        onPressed: null, // Button is disabled, OTP auto-submits
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: 79),
                  // Resend Timer
                  TextButton(
                    onPressed: _canResend ? _onResendOtp : null,
                    child: Text(
                      _canResend
                          ? 'Отправить код повторно'
                          : 'Отправить код повторно (${_formatTime(_secondsRemaining)})',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _canResend
                            ? AppColors.accent
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Cannot Login Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 52),
                    child: TextButton(
                      onPressed: _onCannotLogin,
                      child: Text(
                        'Не получается войти?',
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
