import 'package:flutter/material.dart';
import 'package:inovasi_sumut/app/pages/home_page.dart';
import 'package:inovasi_sumut/app/pages/profil_page.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/presentation/pages/pusat_pekerjaan_page.dart';

/// Kerangka utama aplikasi: 3 tab, dipasang sekali di paling luar.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KkColors.bg,
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onGoActivity: () => _go(1)),
          const PusatPekerjaanPage(),
          const ProfilPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: Colors.white,
        indicatorColor: KkColors.greenSoft,
        onDestinationSelected: _go,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: KkColors.green),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work, color: KkColors.green),
            label: 'Aktivitas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: KkColors.green),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
