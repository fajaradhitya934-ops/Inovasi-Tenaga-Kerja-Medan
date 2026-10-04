import 'package:flutter/material.dart';
import '../../../core/constant/app_colors.dart';

// ================= 1. KOMPONEN TAWARKAN KERJA =================
class TawarkanKerjaCard extends StatelessWidget {
  final VoidCallback? onTap;

  const TawarkanKerjaCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BaseServiceCard(
      title: 'Tawarkan Kerja',
      subtitle: 'Lengkapi profil & tawarkan skill',
      icon: Icons.work_outline_rounded,
      badgeColor: Colors.green.shade100,
      iconColor: AppColors.medanGreen,
      onTap: onTap,
    );
  }
}

// ================= 2. KOMPONEN GOTONG ROYONG =================
class GotongRoyongCard extends StatelessWidget {
  final VoidCallback? onTap;

  const GotongRoyongCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BaseServiceCard(
      title: 'Gotong Royong',
      subtitle: 'Proyek sosial & aksi masyarakat',
      icon: Icons.people_alt_outlined,
      badgeColor: Colors.orange.shade100,
      iconColor: Colors.deepOrange,
      onTap: onTap,
    );
  }
}

// ================= 3. KOMPONEN TUKAR SKILL =================
class TukarSkillCard extends StatelessWidget {
  final VoidCallback? onTap;

  const TukarSkillCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BaseServiceCard(
      title: 'Tukar Skill',
      subtitle: 'Barter keahlian tanpa uang',
      icon: Icons.published_with_changes_rounded,
      badgeColor: Colors.purple.shade100,
      iconColor: Colors.purple,
      onTap: onTap,
    );
  }
}

// ================= BASE REUSABLE CARD (INTERNAL) =================
class _BaseServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color badgeColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _BaseServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}