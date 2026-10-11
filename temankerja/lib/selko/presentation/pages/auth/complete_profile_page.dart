import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';

class CompleteProfilePage extends StatefulWidget {
  final String uid;
  final String email;

  const CompleteProfilePage({
    super.key,
    required this.uid,
    required this.email,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillsController = TextEditingController();
  final _bioController = TextEditingController();

  String? _selectedLocation;
  String _selectedRole = 'Pencari Kerja';
  bool _isLoading = false;

  // Daftar Kecamatan di Kota Medan
  final List<String> _medanDistricts = [
    'Medan Amplas',
    'Medan Area',
    'Medan Barat',
    'Medan Baru',
    'Medan Belawan',
    'Medan Deli',
    'Medan Denai',
    'Medan Helvetia',
    'Medan Johor',
    'Medan Kota',
    'Medan Labuhan',
    'Medan Maimun',
    'Medan Marelan',
    'Medan Perjuangan',
    'Medan Petisah',
    'Medan Polonia',
    'Medan Rumah Kita',
    'Medan Selayang',
    'Medan Sunggal',
    'Medan Tembung',
    'Medan Timur',
    'Medan Tuntungan',
  ];

  final List<String> _roles = [
    'Pencari Kerja',
    'Penyedia Kerja / Usaha',
    'Pelatih / Mentor',
  ];

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kecamatan/lokasi Anda.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<String> skillsList = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      // Simpan data ke Firestore koleksi 'users'
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).set({
        'uid': widget.uid,
        'email': widget.email,
        'name': _nameController.text.trim(),
        'nik': _nikController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _selectedLocation,
        'role': _selectedRole,
        'skills': skillsList,
        'bio': _bioController.text.trim(),
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil disimpan!')),
      );

      // Kembali atau berpindah ke halaman utama
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Firebase (${e.code}): ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nikController.dispose();
    _phoneController.dispose();
    _skillsController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KkColors.bg,
      appBar: AppBar(
        title: const Text('Lengkapi Profil Kamu'),
        backgroundColor: KkColors.bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Langkah Terakhir!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lengkapi informasi profil agar kamu dapat langsung menggunakannya.',
                  style: TextStyle(color: KkColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Nama Lengkap
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap *',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 16),

                // NIK Wajib
                TextFormField(
                  controller: _nikController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: InputDecoration(
                    labelText: 'Nomor NIK (KTP) *',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'NIK wajib diisi';
                    }
                    if (v.trim().length != 16) {
                      return 'NIK harus berjumlah 16 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nomor WhatsApp
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Nomor WhatsApp *',
                    prefixIcon: const Icon(Icons.phone_android),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nomor WhatsApp wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                // Dropdown Kecamatan / Lokasi
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: InputDecoration(
                    labelText: 'Kecamatan / Lokasi *',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  hint: const Text('Pilih Kecamatan'),
                  items: _medanDistricts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedLocation = val);
                  },
                  validator: (v) => v == null ? 'Pilih kecamatan Anda' : null,
                ),
                const SizedBox(height: 16),

                // Status / Peran
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Status / Peran Utama *',
                    prefixIcon: const Icon(Icons.work_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 16),

                // Keahlian / Skill
                TextFormField(
                  controller: _skillsController,
                  decoration: InputDecoration(
                    labelText: 'Keahlian / Skill (pisahkan dengan koma)',
                    prefixIcon: const Icon(Icons.star_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Bio Singkat
                TextFormField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Bio Singkat / Pengalaman Kerja',
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(Icons.notes_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Simpan Profil
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: KkColors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading ? null : _saveProfile,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan Profil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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