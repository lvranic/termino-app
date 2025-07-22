import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
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
      // Dohvati sve usluge koje pruža admin
      final servicesSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .where('adminId', isEqualTo: user.uid)
          .get();

      final serviceIds = servicesSnapshot.docs.map((doc) => doc.id).toList();

      if (serviceIds.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      // Dohvati sve rezervacije za te usluge
      final reservationsSnapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('serviceId', whereIn: serviceIds)
          .get();

      List<Map<String, dynamic>> temp = [];

      for (var doc in reservationsSnapshot.docs) {
        final data = doc.data();

        final rawDate = data['date'];
        DateTime? date;
        if (rawDate is Timestamp) {
          date = rawDate.toDate();
        } else if (rawDate is String) {
          date = DateTime.tryParse(rawDate);
        }

        if (date == null) continue;

        final String time = data['time'] ?? '';
        final String userId = data['userId'] ?? '';
        final String docId = doc.id;

        // Dohvati ime korisnika
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userName = userDoc.data()?['name'] ?? 'Nepoznati korisnik';

        temp.add({
          'docId': docId,
          'date': date,
          'time': time,
          'userName': userName,
        });
      }

      setState(() {
        reservations = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('⚠️ Greška: $e');
    }
  }

  Future<void> _cancelReservation(String docId) async {
    final razlogController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Otkazivanje termina'),
        content: TextField(
          controller: razlogController,
          decoration: const InputDecoration(hintText: 'Unesite razlog otkazivanja'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Odustani')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Otkazi')),
        ],
      ),
    );

    if (confirmed != true || razlogController.text.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('reservations').doc(docId).update({
        'status': 'cancelled',
        'cancelReason': razlogController.text.trim(),
        'cancelledAt': Timestamp.now(),
      });

      setState(() {
        reservations.removeWhere((r) => r['docId'] == docId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Termin otkazan')),
      );
    } catch (e) {
      debugPrint('❌ Neuspješno otkazivanje: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Rezervirani termini', style: TextStyle(color: Color(0xFFC3F44D))),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC3F44D)),
            onPressed: () {
              Navigator.pushNamed(context, '/admin-settings');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : reservations.isEmpty
          ? const Center(child: Text('Nema rezervacija', style: TextStyle(color: Colors.white)))
          : ListView.builder(
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final r = reservations[index];
          final date = r['date'] as DateTime;

          return Card(
            margin: const EdgeInsets.all(10),
            color: Color(0xFFC3F44D),
            child: ListTile(
              title: Text('${r['userName']} - ${date.day}.${date.month}.${date.year} u ${r['time']}'),
              trailing: IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => _cancelReservation(r['docId']),
              ),
            ),
          );
        },
      ),
    );
  }
}