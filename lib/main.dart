import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/admin_register_screen.dart';
import 'screens/admin_setup_screen.dart';
import 'screens/reservation_date_screen.dart';
import 'screens/reservation_time_screen.dart';
import 'screens/reservation_confirmation_screen.dart';
import 'screens/user_details_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/my_appointments_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/user_settings_screen.dart';
import 'screens/add_services_screen.dart';
import 'screens/select_service_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Termino',
      theme: ThemeData(
        fontFamily: 'Sofadi One',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-register': (context) => const AdminRegisterScreen(isAdmin: true),
        '/admin-setup': (context) => const AdminSetupScreen(),
        '/user-details': (context) => const UserDetailsScreen(),
        '/select-date': (context) => const ReservationDateScreen(serviceId: ''),
        '/select_time': (context) => const ReservationTimeScreen(),
        '/user-dashboard': (context) => const UserDashboardScreen(),
        '/my-appointments': (context) => const MyAppointmentsScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-settings': (context) => const AdminSettingsScreen(),
        '/user-settings': (context) => const UserSettingsScreen(),
        '/add-services': (context) => const AddServicesScreen(),
        '/select-service': (context) => const SelectServiceScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/confirm') {
          final args = settings.arguments as Map;

          return MaterialPageRoute(
            builder: (context) => ReservationConfirmationScreen(
              serviceId: args['serviceId'],
              selectedDate: args['selectedDate'],
              selectedTime: args['selectedTime'],
            ),
          );
        }

        return null; // fallback ako ruta nije pronađena
      },
    );
  }
}