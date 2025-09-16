import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:halyk_ambassador_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/pages/profile_creation_page.dart';
import 'package:halyk_ambassador_client/features/auth/domain/usecases/request_otp.dart';
import 'package:halyk_ambassador_client/features/auth/domain/usecases/verify_otp.dart';
import 'package:halyk_ambassador_client/features/auth/domain/usecases/create_profile.dart';
import 'package:halyk_ambassador_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:halyk_ambassador_client/features/auth/domain/entities/auth_entities.dart';
import 'package:halyk_ambassador_client/features/auth/domain/entities/profile_entities.dart';

// Simple mock implementation for testing
class MockAuthRepository implements AuthRepository {
  @override
  Future<void> clearTokens() async {}

  @override
  Future<void> createProfile(ProfileData profileData) async {}

  @override
  Future<List<City>> getCities() async => [];

  @override
  Future<AuthTokens?> getTokens() async => null;

  @override
  Future<AuthContext?> getAuthContext() async => null;

  @override
  Future<void> requestOtp(OtpRequest request) async {}

  @override
  Future<void> saveTokens(AuthTokens tokens) async {}

  @override
  Future<AuthTokens> verifyOtp(OtpVerification verification) async =>
      const AuthTokens(accessToken: 'test', refreshToken: 'test');
}

void main() {
  group('ProfileCreationPage Widget Tests', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      authBloc = AuthBloc(
        requestOtp: RequestOtp(mockRepository),
        verifyOtp: VerifyOtp(mockRepository),
        createProfile: CreateProfile(mockRepository),
        getCities: GetCities(mockRepository),
      );
    });

    testWidgets('should display all form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: authBloc,
            child: const ProfileCreationPage(),
          ),
        ),
      );

      expect(find.text('Введите ваши данные'), findsOneWidget);
      expect(find.text('Имя'), findsOneWidget);
      expect(find.text('Фамилия'), findsOneWidget);
      expect(find.text('Должность'), findsOneWidget);
      expect(find.text('Город'), findsOneWidget);
      expect(find.text('Ваш филиал'), findsOneWidget);
      expect(find.text('Войти в систему'), findsOneWidget);
    });

    testWidgets('form fields should be interactable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: authBloc,
            child: const ProfileCreationPage(),
          ),
        ),
      );

      // Find text fields and verify they exist
      final nameField = find.widgetWithText(TextFormField, 'Имя').first;
      final surnameField = find.widgetWithText(TextFormField, 'Фамилия').first;
      final positionField = find
          .widgetWithText(TextFormField, 'Должность')
          .first;

      expect(nameField, findsOneWidget);
      expect(surnameField, findsOneWidget);
      expect(positionField, findsOneWidget);

      // Test typing in name field
      await tester.enterText(nameField, 'Тест');
      await tester.pump();

      expect(find.text('Тест'), findsOneWidget);
    });
  });
}
