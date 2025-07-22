import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import '../models/service_model.dart'; // ako koristiš poseban model za uslugu

class ReservationDateScreen extends StatefulWidget {
  final String serviceId;

  const ReservationDateScreen({super.key, required this.serviceId});

  @override
  State<ReservationDateScreen> createState() => _ReservationDateScreenState();
}

class _ReservationDateScreenState extends State<ReservationDateScreen> {
  DateTime? _selectedDate;
  List<DateTime> _unavailableDates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnavailableDates();
  }

  Future<void> _loadUnavailableDates() async {
    try {
      // Dohvati uslugu
      final serviceSnapshot = await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .get();

      final adminId = serviceSnapshot.data()?['adminId'];

      if (adminId == null) {
        setState(() => isLoading = false);
        return;
      }

      final unavailableSnapshot = await FirebaseFirestore.instance
          .collection('unavailable_days')
          .where('adminId', isEqualTo: adminId)
          .get();

      setState(() {
        _unavailableDates = unavailableSnapshot.docs
            .map((doc) => (doc.data()['date'] as Timestamp).toDate())
            .toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Greška prilikom dohvaćanja neradnih dana: $e');
      setState(() => isLoading = false);
    }
  }

  bool _isDateSelectable(DateTime day) {
    // Nedjelja
    if (day.weekday == DateTime.sunday) return false;

    // Je li dan među zabranjenima
    for (final unavailable in _unavailableDates) {
      if (unavailable.year == day.year &&
          unavailable.month == day.month &&
          unavailable.day == day.day) {
        return false;
      }
    }

    return true;
  }

  void _goToTimeSelection() {
    if (_selectedDate == null) return;

    Navigator.pushNamed(
      context,
      '/select_time',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 📅 KALENDAR
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
                    primary: Colors.green,
                    onPrimary: Colors.white,
                    onSurface: const Color(0xFFC3F44D),
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  onDateChanged: (date) {
                    setState(() => _selectedDate = date);
                  },
                  selectableDayPredicate: _isDateSelectable,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Gumb
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