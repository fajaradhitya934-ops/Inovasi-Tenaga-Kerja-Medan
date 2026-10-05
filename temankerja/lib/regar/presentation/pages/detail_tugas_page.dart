import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';
import 'package:inovasi_sumut/regar/core/utils/formatter.dart';
import 'package:inovasi_sumut/regar/data/models/worker_models.dart';
import 'package:inovasi_sumut/regar/data/repositories/worker_repository.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/common/kk_widgets.dart';
import 'package:inovasi_sumut/regar/presentation/widgets/tasks/proof_photo_box.dart';

class DetailTugasPage extends StatefulWidget {
  final WorkTask task;

  const DetailTugasPage({super.key, required this.task});

  @override
  State<DetailTugasPage> createState() => _DetailTugasPageState();
}

class _DetailTugasPageState extends State<DetailTugasPage> {
  late final TextEditingController _note =
      TextEditingController(text: widget.task.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    final ok = workerRepository.submitProof(widget.task, _note.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Bukti kerja terkirim, menunggu verifikasi klien'
              : 'Foto Sesudah (After) wajib diunggah',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KkColors.bg,
      appBar: AppBar(
        backgroundColor: KkColors.bg,
        elevation: 0,
        leading: const BackButton(color: KkColors.text),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            color: KkColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: workerRepository,
          builder: (context, _) {
            final t = widget.task;
            final locked = t.status != TaskStatus.berjalan;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                KkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.status == TaskStatus.selesai
                            ? 'PEKERJAAN SELESAI'
                            : 'PEKERJAAN SEDANG BERJALAN',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: KkColors.green,
                        ),
                      ),
                      Text(
                        t.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      KkInfoBox(label: 'Pemberi Kerja', value: t.client),
                      const SizedBox(height: 8),
                      KkInfoBox(label: 'Lokasi Penugasan', value: t.location),
                      const SizedBox(height: 8),
                      KkInfoBox(
                        label: 'Honor Bersih (Escrow Safe-Pay)',
                        value: rupiah(t.amount),
                        valueColor: KkColors.green,
                        caption: 'Terjamin Aman di Escrow',
                      ),
                    ],
                  ),
                ),
                const KkSectionTitle(
                  Icons.photo_camera_outlined,
                  'Dokumentasi Bukti Kerja (Before & After)',
                ),
                const Text(
                  'Wajib foto kondisi sebelum & sesudah untuk verifikasi pencairan honor.',
                  style: TextStyle(fontSize: 12, color: KkColors.muted),
                ),
                if (!locked) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      label: const Text('Gunakan Contoh Foto Demo'),
                      backgroundColor: KkColors.greenSoft,
                      labelStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: KkColors.green,
                      ),
                      onPressed: () => workerRepository.useDemoPhotos(t),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                ProofPhotoBox(
                  isBefore: true,
                  hasPhoto: t.hasBefore,
                  locked: locked,
                  onPick: () => workerRepository.markBefore(t),
                ),
                const SizedBox(height: 10),
                ProofPhotoBox(
                  isBefore: false,
                  hasPhoto: t.hasAfter,
                  locked: locked,
                  onPick: () => workerRepository.markAfter(t),
                ),
                const SizedBox(height: 14),
                if (t.status == TaskStatus.berjalan) ...[
                  TextField(
                    controller: _note,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan Pengerjaan untuk Pemberi Kerja',
                      hintText:
                          'Contoh: Pekerjaan sudah selesai dirapikan dan dibersihkan',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: KkColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pastikan foto sesudah (*After*) telah terlampir dengan jelas sebelum menyelesaikan tugas.',
                    style: TextStyle(fontSize: 12, color: KkColors.muted),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: KkColors.gold,
                        foregroundColor: KkColors.greenDark,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: _submit,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Kirim Bukti & Selesaikan Pekerjaan'),
                    ),
                  ),
                ],
                if (t.status == TaskStatus.menungguVerifikasi) ...[
                  if (t.note.isNotEmpty)
                    KkCard(
                      child: Text(
                        'Catatan Anda: "${t.note}"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const KkCard(
                    color: Color(0xFFFFF3D6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.auto_awesome, color: KkColors.gold),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Bukti Kerja Sedang Ditinjau Klien. Begitu disetujui, dana honor akan seketika masuk ke saldo dompet Anda.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tombol demo: nanti diganti aksi dari sisi Pemberi Kerja (Bang Fajar).
                  OutlinedButton.icon(
                    onPressed: () {
                      workerRepository.simulateClientApprove(t);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Honor ${rupiah(t.amount)} masuk ke saldo')),
                      );
                    },
                    icon: const Icon(Icons.science_outlined, size: 18),
                    label: const Text('[DEMO] Simulasikan klien menyetujui'),
                  ),
                ],
                if (t.status == TaskStatus.selesai)
                  KkCard(
                    color: KkColors.greenSoft,
                    child: Text(
                      'Selesai. Honor ${rupiah(t.amount)} sudah masuk ke saldo dompet Anda.',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: KkColors.green,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
