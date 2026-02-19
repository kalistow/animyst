import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/login_page.dart';
import 'features/splash/splash_page.dart';
import 'core/theme/app_theme.dart';

/// Main entry point aplikasi
/// Menginisialisasi Supabase sebelum menjalankan aplikasi
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Ganti dengan URL dan Anon Key Supabase Anda
  await Supabase.initialize(
    url: 'https://ikhyrzlyadhjofnhxrbt.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlraHlyemx5YWRoam9mbmh4cmJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk5NjA2OTcsImV4cCI6MjA4NTUzNjY5N30.QSifps2OHDnBk1ECwrghpBkwkVHLGfqZ0eforBLNui8',
  );

  runApp(
    // Wrap dengan ProviderScope untuk Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// Instance Supabase global untuk kemudahan akses
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animyst - Gacha Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Force Dark Mode for this game style
      home: const SplashPage(), // Start with Splash Page
    );
  }
}

/// Placeholder HomePage
/// Nanti akan diganti dengan proper authentication flow
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Animyst - Gacha Game'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Selamat Datang di Animyst!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Game Gacha dengan Supabase',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📝 Setup Status:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('✓ Supabase Flutter dikonfigurasi'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('✓ Struktur folder dibuat'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Text('✓ Data Models dibuat'),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Jangan lupa update URL & Anon Key di main.dart!',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
