import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';

/// Kotak foto bukti kerja (Before / After).
/// Sekarang masih tampilan contoh; nanti [onPick] dihubungkan ke image_picker.
class ProofPhotoBox extends StatelessWidget {
  final bool isBefore;
  final bool hasPhoto;
  final bool locked;
  final VoidCallback onPick;

  const ProofPhotoBox({
    super.key,
    required this.isBefore,
    required this.hasPhoto,
    required this.locked,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isBefore ? const Color(0xFFDDE1F0) : const Color(0xFFD3EBC3);
    final tag = isBefore ? 'BEFORE' : 'AFTER (SELESAI)';
    final text = isBefore
        ? 'FOTO SEBELUM PENGERJAAN\nKondisi Awal / Rusak'
        : 'FOTO SESUDAH SELESAI\nKondisi Bersih & Rapi';

    return KkCard(
      color: const Color(0xFFF7F4E6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isBefore ? 'Foto Sebelum (Before):' : 'Foto Sesudah (After):',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              if (!isBefore)
                const Text(
                  ' *Wajib',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: KkColors.red,
                  ),
                ),
              const Spacer(),
              Text(
                isBefore ? 'Kondisi Awal' : 'Selesai Rapi',
                style: const TextStyle(fontSize: 10, color: KkColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: KkColors.border),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    color: KkColors.greenDark,
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    hasPhoto ? text : 'Belum ada foto',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: KkColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!locked) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPick,
                style: OutlinedButton.styleFrom(
                  foregroundColor: KkColors.text,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: KkColors.border),
                ),
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(
                  isBefore
                      ? 'Ambil / Unggah Foto Sebelum'
                      : 'Ambil / Unggah Foto Sesudah',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
