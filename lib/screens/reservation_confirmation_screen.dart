import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationConfirmationScreen extends StatefulWidget {
  final String serviceId;
  final DateTime selectedDate;
  final String selectedTime;

  const ReservationConfirmationScreen({
    super.key,
    required this.serviceId,
    required this.selectedDate,
    required this.selectedTime,
  });

  @override
  State<ReservationConfirmationScreen> createState() => _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState extends State<ReservationConfirmationScreen> {
  String? serviceName;
  int? durationMinutes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServiceName();
  }

  Future<void> _fetchServiceName() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('services').doc(widget.serviceId).get();
      final data = doc.data();
      setState(() {
        serviceName = data?['name'] ?? 'Nepoznata usluga';
        durationMinutes = data?['durationMinutes'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        serviceName = 'Nepoznata usluga';
        durationMinutes = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Potvrda rezervacije', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFFC3F44D), size: 80),
              const SizedBox(height: 24),
              const Text(
                'Rezervacija uspješna!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text(
                'Usluga: $serviceName',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Datum: ${widget.selectedDate.day}.${widget.selectedDate.month}.${widget.selectedDate.year}',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Vrijeme: ${widget.selectedTime}',
                style: const TextStyle(color: Colors.white70),
              ),
              if (durationMinutes != null)
                Text(
                  'Trajanje: $durationMinutes minuta',
                  style: const TextStyle(color: Colors.white70),
                ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/user-dashboard'));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC3F44D),
                  foregroundColor: const Color(0xFF1A434E),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Natrag na početnu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}