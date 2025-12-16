import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'providers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isDarkMode ? "assets/weather_bg.jpeg" : "assets/weather_bg.jpeg",
            fit: BoxFit.cover,
          ),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.blueGrey[800] : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: StadiumBorder(),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WeatherScreen()),
                );
              },
              child: const Text("Check Weather", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController cityController = TextEditingController();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String errorMessage = "";

  static const String apiKey = "f00c38e0279b7bc85480c3fe775d518c";

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    bool isFahrenheit = settingsProvider.isFahrenheit;
    bool isKm = settingsProvider.isKm;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Forecast"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.blueGrey.shade900, Colors.blueGrey.shade800]
                : [Colors.blue.shade800, Colors.blue.shade400],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
          child: Column(
            children: [
              _buildSearchBar(isDarkMode),
              const SizedBox(height: 20),
              if (isLoading) const CircularProgressIndicator(),
              if (errorMessage.isNotEmpty) _buildErrorMessage(isDarkMode),
              if (!isLoading && weatherData != null && errorMessage.isEmpty)
                Column(
                  children: [
                    _buildLocationHeader(),
                    const SizedBox(height: 20),
                    _buildTemperatureDisplay(isFahrenheit),
                    const SizedBox(height: 10),
                    _buildWeatherCondition(),
                    const SizedBox(height: 30),
                    _buildWeatherDetailsCard(isFahrenheit, isKm, isDarkMode),
                    const SizedBox(height: 20),
                    _buildOutfitSuggestionsCard(isFahrenheit, isDarkMode),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: "Search city...",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.7),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => fetchWeather(cityController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.red.withOpacity(0.3) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Column(
      children: [
        Text(
          "${weatherData!['name']}, ${weatherData!['sys']['country']}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat("MMMM d y, h:mm a").format(
            DateTime.fromMillisecondsSinceEpoch(weatherData!['dt'] * 1000),
          ),
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureDisplay(bool isFahrenheit) {
    final temp = isFahrenheit
        ? ((weatherData!['main']['temp'] * 9 / 5) + 32).toStringAsFixed(1)
        : weatherData!['main']['temp'].toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$temp°",
          style: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          children: [
            Text(
              isFahrenheit ? "F" : "C",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 60,
              height: 60,
              child: Lottie.asset(
                _getWeatherAnimation(weatherData!['weather'][0]['description']),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherCondition() {
    return Text(
      weatherData!['weather'][0]['description'].toString().toUpperCase(),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildWeatherDetailsCard(bool isFahrenheit, bool isKm, bool isDarkMode) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
              icon: Icons.air,
              label: "Wind",
              value: "${isKm ? (weatherData!['wind']['speed'] * 3.6).toStringAsFixed(1) : weatherData!['wind']['speed']} ${isKm ? 'km/h' : 'm/s'}",
              isDarkMode: isDarkMode,
            ),
            _buildDivider(isDarkMode),
            _buildDetailRow(
              icon: Icons.thermostat,
              label: "Feels Like",
              value: "${isFahrenheit ? ((weatherData!['main']['feels_like'] * 9 / 5) + 32).toStringAsFixed(1) : weatherData!['main']['feels_like'].toStringAsFixed(1)}°",
              isDarkMode: isDarkMode,
            ),
            _buildDivider(isDarkMode),
            _buildDetailRow(
              icon: Icons.water_drop,
              label: "Humidity",
              value: "${weatherData!['main']['humidity']}%",
              isDarkMode: isDarkMode,
            ),
            _buildDivider(isDarkMode),
            _buildDetailRow(
              icon: Icons.speed,
              label: "Pressure",
              value: "${weatherData!['main']['pressure']} hPa",
              isDarkMode: isDarkMode,
            ),
            if (weatherData!['visibility'] != null) ...[
              _buildDivider(isDarkMode),
              _buildDetailRow(
                icon: Icons.visibility,
                label: "Visibility",
                value: "${weatherData!['visibility'] / 1000} km",
                isDarkMode: isDarkMode,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: isDarkMode ? Colors.blue.shade200 : Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white.withOpacity(0.8) : Colors.white.withOpacity(0.9),
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue.shade100 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.2),
        height: 1,
      ),
    );
  }

  Widget _buildOutfitSuggestionsCard(bool isFahrenheit, bool isDarkMode) {
    final temp = isFahrenheit
        ? ((weatherData!['main']['temp'] * 9 / 5) + 32)
        : weatherData!['main']['temp'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "OUTFIT SUGGESTIONS",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _buildOutfitSuggestion(
              emoji: "👕",
              category: "Men",
              suggestion: _getMenOutfit(temp),
            ),
            _buildDivider(isDarkMode),
            _buildOutfitSuggestion(
              emoji: "👗",
              category: "Women",
              suggestion: _getWomenOutfit(temp),
            ),
            _buildDivider(isDarkMode),
            _buildOutfitSuggestion(
              emoji: "🧒",
              category: "Kids",
              suggestion: _getKidsOutfit(temp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitSuggestion({
    required String emoji,
    required String category,
    required String suggestion,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                suggestion,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getMenOutfit(double temp) {
    if (temp > 30) return "Lightweight linen shirt, breathable shorts, sunglasses, and sandals. Stay hydrated!";
    if (temp > 25) return "Cotton t-shirt, chino shorts or light pants, and comfortable sneakers.";
    if (temp > 20) return "Long-sleeve shirt with jeans or chinos. Light jacket for evenings.";
    if (temp > 10) return "Sweater or hoodie with jeans. Waterproof jacket if rainy.";
    if (temp > 0) return "Thermal layers, heavy coat, scarf, gloves, and warm boots.";
    return "Thermal underwear, thick parka, insulated gloves, wool hat, and winter boots.";
  }

  String _getWomenOutfit(double temp) {
    if (temp > 30) return "Sundress or flowy top with skirt, wide-brim hat, sandals. Don't forget sunscreen!";
    if (temp > 25) return "Blouse with shorts or light skirt. Comfortable flats or sandals.";
    if (temp > 20) return "Light sweater with jeans or midi skirt. Cardigan for cooler evenings.";
    if (temp > 10) return "Knit sweater, warm pants or tights, ankle boots. Add a stylish scarf.";
    if (temp > 0) return "Wool coat, thermal layers, gloves, and knee-high boots.";
    return "Down jacket, thermal leggings, turtleneck, earmuffs, and insulated boots.";
  }

  String _getKidsOutfit(double temp) {
    if (temp > 30) return "Light cotton t-shirt, shorts, sunhat, and sandals. Apply SPF 50+ sunscreen!";
    if (temp > 25) return "Breathable t-shirt, comfortable shorts, and sneakers. Pack a light jacket.";
    if (temp > 20) return "Long-sleeve shirt with pants or leggings. Light jacket for playtime.";
    if (temp > 10) return "Fleece jacket, warm pants, and waterproof shoes for outdoor activities.";
    if (temp > 0) return "Puffer coat, thermal layers, mittens, and snow boots.";
    return "Snowsuit, thermal underwear, balaclava, and insulated waterproof boots.";
  }

  String _getWeatherAnimation(String? condition) {
    if (condition == null) return 'assets/sunny.json';
    condition = condition.toLowerCase();
    if (condition.contains("rain")) return 'assets/rain.json';
    if (condition.contains("thunder")) return 'assets/thunderstorm.json';
    if (condition.contains("cloud")) return 'assets/cloudy.json';
    if (condition.contains("snow")) return 'assets/snow.json';
    if (condition.contains("mist") || condition.contains("fog")) return 'assets/mist.json';
    return 'assets/sunny.json';
  }

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) {
      setState(() => errorMessage = "Please enter a city name.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final Uri url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=${Uri.encodeComponent(city)}&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          weatherData = jsonDecode(response.body);
          errorMessage = "";
        });
      } else {
        setState(() => errorMessage = "City not found. Try another location.");
      }
    } catch (e) {
      setState(() => errorMessage = "Network error. Check your connection.");
    } finally {
      setState(() => isLoading = false);
    }
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Units', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Fahrenheit'),
            value: settings.isFahrenheit,
            onChanged: (value) => settings.toggleTemperatureUnit(),
          ),
          SwitchListTile(
            title: const Text('Kilometers'),
            value: settings.isKm,
            onChanged: (value) => settings.toggleDistanceUnit(),
          ),
          const Divider(),
          const Text('Appearance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: (value) => settings.toggleTheme(value),
          ),
          const Divider(),
          const Text('Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: settings.notificationsEnabled,
            onChanged: (value) => settings.toggleNotifications(),
          ),
          SwitchListTile(
            title: const Text('Daily Updates'),
            value: settings.dailyUpdates,
            onChanged: (value) => settings.toggleDailyUpdates(),
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: const [
                      FlutterLogo(),
                      SizedBox(width: 10),
                      Text('About Weather App'),
                    ],
                  ),
                  content: const Text(
                    'Weather App provides accurate, real-time weather updates with a beautiful and customizable interface.\n\n'
                        'Switch between Celsius and Fahrenheit.\n Toggle dark mode.\n And receive daily weather notifications.\n '
                        'Stay informed with a sleek and user-friendly experience!',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },

          ),
        ],
      ),
    );
  }
}