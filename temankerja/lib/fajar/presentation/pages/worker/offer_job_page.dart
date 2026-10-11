import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inovasi_sumut/regar/core/constant/kk_colors.dart';

enum PostMode { offerService, hireWorker }

class OfferJobPage extends StatefulWidget {
  const OfferJobPage({super.key});

  @override
  State<OfferJobPage> createState() => _OfferJobPageState();
}

class _OfferJobPageState extends State<OfferJobPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();

  // Mode Default: Cari Pekerja (Buka Lowongan)
  PostMode _postMode = PostMode.hireWorker;

  String _selectedCategory = 'Pertanian & Perkebunan';
  String _selectedDistrict = 'Medan Kota';
  String _selectedPaymentType = 'cash';
  bool _requiresOwnTools = true;
  String _selectedMobility = 'Motor Sendiri';

  // Tanggal Pelaksanaan Pekerjaan (Default: Hari Ini)
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _categories = [
    'Pertanian & Perkebunan',
    'Pertukangan',
    'Kebersihan',
    'Elektronik & IT',
    'Media & Kreatif',
    'Jasa Umum',
    'Lainnya',
  ];

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
    'Medan Selayang',
    'Medan Sunggal',
    'Medan Tembung',
    'Medan Timur',
    'Medan Tuntungan',
  ];

  final List<String> _mobilityOptions = [
    'Motor Sendiri',
    'Mobil Sendiri',
    'Transportasi Umum',
    'Tidak Wajib / Bebas',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _formatRupiah(double val) {
    return 'Rp ${val.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  // Helper Format Tanggal Indonesia (Perbaikan Sintaks)
  String _formatDate(DateTime date) {
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: KkColors.green,
              onPrimary: Colors.white,
              onSurface: KkColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double rawPrice = double.tryParse(_priceController.text) ?? 0.0;
      final double appFee = 1000.0;
      final double totalClientPay = rawPrice + appFee;

      final bool isHireWorker = _postMode == PostMode.hireWorker;

      // MENYIMPAN SESUAI STRUKTUR FIELD FIRESTORE EKSIS
      await FirebaseFirestore.instance.collection('job_offers').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'cleanSalary': rawPrice.toInt(),
        'salary': rawPrice.toInt(),
        'totalClientPay': totalClientPay.toInt(),
        'appFee': appFee.toInt(),
        'acceptedPaymentType': _selectedPaymentType,
        'location': '$_selectedDistrict (Medan)',
        'district': _selectedDistrict,
        'company': user.displayName ?? user.email ?? (isHireWorker ? 'Pemberi Kerja' : 'Pekerja Mandiri'),
        'postedByUid': user.uid,
        'applicantUid': '',
        'workerId': '',
        'acceptedWorkerUid': '',
        'phoneNumber': _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : (user.phoneNumber ?? ''),
        
        // Exact Field Firestore
        'postType': isHireWorker ? 'job' : 'worker',
        'postMode': isHireWorker ? 'hire_worker' : 'offer_service',
        'jobType': 'harian',
        'status': 'open',
        'isSkillExchangeable': false,
        'ownTools': _requiresOwnTools
            ? 'Lengkap (Bawa Alat Sendiri)'
            : 'Peralatan Disediakan',
        'mobility': _selectedMobility,
        
        'jobDate': Timestamp.fromDate(_selectedDate),
        'createdAt': FieldValue.serverTimestamp(),
        'expiredAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isHireWorker
              ? 'Lowongan pekerjaan berhasil dibuka!'
              : 'Penawaran jasa Anda berhasil diterbitkan!'),
          backgroundColor: KkColors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menerbitkan postingan: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double currentPrice = double.tryParse(_priceController.text) ?? 0.0;
    final double totalClientPay = currentPrice + 1000.0;

    final bool isHireWorker = _postMode == PostMode.hireWorker;

    return Scaffold(
      backgroundColor: KkColors.bg,
      appBar: AppBar(
        title: Text(
          isHireWorker
              ? 'Buka Lowongan (Cari Pekerja)'
              : 'Tawarkan Jasa (Butuh Kerja)',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        backgroundColor: KkColors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOGGLE MODE POSTINGAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: KkColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _postMode = PostMode.hireWorker),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isHireWorker
                                ? KkColors.green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.work_outline_rounded,
                                size: 18,
                                color: isHireWorker
                                    ? Colors.white
                                    : KkColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Cari Pekerja',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isHireWorker
                                      ? Colors.white
                                      : KkColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _postMode = PostMode.offerService),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isHireWorker
                                ? KkColors.green
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                size: 18,
                                color: !isHireWorker
                                    ? Colors.white
                                    : KkColors.muted,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tawarkan Jasa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: !isHireWorker
                                      ? Colors.white
                                      : KkColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // INFORMASI UTAMA
              _buildSectionTitle(
                Icons.work_outline,
                isHireWorker
                    ? 'Detail Lowongan Pekerjaan'
                    : 'Detail Keahlian Anda',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration(
                        label: isHireWorker
                            ? 'Judul Lowongan Pekerjaan'
                            : 'Judul Keahlian / Jasa',
                        hint: isHireWorker
                            ? 'Contoh: Dibutuhkan tukang kebun segera'
                            : 'Contoh: Jasa Foto & Video Editing',
                        icon: Icons.title_rounded,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Judul wajib diisi' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                      decoration: _inputDecoration(
                        label: 'Kategori Pekerjaan',
                        icon: Icons.category_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // JADWAL & TANGGAL PELAKSANAAN
              _buildSectionTitle(
                Icons.calendar_month_outlined,
                'Jadwal & Tanggal Pelaksanaan',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: KkColors.inner,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: KkColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.event_available_rounded,
                                color: KkColors.green, size: 22),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isHireWorker
                                      ? 'Tanggal Pengerjaan Tugas'
                                      : 'Tersedia Mulai Tanggal',
                                  style: const TextStyle(
                                      fontSize: 10, color: KkColors.muted),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: KkColors.text),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Icon(Icons.edit_calendar_rounded,
                            color: KkColors.green, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // TARIF & PEMBAYARAN
              _buildSectionTitle(
                Icons.payments_outlined,
                isHireWorker
                    ? 'Budget / Imbalan Pekerjaan'
                    : 'Tarif & Pembayaran',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: _inputDecoration(
                        label: isHireWorker
                            ? 'Nominal Imbalan / Gaji (Rp)'
                            : 'Tarif Patokan Anda (Rp)',
                        hint: 'Contoh: 50000',
                        icon: Icons.attach_money_rounded,
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nominal wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: KkColors.inner,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: KkColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isHireWorker
                                    ? 'Budget Bersih Pekerja:'
                                    : 'Tarif Bersih Anda:',
                                style: const TextStyle(
                                    fontSize: 12, color: KkColors.muted),
                              ),
                              Text(_formatRupiah(currentPrice),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Budget Klien (+Fee Rp 1.000):',
                                style: TextStyle(
                                    fontSize: 12, color: KkColors.muted),
                              ),
                              Text(
                                _formatRupiah(totalClientPay),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: KkColors.green,
                                    fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Metode Pembayaran Diterima',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: KkColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceChip(
                            label: 'Tunai / Cash',
                            value: 'cash',
                            selectedValue: _selectedPaymentType,
                            onSelect: (val) =>
                                setState(() => _selectedPaymentType = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildChoiceChip(
                            label: 'Escrow QRIS',
                            value: 'qris',
                            selectedValue: _selectedPaymentType,
                            onSelect: (val) =>
                                setState(() => _selectedPaymentType = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // PERSYARATAN KERJA
              _buildSectionTitle(
                  Icons.checklist_rtl_rounded, 'Persyaratan Kerja'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: KkColors.green,
                      title: Text(
                        isHireWorker
                            ? 'Pekerja Wajib Bawa Peralatan'
                            : 'Membawa Peralatan Sendiri',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: KkColors.text),
                      ),
                      subtitle: Text(
                        _requiresOwnTools
                            ? 'Lengkap (Bawa Alat Sendiri)'
                            : 'Peralatan Disediakan',
                        style: const TextStyle(
                            fontSize: 11, color: KkColors.muted),
                      ),
                      value: _requiresOwnTools,
                      onChanged: (val) =>
                          setState(() => _requiresOwnTools = val),
                    ),
                    const Divider(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedMobility,
                      items: _mobilityOptions.map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedMobility = val);
                      },
                      decoration: _inputDecoration(
                        label: 'Persyaratan Mobilitas',
                        icon: Icons.two_wheeler_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // LOKASI & DESKRIPSI
              _buildSectionTitle(Icons.location_on_outlined, 'Lokasi & Detail'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      items: _medanDistricts.map((district) {
                        return DropdownMenuItem(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDistrict = val);
                      },
                      decoration: _inputDecoration(
                        label: 'Kecamatan di Kota Medan',
                        icon: Icons.map_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecoration(
                        label: 'Nomor WhatsApp Kontak',
                        hint: 'Contoh: 087817615382',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        label: 'Deskripsi & Catatan Tambahan',
                        hint: isHireWorker
                            ? 'Tuliskan detail tugas yang harus dikerjakan, syarat khusus, atau jam kerja...'
                            : 'Tuliskan detail jasa, portofolio singkat, atau cakupan layanan Anda...',
                        icon: Icons.description_outlined,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Deskripsi wajib diisi'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // TOMBOL SUBMIT
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KkColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitOffer,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isHireWorker
                              ? 'Buka Lowongan Pekerjaan'
                              : 'Terbitkan Penawaran Jasa',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: KkColors.green),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: KkColors.text,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: KkColors.border),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: KkColors.muted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: KkColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: KkColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: KkColors.green, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required String value,
    required String selectedValue,
    required Function(String) onSelect,
  }) {
    final bool isSelected = value == selectedValue;
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? KkColors.greenSoft : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? KkColors.green : KkColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? KkColors.green : KkColors.text,
            ),
          ),
        ),
      ),
    );
  }
}