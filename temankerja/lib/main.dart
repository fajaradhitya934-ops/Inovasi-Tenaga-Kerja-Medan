import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/app/app_shell.dart';
import 'package:inovasi_sumut/firebase_options.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/selko/presentation/pages/auth/complete_profile_page.dart';
import 'package:inovasi_sumut/selko/presentation/pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase dengan DefaultFirebaseOptions
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEDAN TALENTA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: KkColors.green),
        scaffoldBackgroundColor: KkColors.bg,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: KkColors.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        snackBarTheme:
            const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: KkColors.green),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        // Menggunakan StreamBuilder Realtime untuk mendengarkan perubahan data profil user
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: KkColors.green),
                ),
              );
            }

            final data = profileSnapshot.data?.data();

            // Auto-Initialize Field Statistik di Firestore jika belum ada
            if (data != null &&
                (!data.containsKey('completedJobs') ||
                 !data.containsKey('socialProjects') ||
                 !data.containsKey('cpPoints'))) {
              FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'completedJobs': data['completedJobs'] ?? 0,
                'socialProjects': data['socialProjects'] ?? 0,
                'cpPoints': data['cpPoints'] ?? 0,
              }, SetOptions(merge: true));
            }

            final isComplete = data?['isProfileComplete'] as bool? ?? false;

            if (!isComplete) {
              return CompleteProfilePage(
                uid: user.uid,
                email: user.email ?? '',
              );
            }

            return const AppShell();
          },
        );
      },
    );
  }
}