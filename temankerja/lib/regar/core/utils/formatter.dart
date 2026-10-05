/// 120000 -> "Rp 120.000"
String rupiah(int value) {
  final digits = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write('.');
    buf.write(digits[i]);
  }
  return '${value < 0 ? '-' : ''}Rp $buf';
}

String nowLabel() {
  final n = DateTime.now();
  String p(int v) => v.toString().padLeft(2, '0');
  return '${p(n.day)}/${p(n.month)}/${n.year} ${p(n.hour)}.${p(n.minute)} WIB';
}
