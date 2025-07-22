import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  DateTime? selectedUnavailableDate;
  bool isLoading = true;

  String? serviceId;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Dohvati korisnika
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    _nameController.text = userDoc.data()?['name'] ?? '';
    _phoneController.text = userDoc.data()?['phone'] ?? '';

    // Dohvati uslugu
    final serviceSnapshot = await FirebaseFirestore.instance
        .collection('services')
        .where('adminId', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (serviceSnapshot.docs.isNotEmpty) {
      final serviceData = serviceSnapshot.docs.first.data();
      serviceId = serviceSnapshot.docs.first.id;
      _addressController.text = serviceData['address'] ?? '';
      _workingHoursController.text = serviceData['workingHours'] ?? '';
    }

    setState(() => isLoading = false);
  }

  Future<void> _saveData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Ažuriraj korisnika
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    // Ažuriraj uslugu
    if (serviceId != null) {
      await FirebaseFirestore.instance.collection('services').doc(serviceId).update({
        'address': _addressController.text.trim(),
        'workingHours': _workingHoursController.text.trim(),
      });
    }

    // Spremi neradni dan ako je odabran
    if (selectedUnavailableDate != null) {
      await FirebaseFirestore.instance.collection('unavailable_days').add({
        'adminId': user.uid,
        'date': Timestamp.fromDate(selectedUnavailableDate!),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Podaci su ažurirani')),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        selectedUnavailableDate = picked;
      });
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType inputType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFC3F44D)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Postavke', style: TextStyle(color: Color(0xFFC3F44D))),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Ime'),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Broj mobitela', inputType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildTextField(_addressController, 'Adresa'),
            const SizedBox(height: 20),
            _buildTextField(_workingHoursController, 'Radno vrijeme (npr. 9-17)'),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Dodaj neradni dan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
              ),
            ),
            if (selectedUnavailableDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Odabrano: ${selectedUnavailableDate!.day}.${selectedUnavailableDate!.month}.${selectedUnavailableDate!.year}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _saveData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC3F44D),
                foregroundColor: const Color(0xFF1A434E),
              ),
              child: const Text('Spremi promjene'),
            ),
          ],
        ),
      ),
    );
  }
}