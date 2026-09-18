import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';

Future<Weather> fetchWeatherWithDio(String city) async {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final apiKey = dotenv.env['OPENWEATHER_API_KEY'];

  try {
    final response = await dio.get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {'q': city, 'appid': apiKey, 'units': 'metric'},
    );
    return Weather.fromJson(response.data as Map<String, dynamic>);
  } on DioException catch (e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
    } else if (e.type == DioExceptionType.badResponse) {
      // ตัวอย่าง: เซิร์ฟเวอร์ตอบกลับมาแล้วแต่ status code ผิดพลาด (เช่น 404, 500)
      throw Exception('เซิร์ฟเวอร์ตอบกลับผิดพลาด (${e.response?.statusCode})');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      // เชื่อมต่อกับเซิร์ฟเวอร์ได้แล้ว แต่รอรับข้อมูลกลับมานานเกินกำหนด (10 วินาที)
      // ต่างจาก connectionTimeout ตรงที่ตอนนี้ "เชื่อมต่อสำเร็จแล้ว" เพียงแต่ข้อมูลส่งกลับมาช้าเกินไป
      throw Exception('เซิร์ฟเวอร์ตอบกลับช้าเกินไป กรุณาลองใหม่อีกครั้ง');
    } else if (e.type == DioExceptionType.connectionError) {
      // ไม่สามารถสร้างการเชื่อมต่อไปยังเซิร์ฟเวอร์ได้เลยตั้งแต่ต้น
      // เช่น ไม่มีอินเทอร์เน็ต, DNS หาเซิร์ฟเวอร์ไม่เจอ, หรือถูกไฟร์วอลล์บล็อก
      throw Exception('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อของคุณ');
    }

    throw Exception('เกิดข้อผิดพลาด: ${e.message}');
  }
}