import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers.dart';
import 'screens.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Weather Pro',
          theme: ThemeData.light().copyWith(
            brightness: Brightness.light,
            primaryColor: Colors.blue[400],
            colorScheme: ColorScheme.light(
              secondary: Colors.blue[200]!,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          darkTheme: ThemeData.dark().copyWith(
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey[800],
            colorScheme: ColorScheme.dark(
              secondary: Colors.blueGrey[600]!,
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
          routes: {
            '/forecast': (context) => const WeatherScreen(),
          },
        );
      },
    );
  }
}
