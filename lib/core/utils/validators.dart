class AppValidators {
  // ตรวจสอบอีเมล
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  // ตรวจสอบรหัสผ่าน (อย่างน้อย 6 ตัวอักษร)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    if (value.length < 6) {
      return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
    }
    return null;
  }

  // ตรวจสอบตัวเลขงบประมาณ
  static String? validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกจำนวนงบประมาณ';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'กรุณากรอกจำนวนเงินที่ถูกต้อง';
    }
    return null;
  }

  // ตรวจสอบลิงก์ URL (สำหรับ Affiliate Link Generator)
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอก URL';
    }
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'รูปแบบ URL ไม่ถูกต้อง';
    }
    return null;
  }
}
