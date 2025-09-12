class Validators {
  static bool isValidKazakhstanPhone(String phone) {
    // Kazakhstan phone numbers: +7 (7XX) XXX-XX-XX or +7 7XX XXX XX XX
    final regex = RegExp(r'^\+?7[0-9]{10}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (!regex.hasMatch(cleanPhone)) return false;

    // Check if it starts with +77 (Kazakhstan mobile)
    return cleanPhone.startsWith('+77') ||
        (cleanPhone.startsWith('77') && cleanPhone.length == 11) ||
        (cleanPhone.startsWith('+7') && cleanPhone.length == 12);
  }

  static String formatKazakhstanPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length <= 1) return '+7 ';
    if (digits.length <= 4) return '+7 ${digits.substring(1)} ';
    if (digits.length <= 7) {
      return '+7 ${digits.substring(1, 4)} ${digits.substring(4)} ';
    }
    if (digits.length <= 9) {
      return '+7 ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7)} ';
    }
    if (digits.length <= 11) {
      return '+7 ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9)}';
    }

    return '+7 ${digits.substring(1, 4)} ${digits.substring(4, 7)} ${digits.substring(7, 9)} ${digits.substring(9, 11)}';
  }

  static bool isValidOtp(String otp) {
    return otp.length == 4 && RegExp(r'^\d{4}$').hasMatch(otp);
  }
}
