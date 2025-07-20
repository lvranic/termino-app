import 'package:flutter/material.dart';

class ReservationDateScreen extends StatefulWidget {
  final String serviceId;

  const ReservationDateScreen({super.key, required this.serviceId});

  @override
  State<ReservationDateScreen> createState() => _ReservationDateScreenState();
}

class _ReservationDateScreenState extends State<ReservationDateScreen> {
  DateTime? _selectedDate;

  void _goToTimeSelection() {
    if (_selectedDate == null) return;

    Navigator.pushNamed(
      context,
      '/select_time', // ✅ Ispravna ruta prema main.dart
      arguments: {
        'serviceId': widget.serviceId,
        'selectedDate': _selectedDate,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Odaberi datum', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 📅 KALENDAR unutar bijelog okvira i s temom koja koristi zelene brojeve
            Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Theme(
                data: Theme.of(context).copyWith(
                  textTheme: Theme.of(context).textTheme.copyWith(
                    bodyLarge: const TextStyle(color: Colors.green),
                    bodyMedium: const TextStyle(color: Colors.green),
                  ),
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: Colors.green, // boja odabranog datuma
                    onPrimary: Colors.white, // tekst na odabranom datumu
                    onSurface: Color(0xFFC3F44D), // boja dana
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  onDateChanged: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Gumb u bijelom okviru
            Container(
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: _selectedDate != null ? _goToTimeSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3F44D),
                  foregroundColor: const Color(0xFF1A434E),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                ),
                child: const Text('Dalje na odabir termina'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}