import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'ระบบขัดข้อง กรุณาลองใหม่อีกครั้ง']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต',
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'ไม่พบข้อมูลในหน่วยความจำชั่วคราว']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'บัญชีผู้ใช้ไม่มีสิทธิ์เข้าถึงข้อมูลนี้']);
}
