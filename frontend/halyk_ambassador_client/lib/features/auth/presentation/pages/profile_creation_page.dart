import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/profile_entities.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_button.dart';
import '../widgets/profile_input_field.dart';
import '../widgets/city_selection_modal.dart';

class ProfileCreationPage extends StatefulWidget {
  final AuthContext? authContext;

  const ProfileCreationPage({super.key, this.authContext});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  String _name = '';
  String _surname = '';
  String _position = '';
  City? _selectedCity;

  bool get _isFormValid {
    return _name.isNotEmpty &&
        _surname.isNotEmpty &&
        _position.isNotEmpty &&
        _selectedCity != null;
  }

  void _onNameChanged(String value) {
    setState(() {
      _name = value;
    });
  }

  void _onSurnameChanged(String value) {
    setState(() {
      _surname = value;
    });
  }

  void _onPositionChanged(String value) {
    setState(() {
      _position = value;
    });
  }

  void _onCityTap() {
    final authBloc = context.read<AuthBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: authBloc,
        child: CitySelectionModal(
          onCitySelected: (city) {
            setState(() {
              _selectedCity = city;
            });
          },
        ),
      ),
    );
  }

  void _onBranchTap() {
    // TODO: Implement branch selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Выбор филиала пока не реализован'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _onSubmit() {
    if (_isFormValid && widget.authContext != null) {
      final profileData = ProfileData(
        phoneNumber: widget.authContext!.phoneNumber,
        name: _name,
        surname: _surname,
        position: _position,
        addressQuery: 'Город ${_selectedCity!.name}',
      );

      context.read<AuthBloc>().add(CreateProfileEvent(profileData));
    } else if (widget.authContext == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка: не найдены данные авторизации'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Профиль успешно создан!'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 70),

                    // Title
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Введите ваши данные',
                        style: AppTextStyles.bodyRegular.copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Form inputs
                    Column(
                      children: [
                        // Name input
                        ProfileInputField(
                          label: 'Имя',
                          value: _name,
                          onChanged: _onNameChanged,
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 20),

                        // Surname input
                        ProfileInputField(
                          label: 'Фамилия',
                          value: _surname,
                          onChanged: _onSurnameChanged,
                          keyboardType: TextInputType.name,
                        ),

                        const SizedBox(height: 20),

                        // Position input
                        ProfileInputField(
                          label: 'Должность',
                          value: _position,
                          onChanged: _onPositionChanged,
                          keyboardType: TextInputType.text,
                        ),

                        const SizedBox(height: 20),

                        // City selection
                        ProfileInputField(
                          label: 'Город',
                          value: _selectedCity?.name ?? '',
                          readOnly: true,
                          onTap: _onCityTap,
                          suffixIcon: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Branch selection - placeholder
                        ProfileInputField(
                          label: 'Ваш филиал',
                          value: '',
                          readOnly: true,
                          onTap: _onBranchTap,
                          suffixIcon: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Submit Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 52),
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            text: 'Войти в систему',
                            onPressed: _isFormValid ? _onSubmit : null,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
