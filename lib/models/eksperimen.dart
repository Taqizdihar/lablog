class Eksperimen {
  int? id;
  int mkId;
  String judul;
  String tanggal;
  String tujuan;
  String prosedur;
  String kesimpulan;
  String statusJurnal;

  Eksperimen({
    this.id,
    required this.mkId,
    required this.judul,
    required this.tanggal,
    required this.tujuan,
    required this.prosedur,
    required this.kesimpulan,
    required this.statusJurnal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mk_id': mkId,
      'judul': judul,
      'tanggal': tanggal,
      'tujuan': tujuan,
      'prosedur': prosedur,
      'kesimpulan': kesimpulan,
      'status_jurnal': statusJurnal,
    };
  }

  factory Eksperimen.fromMap(Map<String, dynamic> map) {
    return Eksperimen(
      id: map['id'] as int?,
      mkId: map['mk_id'] as int? ?? 0,
      judul: map['judul']?.toString() ?? '',
      tanggal: map['tanggal']?.toString() ?? '',
      tujuan: map['tujuan']?.toString() ?? '',
      prosedur: map['prosedur']?.toString() ?? '',
      kesimpulan: map['kesimpulan']?.toString() ?? '',
      statusJurnal: map['status_jurnal']?.toString() ?? '',
    );
  }
}
