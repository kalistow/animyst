import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/screens/login_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container
            Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 40, spreadRadius: 5),
                  BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
                ],
                border: Border.all(color: Colors.white10, width: 2),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (c, o, s) => const Icon(Icons.auto_awesome, size: 80, color: Colors.cyanAccent),
              ),
            ).animate()
             .fade(duration: 1.seconds)
             .scale(duration: 1.seconds, curve: Curves.easeOutBack)
             .then()
             .shimmer(duration: 1500.ms, color: Colors.white24)
             .animate(onPlay: (c) => c.repeat(reverse: true))
             .boxShadow(
                begin: BoxShadow(color: Colors.purpleAccent.withOpacity(0.6), blurRadius: 20, spreadRadius: 0),
                end: BoxShadow(color: Colors.purpleAccent.withOpacity(0.6), blurRadius: 50, spreadRadius: 10),
                duration: 2.seconds
             ),
            
            const SizedBox(height: 50),

            // Animated Text
            Column(
              children: [
                const Text(
                  "ANIMYST",
                  style: TextStyle(
                    fontFamily: 'Orbitron', // Try Orbitron if available, else system default
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.purple, blurRadius: 20),
                      Shadow(color: Colors.cyan, blurRadius: 10, offset: Offset(2,2))
                    ]
                  ),
                ).animate()
                 .fadeIn(delay: 800.ms, duration: 800.ms)
                 .slideY(begin: 0.5, end: 0, delay: 800.ms),

                const SizedBox(height: 16),
                
                const Text(
                  "NEURAL LINK STARTING...",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold
                  ),
                ).animate()
                 .fadeIn(delay: 1500.ms)
                 .shimmer(duration: 2.seconds),
              ],
            ),
            
            const SizedBox(height: 80),
            
            // Loading Indicator
            const SizedBox(
              width: 40, 
              height: 40, 
              child: CircularProgressIndicator(
                 color: Colors.purpleAccent, 
                 backgroundColor: Colors.white10,
                 strokeWidth: 2
              )
            ).animate().fadeIn(delay: 2.seconds),
          ],
        ),
      ),
    );
  }
}
