class PeminjamanAlat {
  int? id;
  String namaAlat;
  String tanggalPinjam;
  String tenggatKembali;
  String status;

  PeminjamanAlat({
    this.id,
    required this.namaAlat,
    required this.tanggalPinjam,
    required this.tenggatKembali,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama_alat': namaAlat,
      'tanggal_pinjam': tanggalPinjam,
      'tenggat_kembali': tenggatKembali,
      'status': status,
    };
  }

  factory PeminjamanAlat.fromMap(Map<String, dynamic> map) {
    return PeminjamanAlat(
      id: map['id'] as int?,
      namaAlat: map['nama_alat']?.toString() ?? '',
      tanggalPinjam: map['tanggal_pinjam']?.toString() ?? '',
      tenggatKembali: map['tenggat_kembali']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
    );
  }
}
