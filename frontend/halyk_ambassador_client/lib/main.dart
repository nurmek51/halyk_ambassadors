import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/phone_input_page.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/menu_page.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/otp_verification_page.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Halyk Ambassador',
      theme: AppTheme.theme,
      home: BlocProvider(
        create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        child: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            backgroundColor: Color(0xFFF1F2F1),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF35645B)),
              ),
            ),
          );
        } else if (state is Authenticated || state is UserProfileExists) {
          return const MenuPage();
        } else if (state is OtpVerified || state is UserProfileNotFound) {
          // User verified but needs to complete profile
          return const MenuPage(); // For now, redirect to menu. Later can check if profile is complete
        } else if (state is OtpSent) {
          return OtpVerificationPage(phoneNumber: state.phoneNumber);
        } else if (state is ProfileCreated) {
          return const MenuPage();
        } else {
          // Unauthenticated or other states
          return const PhoneInputPage();
        }
      },
    );
  }
}
