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
  int durationMinutes = 60;
  bool isLoading = true;
  Set<int> blockedSlots = {};
  int? selectedHour;
  late String adminId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    serviceId = args?['serviceId'];
    selectedDate = args?['selectedDate'];
    _loadData();
  }

  Future<void> _loadData() async {
    await _fetchServiceInfo();
    await _fetchBookedSlots();
    setState(() => isLoading = false);
    //late String adminId;
  }

  Future<void> _fetchServiceInfo() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
      final data = doc.data();
      final hours = data?['workingHours'] ?? '9-17h';
      durationMinutes = data?['durationMinutes'] ?? 60;
      adminId = data?['adminId'];

      final parts = hours.replaceAll('h', '').split('-');
      if (parts.length == 2) {
        startHour = int.tryParse(parts[0].trim()) ?? 9;
        endHour = int.tryParse(parts[1].trim()) ?? 17;
      }
    } catch (e) {
      debugPrint('❌ Greška kod učitavanja usluge: $e');
    }
  }

  Future<void> _fetchBookedSlots() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('date', isEqualTo: Timestamp.fromDate(
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day)))
          .get();

      final blocked = <int>{};

      for (var doc in snapshot.docs) {
        final resServiceId = doc['serviceId'];
        final resDoc = await FirebaseFirestore.instance.collection('services').doc(resServiceId).get();
        final resData = resDoc.data();
        if (resData == null) continue;

        final resAdminId = resData['adminId'];
        if (resAdminId != adminId) continue; // 👈 gledaj samo rezervacije istog pružatelja usluge

        final hour = doc['hour'] as int?;
        final duration = doc['durationMinutes'] ?? 60;

        if (hour != null) {
          final blocks = (duration / 60).ceil(); // zaokruži npr. 90min na 2 sata
          for (int i = 0; i < blocks; i++) {
            blocked.add(hour + i);
          }
        }
      }

      blockedSlots = blocked;
    } catch (e) {
      debugPrint('❌ Greška kod dohvaćanja rezervacija: $e');
    }
  }

  void _confirmReservation() async {
    if (selectedHour == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = {
      'userId': user.uid,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)),
      'time': '$selectedHour:00',
      'hour': selectedHour,
      'durationMinutes': durationMinutes,
      'createdAt': Timestamp.now(),
    };
    debugPrint('🔍 Spremanje rezervacije s trajanjem: $durationMinutes minuta');

    try {
      await FirebaseFirestore.instance.collection('reservations').add(data);

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

  bool _isSlotAvailable(int hour) {
    final slotsNeeded = (durationMinutes / 60).ceil();
    for (int i = 0; i < slotsNeeded; i++) {
      if (blockedSlots.contains(hour + i)) return false;
    }
    return hour + slotsNeeded <= endHour;
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
                  final available = _isSlotAvailable(hour);
                  final isSelected = selectedHour == hour;

                  return Card(
                    color: !available
                        ? Colors.grey.shade700
                        : isSelected
                        ? const Color(0xFFC3F44D)
                        : Colors.white,
                    child: ListTile(
                      title: Text(
                        'Termin u $hour:00',
                        style: TextStyle(
                          color: !available
                              ? Colors.white54
                              : isSelected
                              ? const Color(0xFF1A434E)
                              : Colors.black,
                        ),
                      ),
                      enabled: available,
                      onTap: available
                          ? () => setState(() => selectedHour = hour)
                          : null,
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