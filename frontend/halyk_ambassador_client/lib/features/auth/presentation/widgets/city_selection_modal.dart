import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/profile_entities.dart';

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

  // Kazakhstan cities data
  static const List<Map<String, String>> _kazakhstanCities = [
    {'id': '1', 'name': 'Актау'},
    {'id': '2', 'name': 'Актобе'},
    {'id': '3', 'name': 'Алматы'},
    {'id': '4', 'name': 'Астана'},
    {'id': '5', 'name': 'Арқалық'},
    {'id': '6', 'name': 'Атырау'},
    {'id': '7', 'name': 'Байқоңыр'},
    {'id': '8', 'name': 'Балқаш'},
    {'id': '9', 'name': 'Жезқазған'},
    {'id': '10', 'name': 'Қарағанды'},
    {'id': '11', 'name': 'Кентау'},
    {'id': '12', 'name': 'Қызылорда'},
    {'id': '13', 'name': 'Көкшетау'},
    {'id': '14', 'name': 'Қостанай'},
    {'id': '15', 'name': 'Жаңаөзен'},
    {'id': '16', 'name': 'Павлодар'},
    {'id': '17', 'name': 'Петропавл'},
    {'id': '18', 'name': 'Риддер'},
    {'id': '19', 'name': 'Саран'},
    {'id': '20', 'name': 'Сәтбаев'},
    {'id': '21', 'name': 'Семей'},
    {'id': '22', 'name': 'Степногорск'},
    {'id': '23', 'name': 'Талдықорған'},
    {'id': '24', 'name': 'Тараз'},
    {'id': '25', 'name': 'Теміртау'},
    {'id': '26', 'name': 'Түркістан'},
    {'id': '27', 'name': 'Орал'},
    {'id': '28', 'name': 'Өскемен'},
    {'id': '29', 'name': 'Шымкент'},
    {'id': '30', 'name': 'Шахтинск'},
    {'id': '31', 'name': 'Щучинск'},
    {'id': '32', 'name': 'Екібастұз'},
    {'id': '33', 'name': 'Жолқызыл'},
    {'id': '34', 'name': 'Уртенсай'},
    {'id': '35', 'name': 'Керамик'},
    {'id': '36', 'name': 'Мамайка'},
    {'id': '37', 'name': 'Бітік'},
    {'id': '38', 'name': 'Жамантұз'},
    {'id': '39', 'name': 'Акарал'},
    {'id': '40', 'name': 'Варваринка'},
    {'id': '41', 'name': 'Чистополье'},
    {'id': '42', 'name': 'Жусалы'},
    {'id': '43', 'name': 'Қожагелді'},
    {'id': '44', 'name': 'Калинино'},
    {'id': '45', 'name': 'Жандак-Ори'},
    {'id': '46', 'name': 'Подпуск'},
    {'id': '47', 'name': 'Елтай'},
    {'id': '48', 'name': 'Ленинту'},
    {'id': '49', 'name': 'Малдыбұлақ'},
    {'id': '50', 'name': 'Ортаколь'},
    {'id': '51', 'name': 'Нұр-Сұлтан'},
    {'id': '57', 'name': 'Бородулиха'},
    {'id': '58', 'name': 'Кокпекти'},
    {'id': '59', 'name': 'Курчум'},
    {'id': '60', 'name': 'Катон-Карагай'},
    {'id': '61', 'name': 'Зайсан'},
    {'id': '62', 'name': 'Капшагай'},
    {'id': '63', 'name': 'Есик'},
    {'id': '64', 'name': 'Текели'},
    {'id': '65', 'name': 'Уштобе'},
    {'id': '66', 'name': 'Жаркент'},
    {'id': '67', 'name': 'Панфилов'},
    {'id': '68', 'name': 'Сарканд'},
    {'id': '69', 'name': 'Талгар'},
    {'id': '70', 'name': 'Сарыөзек'},
    {'id': '71', 'name': 'Лепсы'},
    {'id': '72', 'name': 'Баканас'},
    {'id': '73', 'name': 'Өтеген батыр'},
    {'id': '74', 'name': 'Көксу'},
    {'id': '75', 'name': 'Зыряновск'},
    {'id': '76', 'name': 'Курчатов'},
    {'id': '77', 'name': 'Аягөз'},
    {'id': '78', 'name': 'Шемонаиха'},
    {'id': '79', 'name': 'Глубокое'},
    {'id': '80', 'name': 'Абай'},
    {'id': '81', 'name': 'Каркаралинск'},
    {'id': '82', 'name': 'Приозерск'},
    {'id': '84', 'name': 'Лисаковск'},
    {'id': '85', 'name': 'Рудный'},
    {'id': '86', 'name': 'Житикара'},
    {'id': '87', 'name': 'Федоровка'},
    {'id': '88', 'name': 'Денисовка'},
    {'id': '89', 'name': 'Арал'},
    {'id': '90', 'name': 'Қазалы'},
    {'id': '91', 'name': 'Жосалы'},
    {'id': '92', 'name': 'Шиелі'},
    {'id': '93', 'name': 'Жетібай'},
    {'id': '94', 'name': 'Бейнеу'},
    {'id': '95', 'name': 'Сенек'},
    {'id': '96', 'name': 'Шетпе'},
    {'id': '97', 'name': 'Сергеевка'},
    {'id': '98', 'name': 'Тайынша'},
    {'id': '99', 'name': 'Булаево'},
    {'id': '100', 'name': 'Мамлютка'},
    {'id': '101', 'name': 'Ақсу'},
    {'id': '102', 'name': 'Ертіс'},
    {'id': '103', 'name': 'Майское'},
    {'id': '104', 'name': 'Баянауыл'},
    {'id': '106', 'name': 'Арыс'},
    {'id': '107', 'name': 'Ленгер'},
    {'id': '108', 'name': 'Мақтаарал'},
    {'id': '109', 'name': 'Сарыағаш'},
    {'id': '110', 'name': 'Шардара'},
    {'id': '111', 'name': 'Төле би'},
    {'id': '112', 'name': 'Ақсай'},
    {'id': '113', 'name': 'Жаңғала'},
    {'id': '114', 'name': 'Переметное'},
    {'id': '115', 'name': 'Шыңғырлау'},
    {'id': '116', 'name': 'Қордай'},
    {'id': '117', 'name': 'Шу'},
    {'id': '118', 'name': 'Мерке'},
    {'id': '119', 'name': 'Мойынкум'},
    {'id': '120', 'name': 'Сарысу'},
    {'id': '121', 'name': 'Қандыағаш'},
    {'id': '122', 'name': 'Ембі'},
    {'id': '123', 'name': 'Мартук'},
    {'id': '124', 'name': 'Хобда'},
    {'id': '125', 'name': 'Доссор'},
    {'id': '126', 'name': 'Құлсары'},
    {'id': '127', 'name': 'Индербор'},
    {'id': '128', 'name': 'Мақат'},
    {'id': '129', 'name': 'Атбасар'},
    {'id': '130', 'name': 'Мақинск'},
    {'id': '131', 'name': 'Есіл'},
    {'id': '132', 'name': 'Аққол'},
    {'id': '133', 'name': 'Сандықтау'},
    {'id': '135', 'name': 'Жаңаарқа'},
    {'id': '136', 'name': 'Ұлытау'},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with static cities data
    _initializeCities();
    _searchController.addListener(_filterCities);
  }

  void _initializeCities() {
    _allCities = _kazakhstanCities.map((cityData) {
      return City(id: cityData['id']!, name: cityData['name']!);
    }).toList();

    // Sort cities alphabetically
    _allCities.sort((a, b) => a.name.compareTo(b.name));
    _filteredCities = List.from(_allCities);
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
                    child: SizedBox(
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
