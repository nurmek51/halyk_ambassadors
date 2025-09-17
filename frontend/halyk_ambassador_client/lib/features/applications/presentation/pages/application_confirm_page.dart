import 'package:flutter/material.dart';
import '../../../../core/widgets/responsive_wrapper.dart';
import '../../../auth/presentation/pages/menu_page.dart';

class ApplicationConfirmPage extends StatelessWidget {
  const ApplicationConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const Spacer(flex: 3),
                // Success icon
                Container(
                  width: 78,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF64B128),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                // Success title
                const Text(
                  'Заявка отправлена',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Mabry Pro',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 16),
                // Success message
                Container(
                  width: 282.37,
                  constraints: const BoxConstraints(maxHeight: 43.78),
                  child: const Text(
                    'Спасибо за вашу информацию',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Mabry Pro',
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: Color(0xDE000000), // rgba(0, 0, 0, 0.87)
                      height: 1.3,
                    ),
                  ),
                ),
                const Spacer(flex: 5),
                // Close button
                SizedBox(
                  width: 354,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MenuPage(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000000),
                      foregroundColor: const Color(0xFFFFFFFF),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Закрыть',
                      style: TextStyle(
                        fontFamily: 'Mabry Pro',
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
