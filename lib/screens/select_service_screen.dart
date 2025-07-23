import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'reservation_date_screen.dart';

class SelectServiceScreen extends StatelessWidget {
  const SelectServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args == null || args['providerId'] == null) {
      return const Scaffold(
        body: Center(child: Text('Greška: Pružatelj nije pronađen')),
      );
    }

    final String providerId = args['providerId'];
    final String providerName = args['providerName'] ?? 'Pružatelj';

    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: Text('Usluge: $providerName', style: const TextStyle(color: Color(0xFFC3F44D))),
        iconTheme: const IconThemeData(color: Color(0xFFC3F44D)),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('services')
            .where('adminId', isEqualTo: providerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('Nema dostupnih usluga', style: TextStyle(color: Colors.white)));
          }

          final services = snapshot.data!.docs;

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final data = services[index].data() as Map<String, dynamic>;
              final name = data['name'] ?? 'Usluga';
              final duration = data['duration'] ?? 60; // minuta
              final serviceId = services[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFC3F44D),
                child: ListTile(
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Trajanje: $duration min'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservationDateScreen(
                          serviceId: serviceId,
                          durationMinutes: duration,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}