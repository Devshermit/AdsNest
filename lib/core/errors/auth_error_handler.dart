import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorHandler {
  static String parse(dynamic error) {
    if (error is AuthException) {
      final msg = error.message.toLowerCase();

      if (msg.contains('invalid login credentials')) {
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
      }
      if (msg.contains('user already registered')) {
        return 'อีเมลนี้ถูกใช้งานในระบบแล้ว';
      }
      if (msg.contains('email not confirmed')) {
        return 'กรุณายืนยันอีเมลของคุณก่อนเข้าสู่ระบบ';
      }
      if (msg.contains('rate limit') || msg.contains('too many requests')) {
        return 'มีการส่งคำขอมากเกินไป กรุณารอสักครู่แล้วลองใหม่';
      }
      if (msg.contains('password should be at least')) {
        return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
      }
      return error.message; // กรณีเป็น Message อื่นๆ ของ Supabase
    }
    return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง';
  }
}
