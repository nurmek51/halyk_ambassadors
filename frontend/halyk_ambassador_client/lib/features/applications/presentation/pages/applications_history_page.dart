import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../widgets/application_card.dart';

class ApplicationsHistoryPage extends StatefulWidget {
  const ApplicationsHistoryPage({super.key});

  @override
  State<ApplicationsHistoryPage> createState() => _ApplicationsHistoryPageState();
}

class _ApplicationsHistoryPageState extends State<ApplicationsHistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load applications when page opens
    context.read<ApplicationBloc>().add(GetUserApplicationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F2F1),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF1F2F1),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF1C1B1F),
              size: 24,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'История заявок',
            style: TextStyle(
              fontFamily: 'Mabry Pro',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1B1F),
              height: 1.3,
            ),
          ),
          centerTitle: false,
        ),
        body: BlocBuilder<ApplicationBloc, ApplicationState>(
          builder: (context, state) {
            if (state is ApplicationsHistoryLoading) {
              return _buildLoadingState();
            } else if (state is ApplicationsHistoryLoaded) {
              if (state.applications.isEmpty) {
                return _buildEmptyState();
              }
              return _buildApplicationsList(state.applications);
            } else if (state is ApplicationsHistoryError) {
              return _buildErrorState(state.message);
            } else {
              // Initial state - load applications
              context.read<ApplicationBloc>().add(GetUserApplicationsEvent());
              return _buildLoadingState();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: 5, // Show 5 skeleton items
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 100,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<dynamic> applications) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ApplicationBloc>().add(RefreshApplicationsEvent());
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: applications.length,
          itemBuilder: (context, index) {
            final application = applications[index];
            return ApplicationCard(
              application: application,
              onTap: () {
                // TODO: Navigate to application details page
                // For now, just show a placeholder
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Детали заявки (функция в разработке)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/icons/bookmark_icon.svg',
              width: 64,
              height: 64,
              colorFilter: const ColorFilter.mode(
                Color(0xFFBDBDBD),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Нет заявок',
              style: TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1F),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Создайте свою первую заявку для решения проблем в вашем районе',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0x99000000),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Go back to menu
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF35645B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Создать заявку',
                style: TextStyle(
                  fontFamily: 'Mabry Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFE57373),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ошибка загрузки',
              style: TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1B1F),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Mabry Pro',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0x99000000),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<ApplicationBloc>().add(GetUserApplicationsEvent());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF35645B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Повторить',
                style: TextStyle(
                  fontFamily: 'Mabry Pro',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
