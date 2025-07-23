import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Future<List<QueryDocumentSnapshot>>? _adminsFuture;

  @override
  void initState() {
    super.initState();
    _loadAdmins();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _loadAdmins();
      });
    });
  }

  void _loadAdmins() {
    _adminsFuture = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get()
        .then((snapshot) => snapshot.docs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSelectServiceScreen(String adminId, String adminName) {
    Navigator.pushNamed(
      context,
      '/select-service',
      arguments: {
        'providerId': adminId,
        'providerName': adminName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A434E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A434E),
        title: const Text('Dobrodošli', style: TextStyle(color: Color(0xFFC3F44D))),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFC3F44D)),
            onPressed: () {
              Navigator.pushNamed(context, '/user-settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFC3F44D)),
            onPressed: () {
              // TODO: Odjava
            },
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pretraži pružatelje usluga',
                  style: TextStyle(color: Color(0xFFC3F44D), fontSize: 20, fontFamily: 'Sofadi One')),
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Upiši ime pružatelja...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Svi pružatelji',
                  style: TextStyle(color: Color(0xFFC3F44D), fontSize: 18, fontFamily: 'Sofadi One')),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: _adminsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Nema dostupnih pružatelja.', style: TextStyle(color: Colors.white70)));
                    }

                    final filteredDocs = _searchQuery.isEmpty
                        ? snapshot.data!
                        : snapshot.data!.where((doc) {
                      final name = doc['name']?.toString().toLowerCase() ?? '';
                      return name.contains(_searchQuery);
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      return const Center(
                          child: Text('Nema rezultata pretrage.', style: TextStyle(color: Colors.white70)));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final admin = filteredDocs[index];
                        final name = admin['name'] ?? 'Nepoznato';

                        return _ServiceCard(
                          title: name,
                          onTap: () => _openSelectServiceScreen(admin.id, name),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text('Trending',
                  style: TextStyle(color: Color(0xFFC3F44D), fontSize: 18, fontFamily: 'Sofadi One')),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: NetworkImage('https://placehold.co/60x60'),
                    ),
                    title: Text('Popularni ${index + 1}',
                        style: const TextStyle(color: Colors.white)),
                    subtitle: const Text('Broj rezervacija: 120',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/my-appointments');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3F44D),
                    foregroundColor: const Color(0xFF1A434E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  child: const Text(
                    'Rezervirani termini',
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ServiceCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store, size: 40, color: Color(0xFFC3F44D)),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFFC3F44D), fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}