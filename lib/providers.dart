import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'services.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isFahrenheit = false;
  bool _isKm = false;
  bool _notificationsEnabled = false;
  bool _dailyUpdates = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isFahrenheit => _isFahrenheit;
  bool get isKm => _isKm;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyUpdates => _dailyUpdates;

  SettingsProvider() {
    _loadSettings();
  }

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }

  void toggleTemperatureUnit() {
    _isFahrenheit = !_isFahrenheit;
    _saveSettings();
    notifyListeners();
  }

  void toggleDistanceUnit() {
    _isKm = !_isKm;
    _saveSettings();
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveSettings();
    notifyListeners();
  }

  void toggleDailyUpdates() {
    _dailyUpdates = !_dailyUpdates;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setBool('isFahrenheit', _isFahrenheit);
    await prefs.setBool('isKm', _isKm);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('dailyUpdates', _dailyUpdates);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? ThemeMode.system.index];
    _isFahrenheit = prefs.getBool('isFahrenheit') ?? false;
    _isKm = prefs.getBool('isKm') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    _dailyUpdates = prefs.getBool('dailyUpdates') ?? true;
    notifyListeners();
  }
}

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  WeatherData? _currentWeather;
  List<ForecastData> _forecast = [];
  List<ForecastData> _hourlyForecast = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastCity = '';

  WeatherData? get currentWeather => _currentWeather;
  List<ForecastData> get forecast => _forecast;
  List<ForecastData> get hourlyForecast => _hourlyForecast;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String getFormattedTemp(double temp) {
    final settings = SettingsProvider();
    return settings.isFahrenheit
        ? '${((temp * 9 / 5) + 32).toStringAsFixed(1)}°F'
        : '${temp.toStringAsFixed(1)}°C';
  }

  Future<void> fetchWeather(String city) async {
    _lastCity = city;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentWeather = await _weatherService.fetchWeather(city);
      _forecast = await _weatherService.fetchForecast(city);
      _prepareHourlyForecast();
      await _saveLastLocation();
    } catch (e) {
      _errorMessage = 'Failed to load weather data: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> getCurrentLocationWeather() async {
    try {
      final position = await LocationService().getCurrentLocation();
      await fetchWeatherByCoordinates(position.latitude, position.longitude);
    } catch (e) {
      _errorMessage = 'Failed to get location: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> fetchWeatherByCoordinates(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _currentWeather = await _weatherService.fetchWeatherByLocation(lat, lon);
      _forecast = await _weatherService.fetchForecastByLocation(lat, lon);
      _prepareHourlyForecast();
      await _saveLastLocation();
    } catch (e) {
      _errorMessage = 'Failed to load weather data: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshWeather() async {
    if (_lastCity.isNotEmpty) {
      await fetchWeather(_lastCity);
    }
  }

  Future<void> _saveLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCity', _lastCity);
  }

  Future<void> loadLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString('lastCity');
    if (lastCity != null && lastCity.isNotEmpty) {
      await fetchWeather(lastCity);
    }
  }

  void _prepareHourlyForecast() {
    _hourlyForecast = _forecast
        .where((item) => item.date.isAfter(DateTime.now()))
        .take(24)
        .toList();
  }
}