// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/screens/services/cart_service.dart';
import 'screens/role_selection_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/patient/patient_dashboard.dart';
import 'screens/doctor/doctor_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://dtxnkfcmbhhgpazvzaty.supabase.co', // Replace with your Supabase URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR0eG5rZmNtYmhoZ3BhenZ6YXR5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2ODk1NDQsImV4cCI6MjA4MzI2NTU0NH0.SrHEmlOJ3BEF318O3gKikockQzkYMB3MsusBjPAjOWo', // Replace with your Supabase anon key
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartService(),
      child: MyApp(),
    ),
  );
}

// Global Supabase client
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hospital Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),
      ),
      home: RoleSelectionScreen(),
      routes: {
        '/role-selection': (context) => RoleSelectionScreen(),
        '/patient-dashboard': (context) => PatientDashboard(),
        '/doctor-dashboard': (context) => DoctorDashboard(),
        '/admin-dashboard': (context) => AdminDashboard(),
      },
    );
  }
}