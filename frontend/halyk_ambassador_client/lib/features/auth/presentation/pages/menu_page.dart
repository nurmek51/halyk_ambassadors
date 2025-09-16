import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halyk_ambassador_client/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../widgets/halyk_logo_widget.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 59),
              // Header card with logo and user info
              _buildHeaderCard(context),
              const SizedBox(height: 26),
              // Menu buttons
              _buildMenuButtons(context),
              const Spacer(),
              // Feedback link
              _buildFeedbackLink(),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const HalykLogoWidget(),
          const SizedBox(height: 31),
          // User info
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is ProfileMeLoaded) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    '􀉩 ${state.profile.fullName}',
                    style: const TextStyle(
                      fontFamily: 'Mabry Pro',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0x8A000000),
                      height: 1.3,
                    ),
                  ),
                );
              } else if (state is ProfileMeLoading) {
                return const CircularProgressIndicator();
              } else if (state is ProfileMeError) {
                return Text('Error: ${state.message}');
              } else {
                // Trigger load if not already loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (state is! ProfileMeLoaded && state is! ProfileMeLoading) {
                    context.read<AuthBloc>().add(GetProfileMeEvent());
                  }
                });
                return const Text('Loading...');
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Column(
      children: [
        // Create Request button
        _buildMenuButton(
          icon: 'assets/icons/add_icon.svg',
          title: 'Создать заявку',
          onTap: () {
            // Navigate to create request page
            // TODO: Implement navigation
          },
        ),
        const SizedBox(height: 24),
        // History button
        _buildMenuButton(
          icon: 'assets/icons/bookmark_icon.svg',
          title: 'История заявок',
          onTap: () {
            // Navigate to history page
            // TODO: Implement navigation
          },
        ),
      ],
    );
  }

  Widget _buildMenuButton({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      icon,
                      width: 18.42,
                      height: 18.42,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF1C1B1F),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.21,
                    ),
                  ),
                ),
                // Arrow icon
                Container(
                  width: 14,
                  height: 24,
                  alignment: Alignment.center,
                  child: Text(
                    '􀆊',
                    style: TextStyle(
                      fontFamily: 'SF Compact',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withValues(alpha: 0.1),
                      height: 1.19,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackLink() {
    return GestureDetector(
      onTap: () {
        // Open feedback
        // TODO: Implement feedback functionality
      },
      child: const Text(
        'Обратная связь',
        style: TextStyle(
          fontFamily: 'Mabry Pro',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF2782E3),
          height: 1.3,
        ),
      ),
    );
  }
}
