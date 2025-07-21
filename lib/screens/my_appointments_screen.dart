import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final _auth = FirebaseAuth.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .get();
      print('📦 Broj pronađenih rezervacija: ${snapshot.docs.length}');

      List<Map<String, dynamic>> temp = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        DateTime? date;

        final rawDate = data['date'];
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is String) {
          date = DateTime.tryParse(rawDate);
        }

        if (date == null) continue;
        final String time = data['time'] ?? '';
        final String serviceId = data['serviceId'] ?? '';

        final serviceDoc = await FirebaseFirestore.instance.collection('services').doc(serviceId).get();
        final serviceName = serviceDoc.data()?['name'] ?? 'Nepoznata usluga';

        temp.add({
          'serviceName': serviceName,
          'date': date,
          'time': time,
        });
      }

      setState(() {
        reservations = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Greška pri učitavanju rezervacija: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Moji termini', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : reservations.isEmpty
          ? const Center(
        child: Text(
          'Nemate rezerviranih termina.',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final res = reservations[index];
          final date = res['date'] as DateTime;

          return Card(
            margin: const EdgeInsets.all(10),
            color: Color(0xFFC3F44D),
            child: ListTile(
              title: Text(res['serviceName']),
              subtitle: Text(
                '${date.day}.${date.month}.${date.year} u ${res['time']}',
              ),
            ),
          );
        },
      ),
    );
  }
}