import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/weather.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static final _apiKey = dotenv.env['OPENWEATHER_API_KEY'];

  Future<Weather> fetchWeather(String city) async {
    final uri = Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric&lang=th');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      print('DEBUG statusCode: ${response.statusCode}'); 

      if (response.statusCode == 200) {
        // ตัวอย่าง: กรณีสำเร็จ แปลงข้อมูลด้วย Weather.fromJson
        return Weather.fromJson(jsonDecode(response.body));
      }

      // เพิ่มเงื่อนไขกรณี statusCode == 404
      if (response.statusCode == 404) {
        throw Exception('ไม่พบเมืองที่ค้นหา กรุณาตรวจสอบชื่อเมืองอีกครั้ง');
      }

      throw Exception('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (รหัส ${response.statusCode})');
    } on TimeoutException {
      // ตัวอย่าง: แปลง error ที่ได้จากระบบ เป็นข้อความภาษาไทยที่อ่านเข้าใจง่าย
      throw Exception('การเชื่อมต่อหมดเวลา กรุณาลองใหม่อีกครั้ง');
    } on http.ClientException {
      // ตัวอย่าง: ดักจับกรณีเชื่อมต่อเซิร์ฟเวอร์ไม่ได้เลย (เช่น ไม่มีอินเทอร์เน็ต)
      throw Exception('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้ กรุณาตรวจสอบการเชื่อมต่อ');
    } on FormatException {
      // ดักจับกรณี JSON ที่ได้กลับมาผิดรูปแบบ (parse ไม่ได้)
      throw Exception('ข้อมูลที่ได้รับไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง');
    } catch (e) {
      rethrow;
    }
  }
}