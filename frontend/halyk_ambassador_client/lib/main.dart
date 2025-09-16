import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/phone_input_page.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/menu_page.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/profile_creation_page.dart';
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

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTokenRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App resumed, check auth status and refresh token if needed
      context.read<AuthBloc>().add(RefreshTokenEvent());
    }
  }

  void _startTokenRefreshTimer() {
    // Refresh token every 25 minutes (tokens usually expire in 30 minutes)
    _refreshTimer = Timer.periodic(const Duration(minutes: 25), (timer) {
      if (mounted) {
        context.read<AuthBloc>().add(RefreshTokenEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading ||
            state is AuthInitial ||
            state is ProfileMeLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFF1F2F1),
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF35645B)),
              ),
            ),
          );
        } else if (state is ProfileMeLoaded || state is UserProfileExists) {
          return const MenuPage();
        } else if (state is UserProfileNotFound) {
          return ProfileCreationPage(authContext: state.authContext);
        } else if (state is OtpSent) {
          return OtpVerificationPage(phoneNumber: state.phoneNumber);
        } else {
          // Unauthenticated or other states
          return const PhoneInputPage();
        }
      },
    );
  }
}
