class WeatherData {
  final String cityName;
  final String countryCode;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime? sunrise;
  final DateTime? sunset;
  final int? aqi;
  final double? uvIndex;
  final int visibility;

  WeatherData({
    required this.cityName,
    required this.countryCode,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    this.sunrise,
    this.sunset,
    this.aqi,
    this.uvIndex,
    required this.visibility,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      cityName: json['name'],
      countryCode: json['sys']['country'],
      temp: json['main']['temp'].toDouble(),
      feelsLike: json['main']['feels_like'].toDouble(),
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      visibility: json['visibility'],
    );
  }

  String getWeatherAnimation() {
    if (description.toLowerCase().contains('rain')) return 'assets/rain.json';
    if (description.toLowerCase().contains('cloud')) return 'assets/clouds.json';
    if (description.toLowerCase().contains('snow')) return 'assets/snow.json';
    return 'assets/sunny.json';
  }

  String getOutfitSuggestion(String category) {
    if (category == "Men") {
      if (temp > 30) return "Light t-shirt and shorts";
      if (temp > 20) return "T-shirt with light jacket";
      if (temp > 10) return "Sweater and jacket";
      return "Heavy winter coat and gloves";
    } else if (category == "Women") {
      if (temp > 30) return "Summer dress and sunhat";
      if (temp > 20) return "Blouse with jeans";
      if (temp > 10) return "Sweater and coat";
      return "Winter coat and boots";
    } else {
      if (temp > 30) return "Light cotton clothes";
      if (temp > 20) return "Comfy t-shirt and pants";
      if (temp > 10) return "Jacket and closed shoes";
      return "Thermal wear and winter gear";
    }
  }
}

class ForecastData {
  final DateTime date;
  final double temp;
  final double tempMin;
  final double tempMax;
  final String description;
  final String icon;

  ForecastData({
    required this.date,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.description,
    required this.icon,
  });

  factory ForecastData.fromJson(Map<String, dynamic> json) {
    return ForecastData(
      date: DateTime.parse(json['dt_txt']),
      temp: json['main']['temp'].toDouble(),
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}