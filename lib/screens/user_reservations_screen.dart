import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationTimeScreen extends StatefulWidget {
  const ReservationTimeScreen({super.key});

  @override
  State<ReservationTimeScreen> createState() => _ReservationTimeScreenState();
}

class _ReservationTimeScreenState extends State<ReservationTimeScreen> {
  String? serviceId;
  DateTime? selectedDate;
  List<String> bookedTimes = [];
  String? workingHours;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    serviceId = args?['serviceId'];
    selectedDate = args?['selectedDate'];
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (serviceId == null || selectedDate == null) return;

    final serviceDoc = await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
    setState(() {
      workingHours = serviceDoc.data()?['workingHours'];
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('serviceId', isEqualTo: serviceId)
        .where('date', isEqualTo: Timestamp.fromDate(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)))
        .get();

    setState(() {
      bookedTimes = snapshot.docs.map((doc) => doc['time'] as String).toList();
    });
  }

  List<String> _generateTimeSlots(String workingHours) {
    final parts = workingHours.split('-');
    final start = int.tryParse(parts[0]);
    final end = int.tryParse(parts[1]);
    if (start == null || end == null || end <= start) return [];

    return List.generate(end - start, (i) => '${start + i}:00');
  }

  void _bookTime(String time) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || serviceId == null || selectedDate == null) return;

    final reservation = {
      'userId': user.uid,
      'serviceId': serviceId,
      'date': Timestamp.fromDate(DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day)),
      'time': time,
      'createdAt': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('reservations').add(reservation);

    Navigator.pushNamed(context, '/confirm', arguments: {
      'serviceId': serviceId,
      'selectedDate': selectedDate,
      'time': time,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (workingHours == null || selectedDate == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A434E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final timeSlots = _generateTimeSlots(workingHours!);

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
              'Dostupni termini za ${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final time = timeSlots[index];
                  final isBooked = bookedTimes.contains(time);

                  return Card(
                    color: isBooked ? Colors.grey.shade700 : Colors.white,
                    child: ListTile(
                      title: Text(
                        'Termin u $time',
                        style: TextStyle(
                          color: isBooked ? Colors.white54 : Colors.black,
                        ),
                      ),
                      enabled: !isBooked,
                      onTap: isBooked ? null : () => _bookTime(time),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}