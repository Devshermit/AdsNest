import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandler {
  static String parse(dynamic error) {
    if (error is AuthException) {
      switch (error.code) {
        case 'invalid_credentials':
          return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
        case 'user_already_exists':
          return 'อีเมลนี้ถูกใช้งานในระบบแล้ว';
        case 'weak_password':
          return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
        case 'over_email_send_rate_limit':
          return 'มีการขอส่งอีเมลถี่เกินไป กรุณารอสักครู่แล้วลองใหม่';
        default:
          return error.message;
      }
    }

    if (error is PostgrestException) {
      if (error.code == '42501') {
        return 'คุณไม่มีสิทธิ์เข้าถึงหรือแก้ไขข้อมูลนี้';
      }
      return 'เกิดข้อผิดพลาดของฐานข้อมูล: ${error.message}';
    }
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception') || str.contains('clientexception')) {
      return 'ไม่สามารถเชื่อมต่ออินเตอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อ';
    }
    return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง';
  }
}
