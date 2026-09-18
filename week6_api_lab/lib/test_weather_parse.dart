import 'dart:convert';
import 'models/weather.dart'; // ปรับ path ให้ตรงกับตำแหน่งไฟล์จริงในโปรเจกต์

void main() {
  const rawJson = '''
  {
    "coord": { "lon": 100.5167, "lat": 13.75 },
    "weather": [
      { "id": 802, "main": "Clouds", "description": "เมฆกระจาย", "icon": "03d" }
    ],
    "base": "stations",
    "main": {
      "temp": 31.38,
      "feels_like": 38.31,
      "temp_min": 29.94,
      "temp_max": 31.63,
      "pressure": 1010,
      "humidity": 69,
      "sea_level": 1010,
      "grnd_level": 1010
    },
    "visibility": 10000,
    "wind": { "speed": 1.28, "deg": 184, "gust": 1.53 },
    "clouds": { "all": 41 },
    "dt": 1789699912,
    "sys": {
      "type": 2,
      "id": 2112373,
      "country": "TH",
      "sunrise": 1789686417,
      "sunset": 1789730264
    },
    "timezone": 25200,
    "id": 1609350,
    "name": "กรุงเทพมหานคร",
    "cod": 200
  }
  ''';

  final json = jsonDecode(rawJson) as Map<String, dynamic>;
  final weather = Weather.fromJson(json);

  print('cityName: ${weather.cityName}');
  print('temperature: ${weather.temperature}');
  print('description: ${weather.description}');
  print('feelsLike: ${weather.feelsLike}');
}