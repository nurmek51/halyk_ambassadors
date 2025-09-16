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
import '../widgets/halyk_logo_widget.dart';

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
      if (!mounted) return; // Prevent setState on disposed widget
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
    // TODO: Implement functionality for users who cannot log in
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
            if (state is UserProfileExists || state is UserProfileNotFound) {
              _timer.cancel(); // Cancel timer before navigation
              // AuthWrapper will handle navigation automatically
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
                  const SizedBox(height: 180.5),
                  const HalykLogoWidget(),
                  const SizedBox(height: 20),
                  // Title
                  Container(
                    width: 235,
                    height: 44,
                    alignment: Alignment.center,
                    child: Text(
                      'Введите код из СМС',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyRegular.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
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
                  const Spacer(),
                  const Spacer(),
                  // Bottom Buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
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
                        // Cannot Login Button
                        TextButton(
                          onPressed: _onCannotLogin,
                          child: Text(
                            'Не получается войти?',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
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
