import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      body: SafeArea(
        child: Stack(
          children: [
            // Veliki žuti krug
            Positioned(
              top: 30,
              left: 15,
              child: Container(
                width: 400,
                height: 400,
                decoration: const BoxDecoration(
                  color: Color(0xFFC3F44D),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Sadržaj
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'TERMINO',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Sofadi One',
                        color: Color(0xFF1A434E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'rješenje za sve vaše dogovore',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Sofadi One',
                        color: Color(0xFF1A434E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 80),
                    _buildButton(
                      text: 'Registriraj se',
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      text: 'Prijavi se',
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                    ),
                    const SizedBox(height: 16),
                    _buildButton(
                      text: 'Pružatelji usluge',
                      onPressed: () => Navigator.pushNamed(context, '/admin-register'),
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

  Widget _buildButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC3F44D),
          foregroundColor: const Color(0xFF1A434E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Sofadi One',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}