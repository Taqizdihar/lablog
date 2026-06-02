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
      mkId: map['mk_id'] as int,
      judul: map['judul'] as String,
      tanggal: map['tanggal'] as String,
      tujuan: map['tujuan'] as String,
      prosedur: map['prosedur'] as String,
      kesimpulan: map['kesimpulan'] as String,
      statusJurnal: map['status_jurnal'] as String,
    );
  }
}
