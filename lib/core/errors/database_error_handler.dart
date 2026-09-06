import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseErrorHandler {
  static String parse(dynamic error) {
    if (error is PostgrestException) {
      switch (error.code) {
        case '42501':
          return 'คุณไม่มีสิทธิ์ในการเข้าถึงข้อมูลนี้ (RLS Violation)';
        case '23505':
          return 'ข้อมูลนี้มีอยู่ในระบบแล้ว (เช่น Short Code นี้ถูกใช้ไปแล้ว)';
        case '23503':
          return 'ข้อมูลอ้างอิงไม่ถูกต้อง หรือถูกลบไปแล้ว';
        case 'PGRST116':
          return 'ไม่พบข้อมูลที่ต้องการ';
        default:
          return 'เกิดข้อผิดพลาดจากฐานข้อมูล: ${error.message}';
      }
    }

    final errorString = error.toString().toLowerCase();
    if (errorString.contains('socketexception') ||
        errorString.contains('clientexception') ||
        errorString.contains('connection failed')) {
      return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อของคุณ';
    }

    if (errorString.contains('timeout')) {
      return 'หมดเวลาในการเชื่อมต่อเซิร์ฟเวอร์ กรุณาลองใหม่อีกครั้ง';
    }

    return 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ กรุณาลองใหม่อีกครั้ง';
  }
}
