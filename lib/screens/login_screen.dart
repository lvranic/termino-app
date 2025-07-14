import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFC3F44D)),
          onPressed: () => Navigator.pop(context),
        )
            : null, // Ako je landing početni screen, neće prikazati gumb
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'TERMINO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontFamily: 'Sofadi One',
                  color: Color(0xFFC3F44D),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'rješenje za sve vaše dogovore',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'Sofadi One',
                  color: Color(0xFFC3F44D),
                ),
              ),
              const SizedBox(height: 64),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white24,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Lozinka',
                  labelStyle: TextStyle(color: Colors.white),
                  fillColor: Colors.white24,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Ovdje ide login logika (Firebase)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login nije još implementiran')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3F44D),
                  foregroundColor: const Color(0xFF1A434E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                child: const Text(
                  'Prijavi se',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Sofadi One',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigacija na "zaboravljena lozinka" ako bude
                },
                child: const Text(
                  'Zaboravio/la si lozinku?',
                  style: TextStyle(
                    color: Color(0xFFC3F44D),
                    fontFamily: 'Sofadi One',
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