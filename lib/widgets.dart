import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'models.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('${weather.cityName}, ${weather.countryCode}'),
            Lottie.asset(weather.getWeatherAnimation(), height: 100),
            Text('${weather.temp.toStringAsFixed(1)}°'),
            Text(weather.description),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildWeatherDetail('Feels Like', '${weather.feelsLike.toStringAsFixed(1)}°'),
                _buildWeatherDetail('Humidity', '${weather.humidity}%'),
                _buildWeatherDetail('Wind', '${weather.windSpeed} km/h'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class ForecastItem extends StatelessWidget {
  final ForecastData forecast;
  final bool isSelected;
  final bool showDetails;

  const ForecastItem({
    super.key,
    required this.forecast,
    this.isSelected = false,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue[100] : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('${forecast.date.hour}:00'),
            Image.network(
              'https://openweathermap.org/img/wn/${forecast.icon}@2x.png',
              width: 40,
              height: 40,
            ),
            Text('${forecast.temp.toStringAsFixed(1)}°'),
            if (showDetails) ...[
              const SizedBox(height: 4),
              Text(forecast.description),
              Text('H: ${forecast.tempMax.toStringAsFixed(1)}°'),
              Text('L: ${forecast.tempMin.toStringAsFixed(1)}°'),
            ],
          ],
        ),
      ),
    );
  }
}

class AqiIndicator extends StatelessWidget {
  final int aqi;

  const AqiIndicator({super.key, required this.aqi});

  Color _getAqiColor() {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple[900]!;
  }

  String _getAqiDescription() {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Air Quality', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: aqi / 500,
              backgroundColor: Colors.grey[200],
              color: _getAqiColor(),
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AQI: $aqi', style: TextStyle(color: _getAqiColor(), fontWeight: FontWeight.bold)),
                Text(_getAqiDescription()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}