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
  bool _isRefreshingToken = false;
  DateTime? _lastRefreshTime;

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
    _refreshTimer = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only refresh token when app is resumed and enough time has passed since last refresh
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      final timeSinceLastRefresh = _lastRefreshTime != null
          ? now.difference(_lastRefreshTime!)
          : const Duration(minutes: 30); // Allow refresh on first resume

      // Only refresh if it's been more than 5 minutes since last refresh
      // and we're not already refreshing
      // Also skip refresh if this is the first time the app is resuming (app just started)
      if (timeSinceLastRefresh.inMinutes >= 5 &&
          !_isRefreshingToken &&
          _lastRefreshTime != null) {
        print(
          '🔄 App resumed - refreshing token after ${timeSinceLastRefresh.inMinutes} minutes',
        );
        _refreshToken();
      } else if (_lastRefreshTime == null) {
        print('🚀 App just started - skipping token refresh on first resume');
      } else {
        print(
          '⏭️ Skipping token refresh - last refresh was ${timeSinceLastRefresh.inMinutes} minutes ago',
        );
      }
    }
  }

  void _startTokenRefreshTimer() {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Refresh token every 25 minutes (tokens usually expire in 30 minutes)
    _refreshTimer = Timer.periodic(const Duration(minutes: 25), (timer) {
      if (mounted && !_isRefreshingToken) {
        print('⏰ Scheduled token refresh');
        _refreshToken();
      }
    });
    print('⏰ Token refresh timer started (25 minutes interval)');
  }

  Future<void> _refreshToken() async {
    if (_isRefreshingToken) {
      print('⚠️ Token refresh already in progress, skipping');
      return;
    }

    _isRefreshingToken = true;
    _lastRefreshTime = DateTime.now();

    try {
      context.read<AuthBloc>().add(RefreshTokenEvent());
      print('📤 RefreshTokenEvent dispatched');
    } catch (e) {
      print('❌ Error dispatching RefreshTokenEvent: $e');
    } finally {
      // Reset the flag after a delay to prevent rapid successive calls
      // Increased delay to ensure token refresh completes properly
      Future.delayed(const Duration(seconds: 60), () {
        if (mounted) {
          _isRefreshingToken = false;
        }
      });
    }
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
