import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:week6_api_lab/services/weather_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ทดสอบ WeatherService', () async {
    await dotenv.load(fileName: ".env");
    final service = WeatherService();

    print('--- ทดสอบกรณีสำเร็จ (Bangkok) ---');
    try {
      final weather = await service.fetchWeather('Bangkok');
      print('cityName: ${weather.cityName}');
      print('temperature: ${weather.temperature}');
      print('description: ${weather.description}');
      print('feelsLike: ${weather.feelsLike}');
    } catch (e) {
      print('Error: $e');
    }

    print('--- ทดสอบกรณี 404 (เมืองไม่มีจริง) ---');
    try {
      final weather = await service.fetchWeather('ABCXYZ999');
      print('cityName: ${weather.cityName}');
    } catch (e) {
      print('Error: $e');
    }
  });
}