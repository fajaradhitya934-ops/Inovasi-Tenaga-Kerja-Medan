import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';

class KkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  const KkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color = Colors.white,
    this.borderColor = KkColors.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: borderColor),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class KkPill extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;

  const KkPill(
    this.text, {
    super.key,
    this.bg = KkColors.greenSoft,
    this.fg = KkColors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class KkSectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget? trailing;

  const KkSectionTitle(this.icon, this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: KkColors.green),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: KkColors.text,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Kotak krem kecil berisi label + nilai (dipakai di kartu tugas).
class KkInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final String? caption;

  const KkInfoBox({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = KkColors.text,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: KkColors.inner,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: KkColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, color: KkColors.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined,
                    size: 13, color: KkColors.green),
                const SizedBox(width: 4),
                Text(caption!,
                    style:
                        const TextStyle(fontSize: 11, color: KkColors.green)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class KkHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final int notifCount;

  const KkHeader({super.key, this.onBack, this.notifCount = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: KkColors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'M',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEDAN TALENTA',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: KkColors.text,
                ),
              ),
              Text(
                'KOTA MEDAN',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: KkColors.green,
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            _RoundIcon(icon: Icons.notifications_none, onTap: () {}),
            if (notifCount > 0)
              Positioned(
                right: -4,
                top: -6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: KkColors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$notifCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (onBack != null) ...[
          const SizedBox(width: 8),
          _RoundIcon(icon: Icons.arrow_back, onTap: onBack!),
        ],
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KkColors.border),
        ),
        child: Icon(icon, size: 20, color: KkColors.text),
      ),
    );
  }
}
