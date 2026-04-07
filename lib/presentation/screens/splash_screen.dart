import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

// SplashScreen — halaman pembuka.
// Referensi UI (hal.10): kartu putih di tengah background merah,
// logo ikon kopi merah di dalam kartu, teks "Teh Tarik Nomad" dua baris
// dengan "Nomad" berwarna merah, tagline di bawah kartu.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // AnimationController mengatur durasi dan status animasi.
  // SingleTickerProviderStateMixin diperlukan agar vsync bekerja —
  // vsync mencegah animasi berjalan di background, hemat baterai.
  late AnimationController _ctrl;
  late Animation<double> _fade;   // opacity 0→1
  late Animation<double> _scale;  // ukuran 0.8→1.0

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    // Tween<double> mendefinisikan nilai awal & akhir animasi
    _fade  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.85, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        Navigator.pushReplacement(context,
          // PageRouteBuilder membuat transisi halaman custom (fade)
          // transitionDuration: durasi animasi perpindahan halaman
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ));
      }
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor merah brand sebagai background penuh
      backgroundColor: const Color(0xFFC0392B),
      body: AnimatedBuilder(
        // AnimatedBuilder — rebuild hanya ketika animasi berubah,
        // lebih efisien dari setState di dalam animasi
        animation: _ctrl,
        builder: (_, __) => FadeTransition(
          opacity: _fade,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Lingkaran dekoratif blur di kiri atas (sesuai referensi)
              Positioned(
                top: -60, left: -60,
                child: Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),

              // Konten tengah
              Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kartu putih putih rounded — berisi logo
                      Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          // boxShadow memberi bayangan di bawah kartu
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 24, offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ikon kopi merah di dalam kartu
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC0392B),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.coffee_rounded,
                                size: 36, color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            // Nama brand dua baris
                            const Text('Teh Tarik',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              )),
                            const Text('Nomad',
                              style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900,
                                color: Color(0xFFC0392B),
                              )),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Tagline bawah kartu
                      const Text('AUTHENTIC TEH & KOPI TIAM',
                        style: TextStyle(
                          fontSize: 11, letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        )),
                      const SizedBox(height: 16),
                      // Garis dekoratif bawah tagline
                      Container(
                        width: 80, height: 1.5,
                        color: Colors.white38,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
