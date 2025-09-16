import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/profile_entities.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class CitySelectionModal extends StatefulWidget {
  final ValueChanged<City> onCitySelected;

  const CitySelectionModal({super.key, required this.onCitySelected});

  @override
  State<CitySelectionModal> createState() => _CitySelectionModalState();
}

class _CitySelectionModalState extends State<CitySelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  List<City> _allCities = [];
  List<City> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(LoadCitiesEvent());
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCities = _allCities;
      } else {
        _filteredCities = _allCities
            .where((city) => city.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black54),
      child: Column(
        children: [
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              width: 394,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 30, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Выберите город',
                            style: AppTextStyles.bodyRegular.copyWith(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.0,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Search
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: AppTextStyles.bodyRegular.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Поиск города по названию',
                              hintStyle: AppTextStyles.bodyRegular.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Cities List
                  Expanded(
                    child: BlocListener<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is CitiesLoaded) {
                          setState(() {
                            _allCities = state.cities;
                            _filteredCities = state.cities;
                          });
                        }
                      },
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accent,
                              ),
                            );
                          }

                          if (state is AuthError) {
                            return Center(
                              child: Text(
                                'Ошибка загрузки городов: ${state.message}',
                                style: AppTextStyles.bodyRegular.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            );
                          }

                          return SizedBox(
                            width: 354,
                            child: ListView.builder(
                              itemCount: _filteredCities.length,
                              itemBuilder: (context, index) {
                                final city = _filteredCities[index];
                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFDFDFDF),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        widget.onCitySelected(city);
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 18,
                                          horizontal: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              city.name,
                                              style: AppTextStyles.bodyRegular
                                                  .copyWith(
                                                    color: AppColors.textPrimary
                                                        .withValues(alpha: 0.8),
                                                  ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
