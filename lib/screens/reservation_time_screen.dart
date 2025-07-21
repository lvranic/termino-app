import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReservationTimeScreen extends StatefulWidget {
  const ReservationTimeScreen({super.key});

  @override
  State<ReservationTimeScreen> createState() => _ReservationTimeScreenState();
}

class _ReservationTimeScreenState extends State<ReservationTimeScreen> {
  late String serviceId;
  late DateTime selectedDate;
  int startHour = 9;
  int endHour = 17;
  bool isLoading = true;
  Set<int> bookedHours = {};
  int? selectedHour; // ← DODANO

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    serviceId = args?['serviceId'];
    selectedDate = args?['selectedDate'];
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchWorkingHours();
    await _fetchBookedTimes();
    setState(() => isLoading = false);
  }

  Future<void> _fetchWorkingHours() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
      final data = doc.data();
      final hours = data?['workingHours'] ?? '9-17h';

      final parts = hours.replaceAll('h', '').split('-');
      if (parts.length == 2) {
        startHour = int.tryParse(parts[0].trim()) ?? 9;
        endHour = int.tryParse(parts[1].trim()) ?? 17;
      }
    } catch (e) {
      debugPrint('Greška kod radnog vremena: $e');
    }
  }

  Future<void> _fetchBookedTimes() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('serviceId', isEqualTo: serviceId)
          .where('date', isEqualTo: formattedDate)
          .get();

      for (var doc in snapshot.docs) {
        final hour = int.tryParse(doc['hour'].toString());
        if (hour != null) bookedHours.add(hour);
      }
    } catch (e) {
      debugPrint('Greška kod dohvaćanja rezervacija: $e');
    }
  }

  void _confirmReservation() async {
    if (selectedHour == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reservationData = {
      'userId': user.uid,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(selectedDate),
      'time': '$selectedHour:00',
      'hour': selectedHour,
      'createdAt': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance.collection('reservations').add(reservationData);

      Navigator.pushNamed(context, '/confirm', arguments: {
        'serviceId': serviceId,
        'selectedDate': selectedDate,
        'selectedTime': '$selectedHour:00',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Greška prilikom spremanja rezervacije.')),
      );
      debugPrint('❌ Greška pri spremanju rezervacije: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A434E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Odaberi vrijeme', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Dostupni termini za ${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: endHour - startHour,
                itemBuilder: (context, index) {
                  final hour = startHour + index;
                  final time = '$hour:00';
                  final isBooked = bookedHours.contains(hour);
                  final isSelected = selectedHour == hour;

                  return Card(
                    color: isBooked
                        ? Colors.grey.shade700
                        : isSelected
                        ? const Color(0xFFC3F44D)
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        'Termin u $time',
                        style: TextStyle(
                          color: isBooked
                              ? Colors.white54
                              : isSelected
                              ? const Color(0xFF1A434E)
                              : Colors.black,
                        ),
                      ),
                      enabled: !isBooked,
                      onTap: isBooked
                          ? null
                          : () {
                        setState(() => selectedHour = hour);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: selectedHour != null ? _confirmReservation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Rezerviraj termin'),
            ),
          ],
        ),
      ),
    );
  }
}