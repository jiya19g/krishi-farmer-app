import 'package:farmer_app/screens/cropCal.dart';
import 'package:farmer_app/screens/cropRec.dart';
import 'package:farmer_app/screens/register_screen.dart';
import 'package:farmer_app/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:farmer_app/screens/splash.dart';
import 'package:farmer_app/screens/login_screen.dart';
import 'package:farmer_app/screens/main_screen.dart';
import 'package:farmer_app/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

 @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Smart Farming',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: const AuthWrapper(),
        routes: {
          '/crop_recommendation': (context) => const CropRecommendationScreen(),
          '/crop_calendar': (context) => const CropCalendarScreen(),
          // Add other routes if needed
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          
          if (user == null) {
            return const LoginRegisterWrapper();
          }
          return const MainScreen(); // Directly go to MainScreen after login
        }
        
        // Show loading indicator while checking auth state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class LoginRegisterWrapper extends StatefulWidget {
  const LoginRegisterWrapper({Key? key}) : super(key: key);

  @override
  _LoginRegisterWrapperState createState() => _LoginRegisterWrapperState();
}

class _LoginRegisterWrapperState extends State<LoginRegisterWrapper> {
  bool showSignIn = true;

  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showSignIn
          ? LoginScreen(toggleView: toggleView)
          : RegisterScreen(toggleView: toggleView),
    );
  }
}