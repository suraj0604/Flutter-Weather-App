import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'models.dart';

class WeatherService {
  static const String _apiKey = 'f00c38e0279b7bc85480c3fe775d518c';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherData> fetchWeather(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<ForecastData>> fetchForecast(String city) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&cnt=40'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<ForecastData>.from(
        data['list'].map((item) => ForecastData.fromJson(item)),
      );
    } else {
      throw Exception('Failed to load forecast data');
    }
  }

  Future<WeatherData> fetchWeatherByLocation(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return WeatherData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  Future<List<ForecastData>> fetchForecastByLocation(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/forecast?lat=$lat&lon=$lon&appid=$_apiKey&units=metric&cnt=40'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<ForecastData>.from(
        data['list'].map((item) => ForecastData.fromJson(item)),
      );
    } else {
      throw Exception('Failed to load forecast data');
    }
  }
}

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
  }
}