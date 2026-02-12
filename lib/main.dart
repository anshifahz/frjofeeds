import 'package:flutter/material.dart';
import 'package:frijofeeds/frontscn/auth/presentation/pages/apilogin.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'frontscn/auth/presentation/providers/auth_provider.dart';
import 'frontscn/home/presentation/providers/home_provider.dart';
import 'frontscn/home/presentation/pages/home_screen.dart';
import 'frontscn/feed/presentation/providers/feed_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authProvider = AuthProvider(apiClient.dio);
  await authProvider.loadToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => HomeProvider(apiClient.dio)),
        ChangeNotifierProvider(create: (_) => FeedProvider(apiClient.dio)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frijofeeds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.token != null) {
            return const HomeScreen();
          }
          return const ApiLoginPage();
        },
      ),
    );
  }
}
