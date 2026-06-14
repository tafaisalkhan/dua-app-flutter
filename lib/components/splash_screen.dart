import 'package:flutter/material.dart';
import 'landing_page.dart';
import '../services/service.dart';
import '../services/audio_service.dart';
import 'dua.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Start the minimum 2-second splash screen timer
    final splashTimer = Future<void>.delayed(const Duration(seconds: 2));

    try {
      final loadedProphets = await DuaService.fetchProphets();
      prophets = loadedProphets;
    } catch (e) {
      debugPrint('Failed to load Prophets from service: $e');
    }

    // Fire-and-forget audio so it never blocks navigation
    AudioService.play('audio/bismillah.mp3').catchError((e) {
      debugPrint('Failed to play Bismillah: $e');
    });

    await splashTimer;

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LandingPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF15543F), Color(0xFF238B68)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Dua-ul-Anbiya',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Daily duas in one place',
                style: TextStyle(color: Color(0xFFEAF8F2), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
