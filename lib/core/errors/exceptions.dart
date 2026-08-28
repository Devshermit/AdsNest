class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'เกิดข้อผิดพลาดจากระบบเซิร์ฟเวอร์']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([
    this.message = 'ไม่สามารถอ่านหรือบันทึกข้อมูลในอุปกรณ์ได้',
  ]);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([
    this.message = 'การสิทธิ์เข้าถึงไม่ถูกต้อง หรือเซสชันหมดอายุ',
  ]);
}
